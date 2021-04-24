#!/usr/bin/env python
# -*- coding=UTF-8 -*-
'''
@ Author: shy
@ Email: yushuibo@ebupt.com / hengchen2005@gmail.com
@ Version: v1.0
@ Description: -
@ Since: 2020/4/13 13:48
'''

import os
import re
import sys
import base64

import requests
import AdvancedHTMLParser
from requests import ConnectionError

servers = []
payloads_prefix_name = 'payloads'

ishadow_url = 'https://my.ishadowx.biz/'
sssub_prefix_url = 'https://raw.githubusercontent.com/ssrsub/ssr/master/'
sssub_paths = ['ss-sub', 'ssrsub', 'trojan', 'v2ray']

hearders = {
    "User-Agent":
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
    "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.163 Safari/537.36"
}


def get_sssub_payload():
    for path in sssub_paths:
        hosts = []
        sssub_url = '{}{}'.format(sssub_prefix_url, path)
        print('Try to open url {}...'.format(sssub_url))
        try:
            resp = requests.get(sssub_url, headers=hearders)
        except ConnectionError:
            print("Open url failed, abort!")
            sys.exit(-1)
        print("Starting parser response...")
        raw_text = base64.b64decode(resp.text.encode())
        hosts.extend(raw_text.decode().split('\n'))
        servers.append(hosts)


def get_ishadow_payload():
    print('Try to open url {}...'.format(ishadow_url))
    try:
        resp = requests.get(ishadow_url, headers=hearders)
    except ConnectionError:
        print("Open url failed, abort!")
        sys.exit(-1)

    print("Starting parser response...")
    html = resp.text
    parser = AdvancedHTMLParser.AdvancedHTMLParser()
    parser.parseStr(html)
    tags = parser.getElementsByClassName('hover-text').getElementsByXPath("//div/h4")

    ips = []
    ports = []
    passwds = []
    methods = []
    vmess_payloads = []
    for tag in tags:
        if not tag.hasChildNodes():
            methods.append(tag.innerText.split(':')[1].strip())
        else:
            for child in tag.getChildren():
                if not child.getAttribute('id'):
                    continue

                tag_id = str(child.getAttribute('id'))
                if re.match(r'ip.*', tag_id):
                    ips.append(child.innerText.strip())
                elif re.match(r'port.*', tag_id):
                    ports.append(child.innerText.strip())
                elif re.match(r'pw.*', tag_id):
                    passwds.append(child.innerText.strip())
                elif re.match(r'url.*', tag_id):
                    vmess_payloads.append(child.getAttribute('data-clipboard-text').strip())
                else:
                    pass

    ss_payloads = zip(ips, methods, ports, passwds)

    print('Got ss payloads:')
    for payload in ss_payloads:
        print('\tHost={}, Method={}, Port={}, Passwd={}'.format(*payload))

    print('Got vmess payloads:')
    for payload in vmess_payloads:
        print('\tURL={}'.format(payload))

    print('Got ishadow payload successfully.')

    return ss_payloads, vmess_payloads


def builder(ss_payloads, vmess_payloads):
    print('Starting build base64 url...')
    for payload in ss_payloads:
        host, method, port, passwd = payload

        ss_raw = '{method}:{passwd}@{ip}:{port}'.format(method=method, passwd=passwd, ip=host, port=port)

        # a.isxb.top:19291:origin:aes-256-gcm:plain:aXN4Lnl0LTg3ODIxNzU0/?obfsparam=&group=RGVmYXVsdCBHcm91cA
        sr_raw = '{ip}:{port}:origin:{method}:palin:{passwd}/?obfsparam=&group={group}'.format(
            method=method, passwd=base64.b64encode(passwd), ip=host, port=port, group=base64.b64encode('iShadow'))

        ss_encoded = base64.b64encode(ss_raw)
        sr_encoded = base64.b64encode(sr_raw)

        servers[0].append('ss://{}#{}'.format(ss_encoded, host))
        servers[1].append('ssr://{}'.format(sr_encoded))

    servers.append(vmess_payloads)
    return servers


def gen_file(servers):
    print('Starting generate subcribe files...')
    index = 1
    for hosts in servers:
        hosts = filter(lambda x: x, hosts)
        with open('{}_00{}.txt'.format(payloads_prefix_name, index), 'w') as fd:
            fd.write(base64.b64encode('\n'.join(hosts).encode()).decode())
            fd.flush()
        index += 1


if __name__ == '__main__':
    get_sssub_payload()
    ss_payloads, vmess_payloads = get_ishadow_payload()
    servers = builder(ss_payloads, vmess_payloads)
    gen_file(servers)
    print("Subcribe generate done!")
