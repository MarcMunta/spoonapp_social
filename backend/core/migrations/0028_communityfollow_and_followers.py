from django.db import migrations, models
import django.db.models.deletion
from django.conf import settings

class Migration(migrations.Migration):

    dependencies = [
        ("social", "0027_remove_profile_is_private_profile_account_type_and_more"),
    ]

    operations = [
        migrations.CreateModel(
            name="CommunityFollow",
            fields=[
                ("id", models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name="ID")),
                ("created_at", models.DateTimeField(auto_now_add=True)),
                ("community", models.ForeignKey(limit_choices_to={'profile__account_type': 'community'}, on_delete=django.db.models.deletion.CASCADE, related_name="community_followers", to=settings.AUTH_USER_MODEL)),
                ("user", models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to=settings.AUTH_USER_MODEL)),
            ],
            options={
                "unique_together": {("user", "community")},
            },
        ),
        migrations.AddField(
            model_name="profile",
            name="followers",
            field=models.PositiveIntegerField(default=0),
        ),
        migrations.AddField(
            model_name="notification",
            name="target_url",
            field=models.CharField(max_length=200, null=True, blank=True),
        ),
        migrations.AlterField(
            model_name="notification",
            name="notification_type",
            field=models.CharField(
                max_length=20,
                choices=[
                    ("message", "New Message"),
                    ("friend_request", "Friend Request"),
                    ("friend_accepted", "Friend Request Accepted"),
                    ("community_post", "Community Post"),
                ],
            ),
        ),
    ]
