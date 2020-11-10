@echo off
cd C:/Users/shy/OneDrive/dev/python/mytools/ishadow-util
python -u ishadow-util.py

git add .
git commit -m 'update'
git push
exit