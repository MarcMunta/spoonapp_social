from django import template
from django.urls import reverse
from django.contrib.auth.models import User
from django.utils.safestring import mark_safe
import re

register = template.Library()

@register.filter
def get_item(dictionary, key):
    return dictionary.get(key)


MENTION_RE = re.compile(r"@(\w+)")


@register.filter
def link_mentions(text):
    """Convert @username in text to profile links."""

    def repl(match):
        username = match.group(1)
        try:
            User.objects.get(username=username)
        except User.DoesNotExist:
            return match.group(0)
        url = reverse("profile", args=[username])
        return f'<a href="{url}" class="mention">@{username}</a>'

    return mark_safe(MENTION_RE.sub(repl, text))
