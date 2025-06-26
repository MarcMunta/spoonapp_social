from django import template
from django.urls import reverse
from django.contrib.auth.models import User
from django.utils.safestring import mark_safe
from django.utils.translation import gettext, get_language
from googletrans import Translator

_translator = Translator()
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

# Simple text moderation filter replacing offensive words with asterisks
BAD_WORDS = [
    'puta', 'mierda', 'imbecil', 'idiota', 'tonto',
    'cabron', 'pendejo', 'marica', 'perra'
]

@register.filter
def censor_bad_words(text):
    """Replace offensive words with asterisks."""
    if not text:
        return ''
    pattern = re.compile(r'(?i)\b(' + '|'.join(map(re.escape, BAD_WORDS)) + r')\b')
    return pattern.sub(lambda m: '*' * len(m.group(0)), text)


@register.filter
def translate(value):
    """Translate a dynamic string using gettext or fallback to Google Translate."""
    if value is None:
        return ''

    value = str(value)
    translated = gettext(value)

    if translated == value:
        try:
            translated = _translator.translate(value, dest=get_language() or 'en').text
        except Exception:
            pass

    return translated
