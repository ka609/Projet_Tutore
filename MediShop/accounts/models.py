from django.db import models
from django.contrib.auth.models import AbstractUser


class Utilisateur(AbstractUser):
    TYPE_UTILISATEUR_CHOICES = [
        ('CLIENT', 'Client'),
        ('PHARMACIE', 'Pharmacie'),
        ('LIVREUR', 'Livreur'),
    ]

    # Remplacer username par email comme identifiant unique
    email = models.EmailField(unique=True)
    username = models.CharField(max_length=150, blank=True, null=True)

    nom = models.CharField(max_length=100)
    prenom = models.CharField(max_length=100)
    telephone = models.CharField(max_length=20, blank=True, null=True)
    adresse = models.CharField(max_length=255, blank=True, null=True)
    type_utilisateur = models.CharField(max_length=10, choices=TYPE_UTILISATEUR_CHOICES)
    date_creation = models.DateTimeField(auto_now_add=True)
    photo = models.ImageField(upload_to='utilisateurs/', blank=True, null=True)

    USERNAME_FIELD = "email"
    REQUIRED_FIELDS = [ "nom", "prenom"]

    def __str__(self):
        return f"{self.prenom} {self.nom} ({self.type_utilisateur})"


# --- Rôles Spécifiques ---

class Client(models.Model):
    utilisateur = models.OneToOneField(Utilisateur, on_delete=models.CASCADE)

    def __str__(self):
        return f"Client: {self.utilisateur.nom}"


class Pharmacie(models.Model):
    utilisateur = models.OneToOneField(Utilisateur, on_delete=models.CASCADE)
    nom_pharmacie = models.CharField(max_length=255)
    licence_numero = models.CharField(max_length=50, unique=True)
    latitude = models.DecimalField(max_digits=9, decimal_places=6, blank=True, null=True)
    longitude = models.DecimalField(max_digits=9, decimal_places=6, blank=True, null=True)

    def __str__(self):
        return self.nom_pharmacie


class Livreur(models.Model):
    utilisateur = models.OneToOneField(Utilisateur, on_delete=models.CASCADE)

    STATUT_DISPONIBILITE_CHOICES = [
        ('DISPONIBLE', 'Disponible'),
        ('INDISPONIBLE', 'Indisponible'),
        ('EN_COURSE', 'En Course'),
    ]
    statut_disponibilite = models.CharField(max_length=20, choices=STATUT_DISPONIBILITE_CHOICES, default='INDISPONIBLE')
    vehicule_type = models.CharField(max_length=50, blank=True, null=True)

    def __str__(self):
        return f"Livreur: {self.utilisateur.nom}"
