#!/usr/local/bin/zsh

###
# Date        : 2021-05-16 22:30:40
# Author      : shy
# Email       : yushuibo@ebupt.com / hengchen2005@gmail.com
# Version     : v1.0
# Description : -
###

# 替换 brew.git:
git -C "$(brew --repo)" remote set-url origin https://github.com/Homebrew/brew.git

# 替换 homebrew-core.git:
git -C "$(brew --repo homebrew/core)" remote set-url origin https://github.com/Homebrew/homebrew-core.git

# 替换 homebrew-cask.git:
git -C "$(brew --repo homebrew/cask)" remote set-url origin https://github.com/Homebrew/homebrew-cask.git

# 应用生效
brew update-reset
brew update
