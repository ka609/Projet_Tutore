from django.db import models
from accounts.models import Utilisateur

class Notification(models.Model):
    utilisateur_cible = models.ForeignKey(Utilisateur, on_delete=models.CASCADE)
    message = models.TextField()
    type_notification = models.CharField(max_length=50, blank=True, null=True)
    est_lue = models.BooleanField(default=False)
    date_envoi = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Notif. #{self.id} pour {self.utilisateur_cible.nom}"


class JournalActivite(models.Model):
    utilisateur = models.ForeignKey(Utilisateur, on_delete=models.SET_NULL, null=True, blank=True)
    action_faite = models.CharField(max_length=100)
    details = models.TextField(blank=True, null=True)
    date_action = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name_plural = "Journal des Activités"

    def __str__(self):
        user_name = self.utilisateur.nom if self.utilisateur else "Utilisateur Supprimé"
        return f"[{user_name}] {self.action_faite}"


class ParametreUtilisateur(models.Model):
    utilisateur = models.ForeignKey(Utilisateur, on_delete=models.CASCADE)
    cle_parametre = models.CharField(max_length=100)
    valeur_parametre = models.TextField()

    class Meta:
        unique_together = (('utilisateur', 'cle_parametre'),)
        verbose_name_plural = "Paramètres Utilisateurs"

    def __str__(self):
        return f"{self.cle_parametre} pour {self.utilisateur.nom}"
