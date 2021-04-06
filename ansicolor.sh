#!/bin/bash

###
# Date        : 2021-03-15 21:12:08
# Author      : shy
# Email       : yushuibo@ebupt.com / hengchen2005@gmail.com
# Version     : v1.0
# Description : A tool for the teminal ansi color showtime.
###

NAMES=('BLK:黑' 'RED:红' 'GRE:绿' 'YLW:黄' 'BLE:蓝' 'MGT:紫' 'CYA:青' 'WIT:白')

for((i=40;i<50;i++));do
  for((j=30;j<38;j++));do
	((name_index = j - 30))
    echo -e "\033[0;"$i";"$j"m NOMARL:${NAMES[$name_index]}:$j  HandglovesThe quick brown fox jumps over the lazy dog\033[0m"
    echo -e "\033[1;"$i";"$j"m BRIGHT:${NAMES[$name_index]}:$j  HandglovesThe quick brown fox jumps over the lazy dog\033[0m"
  done
done

