#!/usr/bin/env python3
# -*- coding=UTF-8 -*-

'''
@ Date        : 2021-03-18 14:45:44
@ Author      : shy
@ Email       : yushuibo@ebupt.com / hengchen2005@gmail.com
@ Version     : v1.0
@ Description : -
'''

import pty
import sys

pty.spawn(sys.argv[1:])
