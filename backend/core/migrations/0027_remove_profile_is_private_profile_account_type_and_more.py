# Generated by Django 5.2.3 on 2025-06-30 12:12

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ("social", "0026_profile_email_notifications_and_more"),
    ]

    operations = [
        migrations.RemoveField(
            model_name="profile",
            name="is_private",
        ),
        migrations.AddField(
            model_name="profile",
            name="account_type",
            field=models.CharField(
                choices=[("individual", "Individual"), ("community", "Comunidad")],
                default="individual",
                max_length=20,
            ),
        ),
        migrations.DeleteModel(
            name="Follow",
        ),
    ]
