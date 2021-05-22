#!/bin/zsh

###
# @Date        : 2021-05-22 14:19:22
# @Author      : shy
# @Email       : yushuibo@ebupt.com / hengchen2005@gmail.com
# @Version     : v1.0
# @Description : a tool of privoxy, which can use pac proxy in the terminal.
#
# for macosx, install:
#
# brew install privoxy
# echo 'forward-socks5 / 127.0.0.1:1080 .' >>/usr/local/etc/privoxy/config
# 对于shadowsocksX-NG, socks5监听端口为1086, 所以应该更改上面配置为
# echo 'forward-socks5 / 127.0.0.1:1086 .' >>/usr/local/etc/privoxy/config
# privoxy /usr/local/etc/privoxy/config
# ps aux | grep privoxy
# netstat -an | grep 8118
#
###

source ~/.zshrc

which -s privoxy &> /dev/null
[[ $? -ne 0 ]] && echo "Privoxy not installed yet, please install it first!" && exit 0

## socket proxy server
socket_proxy='127.0.0.1:1086'
## privoxy 配置文件, macosx
conf='/usr/local/etc/privoxy/config'
## gfwlist.action 文件
gfwlist_action='/tmp/gfwlist.action'

function start() {
  ps -ef | grep privoxy | grep -v 'grep' &> /dev/null
  [[ $? -eq 0 ]] && echo "Privoxy is already running!" && exit 0
  echo -n -e "Starting privoxy:\t"
  privoxy $conf
  [[ $? -eq 0 ]] && echo -e "\e[32m[OK]\e[0m" || echo -e "\e[31m[NOK]\e[0m"
}

function stop() {
  echo -n -e "Stopping privoxy:\t"
  ps -ef | grep privoxy | grep -v 'grep' | awk '{print $2}' | xargs kill -9
  [[ $? -eq 0 ]] && echo -e "\e[32m[OK]\e[0m" || echo -e "\e[31m[NOK]\e[0m"
}

function status() {
  echo -n -e "Privoxy status is:\t"
  ps -ef | grep privoxy | grep -v 'grep' &> /dev/null
  [[ $? -eq 0 ]] && echo -e "\e[32m[RUNNING]\e[0m" || echo -e "\e[31m[STOPPED]\e[0m"
}

function update() {
  ## socks5 代理地址，必须为 ip:port 形式
  socks5_proxy=$1
  echo -n -e "Updating privoxy's gfwlist.action:\t"

  echo "{{alias}}" > ${gfwlist_action}
  echo "# 直连方式，也就是说让请求走本地网络" >> ${gfwlist_action}
  echo "direct      = +forward-override{forward .}" >> ${gfwlist_action}
  echo "# 请求转发到代理机器" >> ${gfwlist_action}
  echo "proxy       = +forward-override{forward-socks5 ${socks5_proxy} .}" >> ${gfwlist_action}
  echo "# 默认策略，直连" >> ${gfwlist_action}
  echo "default     = direct" >> ${gfwlist_action}
  echo >> ${gfwlist_action}
  echo "{default}" >> ${gfwlist_action}
  echo "/" >> ${gfwlist_action}
  echo >> ${gfwlist_action}
  echo "# 白名单，直连" >> ${gfwlist_action}
  echo "{direct}" >> ${gfwlist_action}
  echo >> ${gfwlist_action}
  echo "127.0.0.1" >> ${gfwlist_action}
  echo "localhost" >> ${gfwlist_action}
  echo "ghproxy.com" >> ${gfwlist_action}
  echo "github.com" >> ${gfwlist_action}
  echo ".github.com" >> ${gfwlist_action}
  echo ".amazonaws.com" >> ${gfwlist_action}
  echo >> ${gfwlist_action}
  echo "# 黑名单，代理" >> ${gfwlist_action}
  echo "{proxy}" >> ${gfwlist_action}
  echo 'libsdl.org' >> ${gfwlist_action}

  gfwlist_raw=$(mktemp)
  ## 获取 gfwlist.txt
  # curl -4sSkL https://raw.github.com/gfwlist/gfwlist/master/gfwlist.txt 2> /dev/null > ${gfwlist_raw}
  curl -4sSkL https://ghproxy.com/https://raw.githubusercontent.com/shy1248/fish-payload/master/fish.txt 2> /dev/null > ${gfwlist_raw}

  if [[ $? -ne 0 ]]; then
    echo -e "\e[31m[NOK]\e[0m"
    ## 删除临时文件
    rm -fr ${gfwlist_raw}
    exit -128
  else
    ## 用到的临时文件
    gfwlist_txt=$(mktemp)
    gfwlist_regex=$(mktemp)
    gfwlist_scheme=$(mktemp)
    gfwlist_begin=$(mktemp)
    gfwlist_main=$(mktemp)
    gfwlist_temp=$(mktemp)
    cat ${gfwlist_raw} | egrep -v '^$|^!|^@@|^\[AutoProxy' > ${gfwlist_txt}
    ## 分离不同的语法
    cat ${gfwlist_txt} | egrep '^/' > ${gfwlist_regex}                  # '/regex/' 正则
    cat ${gfwlist_txt} | egrep '^\|\|' > ${gfwlist_scheme}              # '||pattern' 协议符
    cat ${gfwlist_txt} | egrep '^\|[^\|]' > ${gfwlist_begin}            # '|pattern' 边界符
    cat ${gfwlist_txt} | egrep -v '^/|^\|\||^\|[^\|]' > ${gfwlist_main} # 与 privoxy.action 语法接近的部分
    ## 黑名单，处理正则语法 (目前只能手动添加，因为将正则替换为 shell 通配符太复杂了)
    echo '.google.' >> ${gfwlist_main}
    echo '.blogspot.' >> ${gfwlist_main}
    echo '.twimg.edgesuite.net' >> ${gfwlist_main}
    ## 处理协议符，直接删除即可，在 privoxy.action 中没有所谓的协议字段
    cat ${gfwlist_scheme} | sed -E 's@^\|\|(.*)$@\1@g' >> ${gfwlist_main}
    ## 处理边界符，删除边界符，然后删除可能有的协议字段
    cat ${gfwlist_begin} | sed -E 's@^\|(.*)$@\1@g' | sed -E '\@^https?://@ s@^https?://(.*)$@\1@g' >> ${gfwlist_main}
    ## 处理 gfwlist_main 文件，去除尾部的 uri 部分，只保留域名
    cat ${gfwlist_main} | sed -E '\@/@ s@^([^/]*).*$@\1@g' | sort | uniq -i > ${gfwlist_temp}
    ## 处理 ipv4 地址
    cat ${gfwlist_temp} | grep -E '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$' >> ${gfwlist_action}
    ## 处理域名，在开头添加 '.'，然后删除重复内容
    cat ${gfwlist_temp} | grep -Ev '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$' | sed -E '\@^\.@! s@^(.*)$@.\1@g' | sort | uniq -i >> ${gfwlist_action}
    ## 处理完毕，删除临时文件
    rm -fr ${gfwlist_txt} ${gfwlist_regex} ${gfwlist_scheme} ${gfwlist_begin} ${gfwlist_main} ${gfwlist_temp}
    cp -af ${gfwlist_action} $(dirname ${conf}) && rm ${gfwlist_action} && echo -e "\e[32m[OK]\e[0m"
  fi
}

case $1 in
  start)
    start
    ;;
  stop)
    stop
    ;;
  status)
    status
    ;;
  restart)
    stop && sleep 2 && start
    ;;
  update)
    if [[ -z $2 ]]; then
      echo -e "\e[33mNo proxy server sepcified, using default: 127.0.0.1:1086.\e[0m"
      update 127.0.0.1:1086
    elif [[ ! "$2" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}:[0-9]{1,5}$ ]]; then
      echo -e "\e[31mInvalid proxy server address: $2"
      exit 128
    else
      update $2
    fi
    ;;
  *)
    echo -e "USAGE: \e[32m$(basename $0)\e[0m {start|stop|status|restart|update <IP:PORT>}"
    echo
    exit 128
    ;;
esac
