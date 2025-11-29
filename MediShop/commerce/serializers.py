from rest_framework import serializers
from accounts.models import Client, Pharmacie, Livreur
from .models import (
    Medicament, Symptome, MedicamentSymptome, Stock,
    Prescription, Panier, PanierArticle, Commande,
    LigneCommande, Paiement
)


# --- Catalogue / Stock ---
class MedicamentSerializer(serializers.ModelSerializer):
    class Meta:
        model = Medicament
        fields = ['id', 'nom_commercial', 'nom_scientifique', 'description', 'categorie', 'necessite_prescription','prix']


class SymptomeSerializer(serializers.ModelSerializer):
    class Meta:
        model = Symptome
        fields = ['id', 'nom_symptome', 'description']


class MedicamentSymptomeSerializer(serializers.ModelSerializer):
    medicament = MedicamentSerializer(read_only=True)
    symptome = SymptomeSerializer(read_only=True)

    class Meta:
        model = MedicamentSymptome
        fields = ['id', 'medicament', 'symptome']


class StockSerializer(serializers.ModelSerializer):
    medicament = MedicamentSerializer(read_only=True)
    pharmacie = serializers.StringRelatedField(read_only=True)

    class Meta:
        model = Stock
        fields = ['id', 'pharmacie', 'medicament', 'quantite', 'prix_unitaire']


# --- Prescription ---
class PrescriptionSerializer(serializers.ModelSerializer):
    client = serializers.StringRelatedField(read_only=True)
    pharmacie = serializers.StringRelatedField(read_only=True)

    class Meta:
        model = Prescription
        fields = ['id', 'client', 'pharmacie', 'fichier_url', 'date_telechargement', 'statut_validation']


# --- Panier / Commande ---
class PanierArticleSerializer(serializers.ModelSerializer):
    medicament = MedicamentSerializer(read_only=True)

    class Meta:
        model = PanierArticle
        fields = ['id', 'panier', 'medicament', 'quantite']


class PanierSerializer(serializers.ModelSerializer):
    client = serializers.StringRelatedField(read_only=True)
    articles = PanierArticleSerializer(many=True, source='panierarticle_set', read_only=True)

    class Meta:
        model = Panier
        fields = ['id', 'client', 'date_creation', 'date_derniere_maj', 'articles']


class LigneCommandeSerializer(serializers.ModelSerializer):
    medicament = MedicamentSerializer(read_only=True)

    class Meta:
        model = LigneCommande
        fields = ['id', 'commande', 'medicament', 'quantite_commandee', 'prix_vente']


class CommandeSerializer(serializers.ModelSerializer):
    client = serializers.StringRelatedField(read_only=True)
    pharmacie = serializers.StringRelatedField(read_only=True)
    livreur = serializers.StringRelatedField(read_only=True)
    lignes = LigneCommandeSerializer(many=True, source='lignecommande_set', read_only=True)

    class Meta:
        model = Commande
        fields = [
            'id', 'client', 'pharmacie', 'livreur',
            'date_commande', 'statut_commande', 'total_montant',
            'adresse_livraison', 'lignes'
        ]


class PaiementSerializer(serializers.ModelSerializer):
    commande = serializers.StringRelatedField(read_only=True)

    class Meta:
        model = Paiement
        fields = ['id', 'commande', 'methode_paiement', 'montant', 'statut_paiement', 'reference_transaction', 'date_paiement']
