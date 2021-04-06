#!/bin/bash  
###########################################################################
# File Name: 
# Author: yushuibo  
# Mail: hengchen2005@gmail.com  
# Descraption: --  
# Created Time: 2020-10-24 17:53:06
###########################################################################

sudo softwareupdate --ignore "macOS Catalina"
defaults write com.apple.systempreferences AttentionPrefBundleIDs 0
killall Dock
