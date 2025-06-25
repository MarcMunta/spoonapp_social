#!/usr/bin/env python
import os
import sys
import shutil
import subprocess

def ensure_msgfmt():
    """Ensure the `msgfmt` binary is available, installing gettext if possible."""
    if shutil.which('msgfmt'):
        return

    print('msgfmt not found. Attempting automatic installation of gettext...')
    try:
        if sys.platform.startswith('linux') and shutil.which('apt-get'):
            subprocess.check_call(['sudo', 'apt-get', 'update'])
            subprocess.check_call(['sudo', 'apt-get', 'install', '-y', 'gettext'])
        elif sys.platform == 'darwin' and shutil.which('brew'):
            subprocess.check_call(['brew', 'install', 'gettext'])
            subprocess.check_call(['brew', 'link', '--force', 'gettext'])
        elif os.name == 'nt' and shutil.which('choco'):
            subprocess.check_call(['choco', 'install', 'gettext', '-y'])
    except Exception as exc:
        print(f'Failed to automatically install gettext: {exc}')

    if not shutil.which('msgfmt'):
        print('msgfmt is still missing. Please install gettext manually.')

if __name__ == '__main__':
    os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'spoonapp_social.settings')
    try:
        from django.core.management import call_command, execute_from_command_line
    except ImportError as exc:
        raise ImportError(
            "Couldn't import Django."
        ) from exc

    ensure_msgfmt()
    try:
        call_command('compilemessages', verbosity=0)
    except Exception as exc:
        print(f'Error compiling messages: {exc}')

    execute_from_command_line(sys.argv)
