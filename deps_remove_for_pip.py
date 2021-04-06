#!/usr/bin/env python
# -*- coding=UTF-8 -*-
'''
@Author: shy
@Email: yushuibo@ebupt.com / hengchen2005@gmail.com
@Version: v1.0
@Licence: GPLv3
@Description: -
@Since: 2019-03-25 20:28:34
@LastTime: 2019-04-03 15:26:17
'''

import os


def check_dependents(module_name):
    """
    查看一个模块的依赖
    :param module_name: 模块名
    :return: module_name 所依赖的模块的列表
    """
    with os.popen('pip show %s' % module_name) as p:
        dependents = p.readlines()
        if not len(dependents):
            return None
        dependents = dependents[-1]
        dependents = dependents.split(':')[-1].replace(' ', '').strip()
        if dependents:
            dependents = dependents.split(',')
        else:
            dependents = None
        return dependents


def remove(module_name):
    """
    递归地卸载一个模块
    :param module_name: 模块名称
    :return: None
    """
    dependents = check_dependents(module_name)
    if dependents:
        for package in dependents:
            remove(package)
    os.system('pip uninstall -y %s' % module_name)


if __name__ == '__main__':
    pkg_name = raw_input(u'请输入要卸载的第三方模块包: ')
    remove(pkg_name)
