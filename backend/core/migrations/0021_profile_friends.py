# Generated by Django 5.2.3 on 2025-06-18 11:58

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('social', '0020_auto_20250618_1015'),
    ]

    operations = [
        migrations.AddField(
            model_name='profile',
            name='friends',
            field=models.ManyToManyField(blank=True, to='social.profile'),
        ),
    ]
