from django.db import migrations, models
import core.models

class Migration(migrations.Migration):

    dependencies = [
        ('social', '0030_post_video_post_video_mime'),
    ]

    operations = [
        migrations.AddField(
            model_name='story',
            name='image',
            field=models.ImageField(blank=True, null=True, upload_to=core.models.story_upload_path),
        ),
        migrations.AddField(
            model_name='story',
            name='is_active',
            field=models.BooleanField(default=True),
        ),
    ]
