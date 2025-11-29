from django.db import models
from accounts.models import Client, Pharmacie, Livreur

class Medicament(models.Model):
    nom_commercial = models.CharField(max_length=255)
    nom_scientifique = models.CharField(max_length=255, blank=True, null=True)
    description = models.TextField(blank=True, null=True)
    categorie = models.CharField(max_length=50, blank=True, null=True)
    necessite_prescription = models.BooleanField(default=False)
    photo = models.ImageField(upload_to='medicaments/', blank=True, null=True)
    prix = models.DecimalField(max_digits=10, decimal_places=2, default=0.00)

    def __str__(self):
        return self.nom_commercial


class Symptome(models.Model):
    nom_symptome = models.CharField(max_length=100, unique=True)
    description = models.TextField(blank=True, null=True)

    def __str__(self):
        return self.nom_symptome


class MedicamentSymptome(models.Model):
    medicament = models.ForeignKey(Medicament, on_delete=models.CASCADE)
    symptome = models.ForeignKey(Symptome, on_delete=models.CASCADE)

    class Meta:
        unique_together = (('medicament', 'symptome'),)

    def __str__(self):
        return f"{self.medicament.nom_commercial} - {self.symptome.nom_symptome}"


class Stock(models.Model):
    pharmacie = models.ForeignKey(Pharmacie, on_delete=models.CASCADE)
    medicament = models.ForeignKey(Medicament, on_delete=models.RESTRICT)
    quantite = models.IntegerField(default=0)
    prix_unitaire = models.DecimalField(max_digits=10, decimal_places=2)

    class Meta:
        unique_together = (('pharmacie', 'medicament'),)

    def __str__(self):
        return f"{self.pharmacie.nom_pharmacie}: {self.medicament.nom_commercial} ({self.quantite})"


class Prescription(models.Model):
    STATUT_VALIDATION_CHOICES = [
        ('EN_ATTENTE', 'En Attente'),
        ('VALIDEE', 'Validée'),
        ('REFUSEE', 'Refusée'),
    ]
    client = models.ForeignKey(Client, on_delete=models.RESTRICT)
    pharmacie = models.ForeignKey(Pharmacie, on_delete=models.RESTRICT)
    fichier_url = models.CharField(max_length=255)
    date_telechargement = models.DateTimeField(auto_now_add=True)
    statut_validation = models.CharField(max_length=20, choices=STATUT_VALIDATION_CHOICES)

    def __str__(self):
        return f"Prescription {self.id} pour {self.client.utilisateur.nom}"


class Panier(models.Model):
    client = models.OneToOneField(Client, on_delete=models.CASCADE)
    date_creation = models.DateTimeField(auto_now_add=True)
    date_derniere_maj = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"Panier de {self.client.utilisateur.nom}"


class PanierArticle(models.Model):
    panier = models.ForeignKey(Panier, on_delete=models.CASCADE)
    medicament = models.ForeignKey(Medicament, on_delete=models.RESTRICT)
    quantite = models.PositiveIntegerField()

    class Meta:
        unique_together = (('panier', 'medicament'),)

    def __str__(self):
        return f"{self.quantite} x {self.medicament.nom_commercial} dans {self.panier}"


class Commande(models.Model):
    STATUT_COMMANDE_CHOICES = [
        ('EN_ATTENTE', 'En Attente'),
        ('EN_PREPARATION', 'En Préparation'),
        ('EN_LIVRAISON', 'En Livraison'),
        ('LIVREE', 'Livrée'),
        ('ANNULEE', 'Annulée'),
    ]
    client = models.ForeignKey(Client, on_delete=models.RESTRICT)
    pharmacie = models.ForeignKey(Pharmacie, on_delete=models.RESTRICT)
    livreur = models.ForeignKey(Livreur, on_delete=models.SET_NULL, null=True, blank=True)
    date_commande = models.DateTimeField(auto_now_add=True)
    statut_commande = models.CharField(max_length=20, choices=STATUT_COMMANDE_CHOICES)
    total_montant = models.DecimalField(max_digits=10, decimal_places=2)
    adresse_livraison = models.CharField(max_length=255)

    def __str__(self):
        return f"Commande #{self.id} - Statut: {self.statut_commande}"


class LigneCommande(models.Model):
    commande = models.ForeignKey(Commande, on_delete=models.CASCADE)
    medicament = models.ForeignKey(Medicament, on_delete=models.RESTRICT)
    quantite_commandee = models.PositiveIntegerField()
    prix_vente = models.DecimalField(max_digits=10, decimal_places=2)

    class Meta:
        unique_together = (('commande', 'medicament'),)

    def __str__(self):
        return f"Ligne {self.id} de Commande #{self.commande.id}"


class Paiement(models.Model):
    STATUT_PAIEMENT_CHOICES = [
        ('SUCCES', 'Succès'),
        ('ECHEC', 'Échec'),
        ('EN_COURS', 'En Cours'),
    ]
    commande = models.OneToOneField(Commande, on_delete=models.CASCADE)
    methode_paiement = models.CharField(max_length=50)
    montant = models.DecimalField(max_digits=10, decimal_places=2)
    statut_paiement = models.CharField(max_length=20, choices=STATUT_PAIEMENT_CHOICES)
    reference_transaction = models.CharField(max_length=100, blank=True, null=True)
    date_paiement = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Paiement #{self.id} pour Commande #{self.commande.id}"
