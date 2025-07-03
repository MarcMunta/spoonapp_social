from django.db import migrations


def add_clips_category(apps, schema_editor):
    PostCategory = apps.get_model('social', 'PostCategory')
    PostCategory.objects.get_or_create(name='Clips')

class Migration(migrations.Migration):

    dependencies = [
        ('social', '0028_communityfollow_and_followers'),
    ]

    operations = [
        migrations.RunPython(add_clips_category, migrations.RunPython.noop),
    ]
