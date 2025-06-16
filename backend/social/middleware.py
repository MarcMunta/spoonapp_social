from django.utils import timezone
from django.conf import settings

class UpdateLastSeenMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        if request.user.is_authenticated:
            try:
                profile = request.user.profile
                # Usa il fuso orario configurato in Django
                current_time = timezone.now()
                profile.last_seen = current_time
                # Considera l'utente online se è attivo negli ultimi 5 minuti
                profile.online = True
                profile.save(update_fields=["last_seen", "online"])
            except Exception as e:
                # Log l'errore se necessario, ma non interrompere la richiesta
                pass
        
        response = self.get_response(request)
        return response