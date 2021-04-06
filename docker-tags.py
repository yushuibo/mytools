#!/usr/bin/env python3
# -*- coding=UTF-8 -*-
'''
@ Date        : 2021-03-15 10:55:04
@ Author      : shy
@ Email       : yushuibo@ebupt.com / hengchen2005@gmail.com
@ Version     : v1.0
@ Description : A tool for ist all tags for docker image on a remote registry.
'''

import re
import sys
import json

import click
import requests

api = 'https://registry.hub.docker.com/v1/repositories'


def fetch_tags(image, pattern=None):
    if not image:
        # no image name specified
        return []
    try:
        all_tag_infos = requests.get('{}/{}/tags'.format(api, image)).json()
    except json.decoder.JSONDecodeError:
        return []
    # no tags found
    if not isinstance(all_tag_infos, list):
        return []
    if not pattern:
        return [res['name'] for res in all_tag_infos]
    else:
        return [res['name'] for res in filter(lambda x: re.match(pattern, x['name']), all_tag_infos)]


@click.command()
@click.help_option('-h', '--help')
@click.version_option(version='1.0.0')
@click.argument('images', type=click.STRING, nargs=-1)
@click.option('-p', '--pattern', type=click.STRING, default=None, help='A pattern for docker image\'s tag.')
def batch_fecth_tags(images, pattern=None):
    """
    \b
    A tool for ist all tags for docker image on a remote registry.

    \b
    Examples:
      docker-tags.py nginx
      docker-tags.py nginx -p alpine
      docker search nginx | docker-tags.py
      docker search nginx | docker-tags.py -p alpine
      echo nginx | docker-tags.py
      echo nginx | docker-tags.py -p alpine
    """
    if not images:
        # is this a keyboard ? only suport read from PIPE
        if sys.stdin.isatty():
            click.echo(click.get_current_context().get_help())
            return

        # think use for: docker search nginx | python docker-tags.py
        inputs = [re.split(r'\s+', line)[0] for line in sys.stdin.readlines()]
        images = filter(lambda x: x != 'NAME', inputs)

    for image in images:
        fullname = '{}:*{}*'.format(image, pattern) if pattern else '{}:*'.format(image)
        tags = fetch_tags(image, pattern=pattern)
        count = len(tags)
        if not count:
            click.echo('There is no tags found for image [{}]'.format(fullname))
            continue

        click.echo('Total {} tags found for image [{}]: '.format(count, fullname))
        for tag in tags:
            click.echo('{}:{}'.format(image, tag), color=True)

        click.echo()


if __name__ == "__main__":
    batch_fecth_tags()
