#!/bin/bash

###
# @Date        : 2021-05-22 14:19:22
# @Author      : shy
# @Email       : yushuibo@ebupt.com / hengchen2005@gmail.com
# @Version     : v1.0
# @Description : auto update privoxy,
#
# brew install privoxy
#
###

which -s privoxy &> /dev/null
[[ $? -ne 0 ]] && echo "privoxy not installed yet, please install it first!" && exit 0

## privoxy 配置文件, macosx
conf='/usr/local/etc/privoxy/config'
## gfwlist.action 文件
gfwlist_action='gfwlist.action'

## socks5 代理地址，必须为 ip:port 形式
socks5_proxy=$1
if [[ ! "${socks5_proxy}" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}:[0-9]{1,5}$ ]]; then
  echo -e "\e[35minvalid address:\e[0m \"${socks5_proxy}\"" 1>&2
  echo -e "\e[37mUsage:\e[0m \e[32m$0\e[0m \e[36m'address:port'\e[0m" 1>&2
  exit 1
else
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
fi

## 用到的临时文件
gfwlist_txt=$(mktemp)
gfwlist_regex=$(mktemp)
gfwlist_scheme=$(mktemp)
gfwlist_begin=$(mktemp)
gfwlist_main=$(mktemp)
gfwlist_temp=$(mktemp)

## 获取 gfwlist.txt
curl -4sSkL https://raw.github.com/gfwlist/gfwlist/master/gfwlist.txt | base64 --decode | egrep -v '^$|^!|^@@|^\[AutoProxy' > ${gfwlist_txt}
[[ $? -ne 0 ]] && echo "Updating gfwlist.txt failed, abort!" && exit -128

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

echo "Starting update privoxy..."
cp - af ${gfwlist_action} ${conf} \
  && ps -ef | grep privoxy | grep local | awk '{print $2}' | xargs kill -9 \
  && privoxy ${conf} \
  && rm ${gfwlist_action}
echo "Done!"

## 打印接下来要执行的命令（应用 gfwlist_action）
# echo -e "\e[37m# Please execute the following command:\e[0m"
# echo -e "\e[36mcp -af ${gfwlist_action} /etc/privoxy/\e[0m"
# echo -e "\e[36mecho \"actionsfile ${gfwlist_action}\" >> /etc/privoxy/config\e[0m"
