#!/usr/bin/env python
import os
import sys
import django

# Add the current directory to the Python path
sys.path.insert(0, os.path.dirname(__file__))

# Set up Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

# Now run the migration commands
from django.core.management import execute_from_command_line

if __name__ == '__main__':
    # Create migrations
    execute_from_command_line(['manage.py', 'makemigrations'])
    
    # Apply migrations
    execute_from_command_line(['manage.py', 'migrate'])
    
    print("✅ Notification model migration created and applied successfully!")
