#!/bin/bash

###
# Date        : 2020-08-15 09:29:18
# Author      : shy
# Email       : yushuibo@ebupt.com / hengchen2005@gmail.com
# Version     : v1.0
# Description : A simple http server with python.
###

if [[ $# -eq 0 ]];then
  python3 -u -m http.server 8888
else
  python3 -u -m http.server 8888 -d $1
fi
