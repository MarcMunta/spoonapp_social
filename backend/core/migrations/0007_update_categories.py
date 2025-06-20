from django.db import migrations


def update_categories(apps, schema_editor):
    PostCategory = apps.get_model('social', 'PostCategory')
    # Remove outdated categories
    to_remove = ['Verduras', 'Pasta', 'Carne', 'Pescado']
    PostCategory.objects.filter(name__in=to_remove).delete()

    # Ensure desired categories exist
    to_add = ['Entrantes', 'Primer plato', 'Segundo plato', 'Postres']
    for name in to_add:
        PostCategory.objects.get_or_create(name=name)


class Migration(migrations.Migration):

    dependencies = [
        ('social', '0006_postcommentlike'),
    ]

    operations = [
        migrations.RunPython(update_categories, migrations.RunPython.noop),
    ]
