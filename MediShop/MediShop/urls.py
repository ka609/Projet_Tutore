from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from rest_framework.routers import DefaultRouter

from rest_framework_simplejwt.views import (
    TokenObtainPairView,
    TokenRefreshView,
    TokenVerifyView,
)

# Importer tous les ViewSets
from accounts.views import UtilisateurViewSet, ClientViewSet, PharmacieViewSet, LivreurViewSet
from commerce.views import (
    MedicamentViewSet, SymptomeViewSet, MedicamentSymptomeViewSet,
    StockViewSet, PrescriptionViewSet, PanierViewSet, PanierArticleViewSet,
    CommandeViewSet, LigneCommandeViewSet, PaiementViewSet
)
from features.views import NotificationViewSet, JournalActiviteViewSet, ParametreUtilisateurViewSet

# --- 1. Création du Router DRF ---
router = DefaultRouter()

# --- 2. Accounts ---
router.register(r'utilisateurs', UtilisateurViewSet, basename='utilisateur')
router.register(r'clients', ClientViewSet, basename='client')
router.register(r'pharmacies', PharmacieViewSet, basename='pharmacie')
router.register(r'livreurs', LivreurViewSet, basename='livreur')

# --- 3. Commerce ---
router.register(r'medicaments', MedicamentViewSet, basename='medicament')
router.register(r'symptomes', SymptomeViewSet, basename='symptome')
router.register(r'medicament-symptomes', MedicamentSymptomeViewSet, basename='medicament-symptome')
router.register(r'stocks', StockViewSet, basename='stock')
router.register(r'prescriptions', PrescriptionViewSet, basename='prescription')
router.register(r'paniers', PanierViewSet, basename='panier')
router.register(r'paniers-articles', PanierArticleViewSet, basename='panier-article')
router.register(r'commandes', CommandeViewSet, basename='commande')
router.register(r'lignes-commandes', LigneCommandeViewSet, basename='ligne-commande')
router.register(r'paiements', PaiementViewSet, basename='paiement')

# --- 4. Features ---
router.register(r'notifications', NotificationViewSet, basename='notification')
router.register(r'journal-activites', JournalActiviteViewSet, basename='journal-activite')
router.register(r'parametres-utilisateurs', ParametreUtilisateurViewSet, basename='parametre-utilisateur')

# --- 5. URL Patterns ---
urlpatterns = [
    path('admin/', admin.site.urls),  # ← Ajout de l'admin
    path('api/token/', TokenObtainPairView.as_view(), name='token_obtain_pair'), # Génère access/refresh token
    path('api/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'), # Renouvelle access token
    path('api/token/verify/', TokenVerifyView.as_view(), name='token_verify'),
    path('api/', include(router.urls)),
    path('api-auth/', include('rest_framework.urls')),  # login DRF browsable API
]

# --- 6. Servir les médias et statiques en développement ---
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
    urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
