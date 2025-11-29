from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import Utilisateur, Client, Pharmacie, Livreur

# --- 1. Admin pour Utilisateur personnalisé ---
@admin.register(Utilisateur)
class UtilisateurAdmin(UserAdmin):
    model = Utilisateur

    list_display = ('id', 'email', 'nom', 'prenom', 'type_utilisateur', 'is_staff', 'is_active', 'date_creation')
    list_filter = ('type_utilisateur', 'is_staff', 'is_active')
    search_fields = ('email', 'nom', 'prenom', 'telephone')
    ordering = ('-date_creation',)

    fieldsets = (
        (None, {'fields': ('email', 'password')}),
        ('Informations Personnelles', {'fields': ('nom', 'prenom', 'telephone', 'adresse')}),
        ('Rôle et Permissions', {'fields': ('type_utilisateur', 'is_active', 'is_staff', 'is_superuser', 'groups', 'user_permissions')}),
        ('Dates Importantes', {'fields': ('last_login', 'date_creation')}),
    )

    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': ('email', 'nom', 'prenom', 'password1', 'password2', 'type_utilisateur', 'is_active', 'is_staff', 'is_superuser')
        }),
    )

    list_display_links = ('email', 'nom')
    readonly_fields = ('date_creation',)
    REQUIRED_FIELDS = ['nom', 'prenom']


# --- 2. Admin pour les rôles spécifiques ---
@admin.register(Client)
class ClientAdmin(admin.ModelAdmin):
    list_display = ('id', 'get_full_name', 'get_email')
    search_fields = ('utilisateur__nom', 'utilisateur__email')
    raw_id_fields = ('utilisateur',)

    def get_full_name(self, obj):
        return f"{obj.utilisateur.prenom} {obj.utilisateur.nom}"
    get_full_name.short_description = 'Nom complet'

    def get_email(self, obj):
        return obj.utilisateur.email
    get_email.short_description = 'Email'


@admin.register(Pharmacie)
class PharmacieAdmin(admin.ModelAdmin):
    list_display = ('id', 'nom_pharmacie', 'licence_numero', 'get_gerant_name')
    search_fields = ('nom_pharmacie', 'licence_numero', 'utilisateur__nom')
    raw_id_fields = ('utilisateur',)

    def get_gerant_name(self, obj):
        return f"{obj.utilisateur.prenom} {obj.utilisateur.nom}"
    get_gerant_name.short_description = 'Gérant'


@admin.register(Livreur)
class LivreurAdmin(admin.ModelAdmin):
    list_display = ('id', 'get_full_name', 'statut_disponibilite', 'vehicule_type')
    list_filter = ('statut_disponibilite', 'vehicule_type')
    search_fields = ('utilisateur__nom', 'vehicule_type')
    raw_id_fields = ('utilisateur',)

    def get_full_name(self, obj):
        return f"{obj.utilisateur.prenom} {obj.utilisateur.nom}"
    get_full_name.short_description = 'Nom Livreur'
