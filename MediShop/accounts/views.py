# accounts/views.py
from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from .models import Utilisateur, Client, Pharmacie, Livreur
from .serializers import UtilisateurBaseSerializer, ClientSerializer, PharmacieSerializer, LivreurSerializer
from .permissions import IsClient, IsPharmacie, IsLivreur # ASSUREZ-VOUS QUE CE CHEMIN EST CORRECT


# --- Utilisateur CRUD / Profil (Pour Admin et Utilisateur lui-même) ---
class UtilisateurViewSet(viewsets.ModelViewSet):
    serializer_class = UtilisateurBaseSerializer
    queryset = Utilisateur.objects.all()

    def get_permissions(self):
        if self.action == 'create':  # inscription publique
            return [permissions.AllowAny()]
        if self.action in ['retrieve', 'update', 'partial_update','me']:
            return [permissions.IsAuthenticated()]
        return [permissions.IsAdminUser()]

    def get_queryset(self):
        user = self.request.user
        if user.is_staff:
            return Utilisateur.objects.all()
        return Utilisateur.objects.filter(pk=user.pk)

    @action(detail=False, methods=['get'], permission_classes=[IsAuthenticated])
    def me(self, request):
        serializer = self.get_serializer(request.user)
        return Response(serializer.data)

class ClientViewSet(viewsets.ReadOnlyModelViewSet):
    """Affiche uniquement le profil client de l'utilisateur connecté."""
    serializer_class = ClientSerializer
    # Le profil client ne devrait être accessible qu'aux utilisateurs de type Client
    permission_classes = [IsClient]

    def get_queryset(self):
        return Client.objects.filter(utilisateur=self.request.user)

    @action(detail=False, methods=['get'])
    def me(self, request):
        client = self.get_queryset().first()
        if client:
            serializer = self.get_serializer(client)
            return Response(serializer.data)
        return Response({"detail": "Client non trouvé."}, status=status.HTTP_404_NOT_FOUND)


class PharmacieViewSet(viewsets.ReadOnlyModelViewSet):
    """Affiche uniquement le profil pharmacie de l'utilisateur connecté."""
    serializer_class = PharmacieSerializer
    permission_classes = [IsPharmacie]

    def get_queryset(self):
        # Retourne uniquement la pharmacie liée à l'utilisateur connecté
        return Pharmacie.objects.filter(utilisateur=self.request.user)

    # GET /api/pharmacies/my/
    @action(detail=False, methods=['get'], url_path='my')
    def my_pharmacies(self, request):
        queryset = self.get_queryset()
        serializer = self.get_serializer(queryset, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

    # POST /api/pharmacies/create/
    @action(detail=False, methods=['post'], url_path='create',permission_classes=[IsAuthenticated])
    def create_pharmacie(self, request):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        # Assigne automatiquement l'utilisateur connecté
        serializer.save(utilisateur=request.user)
        return Response(serializer.data, status=status.HTTP_201_CREATED)

class LivreurViewSet(viewsets.ReadOnlyModelViewSet):
    """Affiche uniquement le profil livreur de l'utilisateur connecté."""
    serializer_class = LivreurSerializer
    permission_classes = [IsLivreur]

    def get_queryset(self):
        # Filtre simple et direct : ne retourne que le Livreur lié à l'Utilisateur connecté
        return Livreur.objects.filter(utilisateur=self.request.user)