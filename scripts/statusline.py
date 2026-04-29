#!/usr/bin/env python3
"""Minimal Claude Code statusline. Reads session JSON from stdin."""
import json
import os
import sys


def main():
    try:
        d = json.load(sys.stdin)
    except Exception:
        return

    model = d.get('model', {}).get('display_name') or '?'
    cwd = d.get('workspace', {}).get('current_dir') or os.getcwd()
    cwd_short = os.path.basename(cwd.rstrip('/\\'))

    cyan = '\033[36m'
    dim = '\033[2m'
    nc = '\033[0m'

    print(f"{cyan}{model}{nc} {dim}|{nc} {cwd_short}", end='')


if __name__ == '__main__':
    main()
