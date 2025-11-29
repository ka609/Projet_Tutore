from rest_framework import serializers
from .models import Utilisateur, Client, Pharmacie, Livreur


# --- Serializer pour l'utilisateur de base ---
class UtilisateurBaseSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, required=False)

    class Meta:
        model = Utilisateur
        fields = [
            'id',
            'email',
            'nom',
            'prenom',
            'telephone',
            'adresse',
            'type_utilisateur',
            'password',
            'is_active',
            'is_staff',
            'is_superuser',
            'date_creation'
        ]
        read_only_fields = ['id', 'date_creation']

    def create(self, validated_data):
        password = validated_data.pop('password', None)

        # 🔥 IMPORTANT : créer un user correctement
        user = Utilisateur.objects.create_user(
            email=validated_data.get("email"),
            username=validated_data.get("email"),  # éviter username = None
            nom=validated_data.get("nom"),
            prenom=validated_data.get("prenom"),
            telephone=validated_data.get("telephone"),
            adresse=validated_data.get("adresse"),
            type_utilisateur=validated_data.get("type_utilisateur"),
        )

        if password:
            user.set_password(password)
            user.save()

        return user

    def update(self, instance, validated_data):
        password = validated_data.pop('password', None)

        for attr, value in validated_data.items():
            setattr(instance, attr, value)

        if password:
            instance.set_password(password)

        instance.save()
        return instance

# --- Serializers pour les rôles spécifiques ---
class ClientSerializer(serializers.ModelSerializer):
    utilisateur = UtilisateurBaseSerializer(read_only=True)

    class Meta:
        model = Client
        fields = ['id', 'utilisateur']


class PharmacieSerializer(serializers.ModelSerializer):
    utilisateur = UtilisateurBaseSerializer(read_only=True)

    class Meta:
        model = Pharmacie
        fields = ['id', 'utilisateur', 'nom_pharmacie', 'licence_numero', 'latitude', 'longitude']


class LivreurSerializer(serializers.ModelSerializer):
    utilisateur = UtilisateurBaseSerializer(read_only=True)

    class Meta:
        model = Livreur
        fields = ['id', 'utilisateur', 'statut_disponibilite', 'vehicule_type']
