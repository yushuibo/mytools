#!/usr/bin/env python
# -*- coding=UTF-8 -*-
'''
@ Since: 2019-06-01 21:09:56
@ Author: shy
@ Email: yushuibo@ebupt.com / hengchen2005@gmail.com
@ Version: v1.0
@ Licence: GPLv3
@ Description: -
@ LastTime: 2019-06-01 21:12:04
'''

import os
import shutil
import datetime

readme = u'''http://wp-cloud.cc
winrar中文版去广告&注册(5.5、5.6中测试通过)
water
2018-12-19
version: %s'''

s_version = "1.0.1"

root = u"C:\\Program Files\\WinRAR"
key = '''RAR registration data
hack520.com
100 PC usage license
UID=220d3db605000308573f
6412212250573ffc6e51d88cce8a99a8dfa5d804dd25cb051d0d71
e37850904841767d6eb96007e697024c155e27713a0f6ced4231f1
bdd814b379ce793dea8dc738ed6feab43e470752e4be6223bc1505
ef939613fad2a789a4e17319eb43d7f8b2604ef0962667fec07a8b
69df8bb8db1f2f7ec0abb74d2a31c41f1b84c60e2791ff599c7861
5e4159055774731ce5addef0262b0d629791f8d0f06b5898606a6f
8dff593fe66724e6bc0eb47b5441b844ee1e3a3bf67e2053147473
'''


def register():
    fn = '%s\\rarreg.key' % root
    if not os.path.exists(fn):
        f = open(fn, 'w')
        f.write(key)
        f.close()
        print(u'-->写入注册文件成功！')
    else:
        print(u'-->已注册！')


def clear():
    b_crack = False
    s_dt = datetime.datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
    fn = '%s\\WinRAR.exe' % root
    fn_bak = '%s\\WinRAR.exe.bak_%s' % (root, s_dt)
    fn_out = '%s\\WinRAR.exe.new' % root
    n = os.path.getsize(fn)
    if os.path.exists(fn):
        b = '##0aN9=>34'.encode('utf-16le')
        f = open(fn, 'rb')
        f_out = open(fn_out, 'wb')
        t = b''
        while True:
            s = f.read(2)
            if len(s) < 2:
                break
            t += s
            if len(t) > len(b):
                t = t[2:]
            if t == b:
                s = b'0\x00'
                b_crack = True
            f_out.write(s)

        f.close()
        f_out.close()

        if b_crack:
            shutil.move(fn, fn_bak)
            shutil.move(fn_out, fn)
            print(u'-->破解完成！')
        else:
            os.remove(fn_out)
            print(u'-->已破解或不是中文版！')

    else:
        print(u'-->文件不存在！')


if __name__ == '__main__':
    print(readme % s_version)
    clear()
    register()
