#!/bin/bash  
###########################################################################
# File Name: fix_onedrive.sh
# Author: yushuibo  
# Mail: hengchen2005@gmail.com  
# Descraption: --  
# Created Time: 2020-10-24 12:47:25
###########################################################################

## Fix OneDrive for Mac CPU usage
##
## Seems this is still a problem 5 years later after I created this little gist.
## I have long since stopped using OneDrive (luckily), but according to
## comments below, I have added the new path for OfficeFileCache for macOS
## Mojave (10.14) and Catalina (10.15).

## Run this on macOS Mojave (10.14) and Catalina (10.15)
find ~/Library/Containers/ -type d -name OfficeFileCache -exec rm -r {} +

## Run this if you're on pre-Mojave (< 10.14)
find ~/Library/Group\ Containers/ -type d -name OfficeFileCache -exec rm -r {} +
