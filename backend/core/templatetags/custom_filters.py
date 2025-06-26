from django import template
from django.urls import reverse
from django.contrib.auth.models import User
from django.utils.safestring import mark_safe
from django.utils.translation import gettext, gettext_lazy as _, get_language
from functools import lru_cache
from googletrans import Translator

_translator = Translator(service_urls=["translate.googleapis.com"])
# googletrans 4.0.0rc1 uses `raise_Exception` internally; ensure it's present
setattr(_translator, "raise_Exception", getattr(_translator, "raise_exception", False))


@lru_cache(maxsize=1024)
def _google_translate(text, dest):
    """Translate text using Google Translate with caching."""
    return _translator.translate(text, dest=dest).text


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
    "puta",
    "mierda",
    "imbecil",
    "idiota",
    "tonto",
    "cabron",
    "pendejo",
    "marica",
    "perra",
]

# Basic offline translations for common profile fields
OFFLINE_TRANSLATIONS = {
    # Genders
    "Hombre": _("Male"),
    "Mujer": _("Female"),
    "Otro": _("Other"),
    "Male": _("Male"),
    "Female": _("Female"),
    "Other": _("Other"),
    # Categories
    "Entrantes": _("Starters"),
    "Primer plato": _("First course"),
    "Segundo plato": _("Second course"),
    "Postres": _("Desserts"),
    "Starters": _("Starters"),
    "First course": _("First course"),
    "Second course": _("Second course"),
    "Desserts": _("Desserts"),
}


@register.filter
def censor_bad_words(text):
    """Replace offensive words with asterisks."""
    if not text:
        return ""
    pattern = re.compile(r"(?i)\b(" + "|".join(map(re.escape, BAD_WORDS)) + r")\b")
    return pattern.sub(lambda m: "*" * len(m.group(0)), text)


@register.filter
def translate(value):
    """Translate a dynamic string using gettext or fallback to Google Translate."""
    if value is None:
        return ""

    value = str(value)
    lang = get_language() or "en"
    translated = gettext(value)

    if translated == value:
        # Try offline dictionary before falling back to Google Translate
        if value in OFFLINE_TRANSLATIONS:
            translated = OFFLINE_TRANSLATIONS[value]
        else:
            try:
                translated = _google_translate(value, lang)
            except Exception:
                pass

    return translated
