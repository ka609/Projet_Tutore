from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django.shortcuts import get_object_or_404
from django.db.models import Q

from .models import Notification, JournalActivite, ParametreUtilisateur
from .serializers import NotificationSerializer, JournalActiviteSerializer, ParametreUtilisateurSerializer

# IMPORTER LES PERMISSIONS PERSONNALISÉES
# Assurez-vous que le chemin d'importation est correct pour votre structure de projet
from accounts.permissions import IsClient, IsPharmacie, IsLivreur


# --- 1. Gestion des Notifications ---

class NotificationViewSet(viewsets.ReadOnlyModelViewSet):
    """
    Gère les notifications de l'utilisateur. Lecture seule par l'utilisateur cible.
    Les notifications sont créées par la logique métier du backend.
    """
    serializer_class = NotificationSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user

        # Les administrateurs peuvent voir toutes les notifications
        if user.is_staff:
            return Notification.objects.all().order_by('-date_envoi')

        # Les utilisateurs (Client, Pharmacie, Livreur) ne voient que les notifications qui les ciblent
        return Notification.objects.filter(utilisateur_cible=user).order_by('-date_envoi')

    # Endpoint POST /api/notifications/{id}/mark_as_read/
    @action(detail=True, methods=['post'])
    def mark_as_read(self, request, pk=None):
        """Marque une notification spécifique comme lue."""
        # Utilise get_queryset() pour s'assurer que l'utilisateur n'accède qu'à ses propres notifications
        notification = get_object_or_404(self.get_queryset(), pk=pk)

        if not notification.est_lue:
            notification.est_lue = True
            notification.save()
            # On renvoie la notification mise à jour
            return Response(self.get_serializer(notification).data, status=status.HTTP_200_OK)

        return Response({'status': 'Notification déjà lue.'}, status=status.HTTP_200_OK)

    # Endpoint GET /api/notifications/unread_count/
    @action(detail=False, methods=['get'])
    def unread_count(self, request):
        """Compte le nombre de notifications non lues pour l'utilisateur."""
        count = self.get_queryset().filter(est_lue=False).count()
        return Response({'unread_count': count})


# --- 2. Journal d'Activité ---

class JournalActiviteViewSet(viewsets.ReadOnlyModelViewSet):
    """
    Affiche le journal d'activité. Filtré pour l'utilisateur connecté,
    sauf si l'utilisateur est admin (staff).
    """
    serializer_class = JournalActiviteSerializer
    # Seuls les utilisateurs authentifiés peuvent lire le journal
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user

        # Les administrateurs peuvent voir toutes les activités
        if user.is_staff:
            return JournalActivite.objects.all().order_by('-date_action')

        # Les autres utilisateurs ne voient que leurs propres actions
        return JournalActivite.objects.filter(utilisateur=user).order_by('-date_action')


# --- 3. Paramètres Utilisateur ---

class ParametreUtilisateurViewSet(viewsets.ModelViewSet):
    """
    Permet aux utilisateurs de gérer leurs propres paires clé/valeur de paramètres (CRUD).
    """
    serializer_class = ParametreUtilisateurSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user

        # Les administrateurs voient tous les paramètres
        if user.is_staff:
            return ParametreUtilisateur.objects.all()

        # Les utilisateurs ne voient que leurs propres paramètres
        return ParametreUtilisateur.objects.filter(utilisateur=user)

    # Assure que le paramètre créé appartient à l'utilisateur
    def perform_create(self, serializer):
        # Assigne l'utilisateur connecté automatiquement comme utilisateur du paramètre
        serializer.save(utilisateur=self.request.user)

    # La méthode perform_update() est implicitement sécurisée par le filtrage du get_queryset()