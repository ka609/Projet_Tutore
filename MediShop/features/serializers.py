from rest_framework import serializers
from accounts.models import Utilisateur
from .models import Notification, JournalActivite, ParametreUtilisateur


class NotificationSerializer(serializers.ModelSerializer):
    utilisateur_cible = serializers.StringRelatedField(read_only=True)

    class Meta:
        model = Notification
        fields = ['id', 'utilisateur_cible', 'message', 'type_notification', 'est_lue', 'date_envoi']


class JournalActiviteSerializer(serializers.ModelSerializer):
    utilisateur = serializers.StringRelatedField(read_only=True)

    class Meta:
        model = JournalActivite
        fields = ['id', 'utilisateur', 'action_faite', 'details', 'date_action']


class ParametreUtilisateurSerializer(serializers.ModelSerializer):
    utilisateur = serializers.StringRelatedField(read_only=True)

    class Meta:
        model = ParametreUtilisateur
        fields = ['id', 'utilisateur', 'cle_parametre', 'valeur_parametre']
