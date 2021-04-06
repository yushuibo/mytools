#!/bin/sh

###
# Date        : 2020-11-03 20:39:47
# Author      : shy
# Email       : yushuibo@ebupt.com / hengchen2005@gmail.com
# Version     : v1.0
# Description : -
###

HOST="221.178.45.221"
PORT=8822
USER="ftpd"
PASSWD="Music#2020"

build_cmd(){
	_type=$1
	shift
	echo > .mgsftp.tmp
	for f in $@;do
	  echo "${_type} ${f}"
	done
	cmd=$(cat .mgsftp.tmp)
	rm .mgsftp.tmp
	echo ${cmd}
}

download() {
  cmd=$(build_cmd $@)
  sshpass -p "${PASSWD}" sftp -oPort=${PORT} -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no ${USER}@${HOST} << EOF
  # lftp -e "set sftp:auto-confirm yes" -p ${PORT} sftp://${USER}@${HOST} << EOF
cd shy/upload
${cmd}
exit
EOF
}

upload() {
  cmd=$(build_cmd $@)
  sshpass -p "${PASSWD}" sftp -oPort=${PORT} -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no ${USER}@${HOST} << EOF
cd shy/upload
${cmd}
exit
EOF
}

remove() {
  cmd=$(build_cmd $@)
  sshpass -p "${PASSWD}" sftp -oPort=${PORT} -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no ${USER}@${HOST} << EOF
cd shy/upload
${cmd}
exit
EOF
}

list() {
  sshpass -p "${PASSWD}" sftp -oPort=${PORT} -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no ${USER}@${HOST} << EOF
cd shy/upload
ls -l
exit
EOF
}

shelp() {
  echo "Usage: $(basename $0) option dest_file ..."
  echo "\t -[d|D] f1 f2 ... : dowload files from remote server to local in current directory."
  echo "\t -[u|U] f1 f2 ... : upload files from local to remote server."
  echo "\t -[r|R] f1 f2 ... : remove files from remote server."
  echo "\t -[l|L] : list files from remote server."
}


OPER=$1
shift

if [[ x"$(echo ${OPER} | tr 'a-z' 'A-Z')" == x"-D" ]]; then
  download get $@
elif [[ x"$(echo ${OPER} | tr 'a-z' 'A-Z')" == x"-U" ]]; then
  upload put $@
elif [[ x"$(echo ${OPER} | tr 'a-z' 'A-Z')" == x"-R" ]]; then
  remove rm $@
elif [[ x"$(echo ${OPER} | tr 'a-z' 'A-Z')" == x"-L" ]]; then
  list
else
  shelp
fi

