#!/usr/bin/env python
# -*- coding=UTF-8 -*-
'''
@ Since: 2019-06-02 07:04:38
@ Author: shy
@ Email: yushuibo@ebupt.com / hengchen2005@gmail.com
@ Version: v1.0
@ Description: -
@ LastTime: 2019-12-05 17:38:26
'''

from __future__ import print_function
from __future__ import unicode_literals

import os
import io
import re

content_temp = """
Sub Main
\txsh.Screen.WaitForString "[ q ]"
\txsh.Session.Sleep 5
\txsh.Screen.Synchronous = True
%s
\txsh.Screen.Send chr(13)
\txsh.Screen.WaitForString "unused"
\txsh.Screen.Send "0"
\txsh.Session.Sleep 5
\txsh.Screen.Send chr(13)
%s
End Sub
"""


def rewrite(filename):
    bak_file = '{}.orig'.format(filename)
    os.system('copy {} {} 1>nul 2>nul'.format(filename, bak_file))
    print('starting process {}...'.format(filename))
    ip = re.sub(r'[^\d.]', '', os.path.basename(filename).replace('.vbs', ''))
    ip_area = '\txsh.Session.Sleep 5\n'.join(['\txsh.Screen.Send "{}"\n'.format(c) for c in ip])
    keeped = []
    rfp = io.open(bak_file, 'r', encoding='utf-8')
    for line in rfp:
        if not line:
            continue
        if re.match(r'\s*xsh\.Screen\.Send \".{2,}\"\n', line):
            keeped.append(line)

    keeped.append('')
    auth_area = '\txsh.Session.Sleep 5\n\txsh.Screen.Send chr(13)\n'.join(keeped).replace('crt', 'xsh')
    rfp.close()
    # print(content_temp % (ip_area, auth_area))
    with io.open(filename, 'w', encoding='utf-8') as wfp:
        wfp.write(content_temp % (ip_area, auth_area))

    os.remove(bak_file)


if __name__ == "__main__":

    directory = 'C:\\Users\\shy\\OneDrive\\commons\\loginvbs\\xsh\\'
    for root, _, files in os.walk(directory):
        for f in files:
            f = '{}\\{}'.format(root, f)
            if os.path.splitext(f)[1] != '.vbs':
                print("File {} is not a valid login scripts, skipped.".format(f))
                continue
            rewrite(f)
