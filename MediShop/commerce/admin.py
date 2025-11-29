from django.contrib import admin
from .models import (
    Medicament, Symptome, MedicamentSymptome, Stock,
    Prescription, Panier, PanierArticle, Commande,
    LigneCommande, Paiement
)


@admin.register(Medicament)
class MedicamentAdmin(admin.ModelAdmin):
    list_display = ('id', 'nom_commercial', 'categorie', 'necessite_prescription','photo','prix')
    search_fields = ('nom_commercial', 'nom_scientifique', 'categorie')


@admin.register(Symptome)
class SymptomeAdmin(admin.ModelAdmin):
    list_display = ('id', 'nom_symptome')
    search_fields = ('nom_symptome',)


@admin.register(MedicamentSymptome)
class MedicamentSymptomeAdmin(admin.ModelAdmin):
    list_display = ('id', 'medicament', 'symptome')
    search_fields = ('medicament__nom_commercial', 'symptome__nom_symptome')


@admin.register(Stock)
class StockAdmin(admin.ModelAdmin):
    list_display = ('id', 'pharmacie', 'medicament', 'quantite', 'prix_unitaire')
    list_filter = ('pharmacie',)
    search_fields = ('medicament__nom_commercial',)


@admin.register(Prescription)
class PrescriptionAdmin(admin.ModelAdmin):
    list_display = ('id', 'client', 'pharmacie', 'statut_validation', 'date_telechargement')
    list_filter = ('statut_validation', 'pharmacie')
    search_fields = ('client__utilisateur__nom',)


@admin.register(Panier)
class PanierAdmin(admin.ModelAdmin):
    list_display = ('id', 'client', 'date_creation', 'date_derniere_maj')
    search_fields = ('client__utilisateur__nom',)


@admin.register(PanierArticle)
class PanierArticleAdmin(admin.ModelAdmin):
    list_display = ('id', 'panier', 'medicament', 'quantite')
    search_fields = ('medicament__nom_commercial',)


@admin.register(Commande)
class CommandeAdmin(admin.ModelAdmin):
    list_display = ('id', 'client', 'pharmacie', 'livreur', 'statut_commande', 'total_montant', 'date_commande')
    list_filter = ('statut_commande',)
    search_fields = ('client__utilisateur__nom', 'pharmacie__nom_pharmacie')


@admin.register(LigneCommande)
class LigneCommandeAdmin(admin.ModelAdmin):
    list_display = ('id', 'commande', 'medicament', 'quantite_commandee', 'prix_vente')
    search_fields = ('medicament__nom_commercial',)


@admin.register(Paiement)
class PaiementAdmin(admin.ModelAdmin):
    list_display = ('id', 'commande', 'methode_paiement', 'montant', 'statut_paiement', 'date_paiement')
    list_filter = ('statut_paiement',)
