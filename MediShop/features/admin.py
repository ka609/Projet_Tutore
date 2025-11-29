from django.contrib import admin
from .models import Notification, JournalActivite, ParametreUtilisateur


@admin.register(Notification)
class NotificationAdmin(admin.ModelAdmin):
    list_display = ('id', 'utilisateur_cible', 'message', 'est_lue', 'date_envoi')
    list_filter = ('est_lue',)
    search_fields = ('utilisateur_cible__nom', 'message')


@admin.register(JournalActivite)
class JournalActiviteAdmin(admin.ModelAdmin):
    list_display = ('id', 'utilisateur', 'action_faite', 'date_action')
    search_fields = ('utilisateur__nom', 'action_faite')


@admin.register(ParametreUtilisateur)
class ParametreUtilisateurAdmin(admin.ModelAdmin):
    list_display = ('id', 'utilisateur', 'cle_parametre', 'valeur_parametre')
    search_fields = ('utilisateur__nom', 'cle_parametre')
