from django.db import migrations
from django.utils.text import slugify


def populate_slugs(apps, schema_editor):
    PostCategory = apps.get_model('social', 'PostCategory')
    for category in PostCategory.objects.filter(slug__isnull=True):
        category.slug = slugify(category.name)
        category.save()


class Migration(migrations.Migration):
    dependencies = [
        ("social", "0019_merge_0017_merge_20250616_1658_0018_message_story"),
    ]

    operations = [
        migrations.RunPython(populate_slugs, migrations.RunPython.noop)
    ]
