from django.core.management.base import BaseCommand
from django.utils import timezone
from core.models import Story

class Command(BaseCommand):
    help = "Delete stories older than their expiration time"

    def handle(self, *args, **options):
        expired = Story.objects.filter(expires_at__lte=timezone.now())
        count = expired.count()
        expired.delete()
        self.stdout.write(self.style.SUCCESS(f"Deleted {count} expired stories"))
