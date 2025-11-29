# accounts/permissions.py

from rest_framework import permissions

class IsClient(permissions.BasePermission):
    """Autorise l'accès uniquement si l'utilisateur est de type CLIENT."""
    def has_permission(self, request, view):
        return request.user.is_authenticated and hasattr(request.user, 'client')

class IsPharmacie(permissions.BasePermission):
    """Autorise l'accès uniquement si l'utilisateur est de type PHARMACIE."""
    def has_permission(self, request, view):
        return request.user.is_authenticated and hasattr(request.user, 'pharmacie')

class IsLivreur(permissions.BasePermission):
    """Autorise l'accès uniquement si l'utilisateur est de type LIVREUR."""
    def has_permission(self, request, view):
        return request.user.is_authenticated and hasattr(request.user, 'livreur')