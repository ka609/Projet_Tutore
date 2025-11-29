from rest_framework import viewsets, permissions, mixins, status
from rest_framework.response import Response
from rest_framework.decorators import action
from django.db import transaction  # Pour garantir l'intégrité des opérations stock/commande
from django.shortcuts import get_object_or_404

from .models import (
    Medicament, Symptome, MedicamentSymptome,
    Stock, Prescription, Panier, PanierArticle,
    Commande, LigneCommande, Paiement
)
from .serializers import (
    MedicamentSerializer, SymptomeSerializer, MedicamentSymptomeSerializer,
    StockSerializer, PrescriptionSerializer, PanierSerializer, PanierArticleSerializer,
    CommandeSerializer, LigneCommandeSerializer, PaiementSerializer
)

# IMPORTER LES PERMISSIONS PERSONNALISÉES (Assurez-vous qu'elles existent dans accounts/permissions.py)
from accounts.permissions import IsClient, IsPharmacie, IsLivreur
from accounts.models import Pharmacie  # Importé pour la recherche de stock


# --- 1. Catalogue / Recherche ---

class MedicamentViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Medicament.objects.all()
    serializer_class = MedicamentSerializer
    permission_classes = [permissions.IsAuthenticated]


class SymptomeViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Symptome.objects.all()
    serializer_class = SymptomeSerializer
    permission_classes = [permissions.IsAuthenticated]


class MedicamentSymptomeViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = MedicamentSymptome.objects.all()
    serializer_class = MedicamentSymptomeSerializer
    permission_classes = [permissions.IsAuthenticated]


# --- 2. Stock / Inventaire ---

class StockViewSet(viewsets.ModelViewSet):
    queryset = Stock.objects.all()
    serializer_class = StockSerializer
    # Seules les Pharmacies et les Administrateurs peuvent gérer le stock
    permission_classes = [IsPharmacie | permissions.IsAdminUser]

    # Filtrer pour que la pharmacie ne voie que son propre stock
    def get_queryset(self):
        user = self.request.user
        if hasattr(user, 'pharmacie'):
            return Stock.objects.filter(pharmacie=user.pharmacie)
        # Permet aux admins de tout voir
        return super().get_queryset()

    @action(detail=False, methods=['get'], permission_classes=[permissions.AllowAny])
    def available(self, request):
        stocks = Stock.objects.filter(quantite__gt=0)
        serializer = self.get_serializer(stocks, many=True)
        return Response(serializer.data)

# --- 3. Prescriptions ---

class PrescriptionViewSet(viewsets.ModelViewSet):
    queryset = Prescription.objects.all()
    # Seuls les Clients créent/lisent, les Pharmacies lisent/mettent à jour le statut
    permission_classes = [IsClient | IsPharmacie]

    # Logique de filtrage par client ou par pharmacie
    def get_queryset(self):
        user = self.request.user
        if hasattr(user, 'client'):
            return Prescription.objects.filter(client=user.client)
        if hasattr(user, 'pharmacie'):
            return Prescription.objects.filter(pharmacie=user.pharmacie)
        return Prescription.objects.none()


# --- 4. Panier et Articles (Logique Client) ---

class PanierViewSet(viewsets.GenericViewSet,
                    mixins.RetrieveModelMixin,
                    mixins.DestroyModelMixin):  # DELETE pour vider le panier
    """Gestion du panier actif du client."""
    serializer_class = PanierSerializer
    # Seuls les clients peuvent manipuler le panier
    permission_classes = [IsClient]

    def get_object(self):
        # Récupère ou crée le panier actif du client
        user = self.request.user
        panier, created = Panier.objects.get_or_create(client=user.client)
        return panier

    # Endpoint GET /api/panier/me/ (implémenté via mixins.RetrieveModelMixin ou action)
    def retrieve(self, request, pk=None):
        """Récupère le panier actif."""
        return self.me(request)

    @action(detail=False, methods=['get'])
    def me(self, request):
        panier = self.get_object()
        serializer = self.get_serializer(panier)
        return Response(serializer.data)

    # Endpoint DELETE /api/panier/{id}/ (vide le panier)
    def destroy(self, request, pk=None):
        panier = self.get_object()
        # Supprime tous les articles du panier
        panier.panierarticle_set.all().delete()
        return Response(status=status.HTTP_204_NO_CONTENT)

    # Endpoint POST /api/panier/add_item/
    @action(detail=False, methods=['post'], serializer_class=PanierArticleSerializer)
    def add_item(self, request):
        """Ajouter/modifier un article dans le panier (nécessite medicament_id et quantite)."""
        panier = self.get_object()
        # Utiliser un serializer temporaire pour la validation des données d'entrée
        temp_serializer = PanierArticleSerializer(data=request.data)
        temp_serializer.is_valid(raise_exception=True)

        medicament_id = temp_serializer.validated_data['medicament'].id
        quantite = temp_serializer.validated_data['quantite']

        try:
            # Tente de trouver l'article existant
            article = PanierArticle.objects.get(panier=panier, medicament__id=medicament_id)
            article.quantite = quantite
            article.save()
        except PanierArticle.DoesNotExist:
            # Crée un nouvel article
            article = PanierArticle.objects.create(
                panier=panier,
                medicament_id=medicament_id,
                quantite=quantite
            )

        return Response(PanierArticleSerializer(article).data, status=status.HTTP_200_OK)


class PanierArticleViewSet(viewsets.ModelViewSet):
    queryset = PanierArticle.objects.all()
    serializer_class = PanierArticleSerializer
    permission_classes = [IsClient]

    # Filtrer pour ne voir que ses propres articles de panier
    def get_queryset(self):
        user = self.request.user
        if hasattr(user, 'client'):
            return PanierArticle.objects.filter(panier__client=user.client)
        return PanierArticle.objects.none()


# --- 5. Commandes et Lignes de Commande (Logique Métier) ---

class CommandeViewSet(viewsets.GenericViewSet,
                      mixins.ListModelMixin,
                      mixins.RetrieveModelMixin,
                      mixins.UpdateModelMixin):
    """Gère la création, la consultation et la mise à jour de statut des commandes."""
    serializer_class = CommandeSerializer
    permission_classes = [IsClient | IsPharmacie | IsLivreur]

    def get_queryset(self):
        # Filtrer les commandes selon le rôle de l'utilisateur connecté
        user = self.request.user
        if hasattr(user, 'client'):
            return Commande.objects.filter(client=user.client).order_by('-date_commande')
        if hasattr(user, 'pharmacie'):
            return Commande.objects.filter(pharmacie=user.pharmacie).order_by('-date_commande')
        if hasattr(user, 'livreur'):
            return Commande.objects.filter(livreur=user.livreur).order_by('-date_commande')
        return Commande.objects.none()

    # Logique de création de commande (POST)
    @transaction.atomic
    def create(self, request, *args, **kwargs):
        """Crée une commande à partir du panier actif."""
        user = request.user
        if not hasattr(user, 'client'):
            return Response({"detail": "Seuls les clients peuvent créer une commande."},
                            status=status.HTTP_403_FORBIDDEN)

        client = user.client
        panier = get_object_or_404(Panier, client=client)
        articles = panier.panierarticle_set.all()

        if not articles.exists():
            return Response({"detail": "Le panier est vide."}, status=status.HTTP_400_BAD_REQUEST)

        # 1. Validation de l'adresse (peut être fournie dans le corps de la requête)
        adresse_livraison = request.data.get('adresse_livraison', client.utilisateur.adresse)
        if not adresse_livraison:
            return Response({"detail": "L'adresse de livraison est requise."}, status=status.HTTP_400_BAD_REQUEST)

        # 2. Sélection de la pharmacie et vérification du stock
        pharmacies_avec_stock = Pharmacie.objects.filter(stock__medicament__in=articles.values('medicament'),
                                                         stock__quantite__gt=0).distinct()

        # Logique de sélection (simplifiée : prend la première éligible qui couvre le panier entier)
        pharmacie_selectionnee = None
        for pharmacie in pharmacies_avec_stock:
            stock_suffisant = True
            for article in articles:
                try:
                    stock = Stock.objects.get(pharmacie=pharmacie, medicament=article.medicament)
                    if stock.quantite < article.quantite:
                        stock_suffisant = False
                        break
                except Stock.DoesNotExist:
                    stock_suffisant = False
                    break

            if stock_suffisant:
                pharmacie_selectionnee = pharmacie
                break

        if not pharmacie_selectionnee:
            return Response({"detail": "Aucune pharmacie n'a le stock complet pour cette commande."},
                            status=status.HTTP_404_NOT_FOUND)

        # 3. Création de la Commande
        total_montant = 0
        commande = Commande.objects.create(
            client=client,
            pharmacie=pharmacie_selectionnee,
            statut_commande='EN_ATTENTE',
            adresse_livraison=adresse_livraison,
            total_montant=0.00
        )

        # 4. Transfert vers Lignes de Commande et Mise à jour du Stock
        for article in articles:
            stock = Stock.objects.select_for_update().get(pharmacie=pharmacie_selectionnee,
                                                          medicament=article.medicament)

            prix_vente = stock.prix_unitaire
            montant_ligne = prix_vente * article.quantite
            total_montant += montant_ligne

            LigneCommande.objects.create(
                commande=commande,
                medicament=article.medicament,
                quantite_commandee=article.quantite,
                prix_vente=prix_vente
            )

            # Décrémentation du stock
            stock.quantite -= article.quantite
            stock.save()

        # 5. Finalisation du Total et Vidage du Panier
        commande.total_montant = total_montant
        commande.save()

        articles.delete()

        serializer = self.get_serializer(commande)
        return Response(serializer.data, status=status.HTTP_201_CREATED)

    # Logique de mise à jour de statut (PATCH/PUT)
    def update(self, request, *args, **kwargs):
        """Permet la mise à jour du statut par la Pharmacie (PREPARATION) ou le Livreur (LIVRAISON/LIVREE)."""
        instance = self.get_object()
        user = request.user
        nouveau_statut = request.data.get('statut_commande')

        # Si c'est un client, il ne peut qu'annuler (logique non implémentée ici, mais possible)
        # Si c'est un admin, il peut tout faire (implémenté via la permission DRF)

        if hasattr(user, 'pharmacie') and user.pharmacie == instance.pharmacie:
            # Pharmacie ne peut passer qu'à EN_PREPARATION ou assigner un Livreur
            if nouveau_statut == 'EN_PREPARATION' or 'livreur' in request.data:
                return super().update(request, *args, **kwargs)
            else:
                return Response({"detail": "La pharmacie ne peut que préparer la commande ou assigner un livreur."},
                                status=status.HTTP_403_FORBIDDEN)

        elif hasattr(user, 'livreur') and user.livreur == instance.livreur:
            # Livreur ne peut passer qu'à EN_LIVRAISON ou LIVREE
            if nouveau_statut in ['EN_LIVRAISON', 'LIVREE']:
                return super().update(request, *args, **kwargs)
            else:
                return Response({"detail": "Le livreur ne peut mettre à jour le statut qu'à EN_LIVRAISON ou LIVREE."},
                                status=status.HTTP_403_FORBIDDEN)

        return Response({"detail": "Vous n'avez pas la permission de modifier cette commande."},
                        status=status.HTTP_403_FORBIDDEN)


class LigneCommandeViewSet(viewsets.ModelViewSet):
    queryset = LigneCommande.objects.all()
    serializer_class = LigneCommandeSerializer
    # Lecture seule après la création de la commande
    permission_classes = [permissions.IsAuthenticated]

    # Restreindre la visibilité aux commandes de l'utilisateur
    def get_queryset(self):
        user = self.request.user
        if hasattr(user, 'client'):
            return LigneCommande.objects.filter(commande__client=user.client)
        if hasattr(user, 'pharmacie'):
            return LigneCommande.objects.filter(commande__pharmacie=user.pharmacie)
        return LigneCommande.objects.none()


# --- 6. Paiements ---

class PaiementViewSet(viewsets.ModelViewSet):
    queryset = Paiement.objects.all()
    serializer_class = PaiementSerializer
    permission_classes = [permissions.IsAuthenticated]