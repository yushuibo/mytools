#!/usr/local/bin/zsh

###
# Date        : 2021-05-16 22:29:39
# Author      : shy
# Email       : yushuibo@ebupt.com / hengchen2005@gmail.com
# Version     : v1.0
# Description : -
# 清华源：https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git
# 中科大源：https://mirrors.ustc.edu.cn/brew.git
# 阿里源：https://mirrors.aliyun.com/homebrew/brew.git
###

REPO='https://mirrors.ustc.edu.cn'

# 替换 brew.git:
git -C "$(brew --repo)" remote set-url origin $REPO/brew.git

# 替换 homebrew-core.git:
git -C "$(brew --repo homebrew/core)" remote set-url origin $REPO/homebrew-core.git

# 替换 homebrew-cask.git:
git -C "$(brew --repo homebrew/cask)" remote set-url origin $REPO/homebrew-cask.git

# 应用生效
brew update-reset
brew update
# 替换 homebrew-bottles:
sed -i '' '/HOMEBREW_BOTTLE_DOMAIN/d' ~/.zshrc && \
echo "export HOMEBREW_BOTTLE_DOMAIN=$REPO/homebrew-bottles" >> ~/.zshrc
. ~/.zshrc
