# 🏥 Medishop – Application de gestion de pharmacie en ligne

## 📌 Présentation du projet

**Medishop** est une application de gestion de pharmacie en ligne développée dans le cadre du **Projet Tutoré** de la **Licence 3 – Génie Logiciel (Développement Web et Mobile)** à l’**Université Virtuelle du Burkina Faso (UV-BF)**.

La plateforme permet aux utilisateurs de rechercher et commander des médicaments en ligne, tandis que les pharmacies disposent d’un tableau de bord pour gérer leurs stocks, commandes et livraisons via une API sécurisée.

---

## 👨‍🎓 Informations académiques

- **Étudiant** : Kassongo Moussa  
- **Filière** : Génie Logiciel – Développement Web et Mobile  
- **Niveau** : Licence 3  
- **Tuteur** : M. OUEDRAOGO W. A. Marc Christian  
- **Année académique** : 2023 – 2024  
- **Université** : Université Virtuelle du Burkina Faso (UV-BF)

---

## 🎯 Objectifs du projet

### Objectif général
Concevoir et implémenter une plateforme numérique moderne permettant la **gestion des stocks** et la **commande de médicaments en ligne**.

### Objectifs spécifiques
- Faciliter l’inscription et l’authentification des utilisateurs et pharmacies
- Permettre la recherche de médicaments par nom, catégorie ou symptôme
- Gérer les commandes et le panier
- Proposer un paiement sécurisé
- Assurer le suivi des commandes et livraisons
- Optimiser la gestion des prescriptions et des stocks

---

## 👥 Utilisateurs cibles

- **Clients** : recherche, commande et suivi des médicaments
- **Pharmacies** : gestion des stocks, disponibilités et commandes
- **Administrateur** : supervision globale du système

---

## 🧩 Fonctionnalités principales

- Gestion des comptes utilisateurs et pharmacies
- Catalogue des médicaments
- Recherche avancée
- Panier et commande
- Paiement sécurisé
- Suivi des livraisons
- Gestion des prescriptions
- Gestion des stocks
- Tableau de bord pharmacie

---

## 🏗️ Architecture du système

L’application repose sur une **architecture client–serveur** :

- **Frontend mobile** : Application Flutter
- **Backend** : API REST développée avec Django & Django REST Framework
- **Base de données** : PostgreSQL

---

## 🛠️ Technologies utilisées

### Backend
- Python
- Django
- Django REST Framework
- JWT (authentification)
- PostgreSQL

### Frontend
- Flutter
- Dart

### Autres outils
- Git & GitHub
- Postman (tests API)

---

## 🧪 Tests et validation

### Tests Backend
- Tests unitaires
- Tests fonctionnels
- Tests d’intégration des endpoints API

### Tests Frontend (Flutter)
- Tests des interfaces utilisateur
- Tests fonctionnels (authentification, recherche, commande)
- Tests de communication avec l’API

---

## ⚡ Performances et sécurité

### Performances
- Temps de réponse API optimisé
- Requêtes efficaces (`select_related`, `prefetch_related`)
- Mise en cache des données statiques
- Bonne stabilité sur appareils mobiles modestes

### Sécurité
- Authentification JWT
- Communication sécurisée via HTTPS
- Gestion stricte des permissions (DRF)
- Validation côté serveur
- Protection contre injections et accès non autorisés

---

## 📷 Aperçu de l’application

- Tableau de bord pharmacie
- Catalogue des médicaments
- Recherche avancée
- Panier et processus de paiement
- Écran de couverture (Medishop)

*(Voir les captures d’écran dans le rapport ou le dossier du projet)*

---

## 🔗 Liens du projet

- **Dépôt GitHub** :  
  https://github.com/ka609/ProjetTutore  
  https://github.com/ka609/Projet_Tutore

---

## 🚀 Perspectives d’amélioration

- Intégration du paiement mobile (Mobile Money)
- Géolocalisation des pharmacies
- Version Web complète
- Notifications en temps réel
- Gestion avancée des livraisons

---

## 📝 Conclusion

Ce projet a permis de concevoir une solution complète et moderne répondant aux besoins actuels de gestion pharmaceutique. Il met en pratique les compétences acquises en développement web, mobile, conception logicielle et sécurité des applications.

---

**© 2024 – Projet Tutoré UV-BF | Kassongo Moussa**
