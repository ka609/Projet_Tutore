# 🏥 Medishop – Application de gestion de pharmacie en ligne

![Status](https://img.shields.io/badge/status-académique-success)
![Backend](https://img.shields.io/badge/backend-Django-green)
![Frontend](https://img.shields.io/badge/frontend-Flutter-blue)
![Database](https://img.shields.io/badge/database-PostgreSQL-informational)
![License](https://img.shields.io/badge/license-MIT-lightgrey)

## 📌 Description

**Medishop** est une application web et mobile permettant la **gestion des pharmacies**, la **recherche** et la **commande de médicaments en ligne**.  
Le projet a été réalisé dans le cadre du **Projet Tutoré de Licence 3** à l'**Université Virtuelle du Burkina Faso (UV-BF)**.

---

## 📑 Table des matières

- [Fonctionnalités](#-fonctionnalités)
- [Prérequis et installation](#️-prérequis-et-installation)
- [Utilisation](#-utilisation)
- [Configuration](#️-configuration)
- [Tests](#️-tests)
- [Déploiement](#️-déploiement)
- [Contributions](#️-contributions)
- [Auteurs et remerciements](#️-auteurs-et-remerciements)
- [Licence](#️-licence)
- [Support et contact](#️-support-et-contact)
- [Roadmap](#️-roadmap)

---

## ✨ Fonctionnalités

### 👤 Utilisateurs (Clients)
- Création de compte et authentification
- Recherche de médicaments (nom, catégorie, symptôme)
- Ajout au panier
- Passage de commande
- Suivi des commandes et livraisons

### 🏪 Pharmacies
- Tableau de bord pharmacie
- Gestion du stock de médicaments
- Gestion des commandes
- Mise à jour des disponibilités

### 🛠️ Administration
- Supervision globale du système
- Gestion des utilisateurs et pharmacies

---

## ⚙️ Prérequis et installation

### 📦 Prérequis

#### Backend
- Python ≥ 3.9
- PostgreSQL
- pip / virtualenv

#### Frontend
- Flutter SDK ≥ 3.x
- Dart

### 🔧 Installation et utilisation


# Cloner le projet
```bash
git clone https://github.com/ka609/Projet_Tutore.git
cd ProjetTutore/Medishop
```

# Créer un environnement virtuel

```bash
python -m venv venv
source venv/bin/activate   # Linux / macOS
venv\Scripts\activate      # Windows
```

# Installer les dépendances

```bash
pip install -r requirements.txt
```

# Appliquer les migrations
```bash
python manage.py migrate
```

# Lancer le serveur backend
```bash
python manage.py runserver
```

# Installer et lancer le frontend Flutter
```bash
cd ../frontend
flutter pub get
flutter run
```

## 🚀 Utilisation

1. **Accéder à l'API backend** : http://127.0.0.1:8000/api/
2. **Lancer l'application Flutter** sur émulateur ou appareil réel
3. **Créer un compte** utilisateur ou pharmacie
4. **Rechercher des médicaments**
5. **Passer une commande**

📸 *Les captures d'écran sont disponibles dans le rapport du projet.*



## 🧪 Tests

### Backend (Django)
```bash
python manage.py test
```

**Types de tests :**
- Tests unitaires
- Tests fonctionnels
- Tests d'intégration API

### Frontend (Flutter)
- Tests UI
- Tests fonctionnels (navigation, formulaires)
- Tests API

## 🚀 Déploiement

**Recommandations :**
- **Backend** : VPS Linux avec Nginx + Gunicorn
- **Base de données** : PostgreSQL
- **Frontend mobile** : APK / Play Store (perspective)

⚠️ *Le projet est actuellement en environnement académique (développement).*

## 🤝 Contributions

Les contributions sont acceptées dans un cadre académique.

**Processus :**
1. Fork du dépôt
2. Création d'une branche (`feature/ma-fonctionnalite`)
3. Commit clair et structuré
4. Pull Request

**Style de code :**
- Respect des conventions Python (PEP8)
- Code clair et commenté

## 👨‍🎓 Auteurs et remerciements

**Auteur principal :**
- Kassongo Moussa
- Licence 3 – Génie Logiciel
- Université Virtuelle du Burkina Faso

**Encadrement :**
- M. OUEDRAOGO W. A. Marc Christian
- Tuteur académique

🙏 *Merci à l'UV-BF pour l'encadrement pédagogique.*

## 📜 Licence

Ce projet est sous licence MIT.  
Voir le fichier **LICENSE** pour plus de détails.

## 📞 Support et contact

Pour toute question académique ou technique :
- **GitHub** : https://github.com/ka609
- **Projet** : https://github.com/ka609/Projet_Tutore

## 🛣️ Roadmap (évolutions futures)

- Intégration du paiement mobile (Mobile Money)
- Géolocalisation des pharmacies
- Notifications en temps réel
- Version web complète
- Gestion avancée des livraisons

---

© 2024 – Projet Tutoré UV-BF | Medishop
