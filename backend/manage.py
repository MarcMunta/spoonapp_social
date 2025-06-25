#!/usr/bin/env python
import os
import sys

if __name__ == '__main__':
    os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'spoonapp_social.settings')
    try:
        from django.core.management import call_command, execute_from_command_line
    except ImportError as exc:
        raise ImportError(
            "Couldn't import Django."
        ) from exc

    try:
        call_command('compilemessages', verbosity=0)
    except Exception as exc:
        print(f'Error compiling messages: {exc}')

    execute_from_command_line(sys.argv)
