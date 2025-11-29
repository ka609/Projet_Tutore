// lib/screens/pharmacie/medicament_detail_screen.dart

import 'package:flutter/material.dart';

// Classe de modèle factice pour simuler les données
// Remplacez cela par votre véritable modèle de données (Medicament)
class MedicamentDetail {
  final String title;
  final String dosage;
  final String packaging;
  final String price;
  final String imageUrl;
  final String generalUsage;
  final String composition;
  final String usageInstruction;

  const MedicamentDetail({
    required this.title,
    required this.dosage,
    required this.packaging,
    required this.price,
    required this.imageUrl,
    required this.generalUsage,
    required this.composition,
    required this.usageInstruction,
  });
}

// -------------------------------------------------------------
// WIDGET PRINCIPAL : MedicamentDetailScreen
// -------------------------------------------------------------

class MedicamentDetailScreen extends StatelessWidget {
  final String
      medicamentId; // Peut être utilisé pour charger les données réelles

  const MedicamentDetailScreen({super.key, required this.medicamentId});

  @override
  Widget build(BuildContext context) {
    // Données factices correspondant à l'image
    const medicament = MedicamentDetail(
      title: "Antibiotics 200mg",
      dosage: "200mg",
      packaging: "10 tablets",
      price: "5.22",
      imageUrl: 'assets/antibiotics.png', // À remplacer par votre asset
      generalUsage:
          "Antibiotics, also known as antibacterials, are medications that destroy or slow down the growth of bacteria.",
      composition:
          "Amoxicillin, amoxicillin/clavulanate, cephalosporins, lipoglycopeptides, macrolides, ketolides, and clindamycin",
      usageInstruction:
          "Take one tablet every 12 hours with food. Do not stop treatment early, even if you feel better.",
    );

    // Couleur de référence pour le bouton 'Buy'
    const Color primaryBlue = Color(0xFF1E88E5);

    return Scaffold(
      backgroundColor: Colors.white,

      // La barre d'application est simplifiée (juste la flèche retour)
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      // Le corps de l'écran est entièrement déroulant
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ------------------ SECTION IMAGE ET PRIX ------------------
            _buildImageAndPriceSection(context, medicament),

            // ------------------ SECTION DESCRIPTION (TITRE ET EMBALLAGE) ------------------
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medicament.title,
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    medicament.packaging,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ],
              ),
            ),

            // ------------------ SECTION USAGE GÉNÉRAL ------------------
            _buildDetailSection(
              context,
              title: "General Usage",
              content: medicament.generalUsage,
            ),

            // ------------------ SECTION COMPOSITION ------------------
            _buildDetailSection(
              context,
              title: "Composition",
              content: medicament.composition,
            ),

            // ------------------ SECTION INSTRUCTIONS ------------------
            _buildDetailSection(
              context,
              title: "Usage Instruction",
              content: medicament.usageInstruction,
              includeIcon:
                  true, // Pour l'icône de la seringue comme sur l'image
            ),

            const SizedBox(
                height:
                    100), // Espace pour éviter que le FAB ne cache le contenu
          ],
        ),
      ),

      // ------------------ BARRE DE BOUTONS INFÉRIEURE ------------------
      bottomSheet: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Bouton de consultation (icône de sac)
            Container(
              height: 55,
              width: 55,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child:
                  const Icon(Icons.shopping_bag_outlined, color: primaryBlue),
            ),
            const SizedBox(width: 15),

            // Bouton Acheter
            Expanded(
              child: SizedBox(
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Logique d'achat
                  },
                  icon: const Icon(Icons.shopping_cart_outlined,
                      color: Colors.white),
                  label: const Text(
                    "Buy",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // WIDGETS DE CONSTRUCTION PRIVÉS
  // -------------------------------------------------------------

  /// Construit la section de l'image du produit et le badge de prix flottant
  Widget _buildImageAndPriceSection(
      BuildContext context, MedicamentDetail medicament) {
    // La Stack permet de superposer l'image et le badge de prix
    return Stack(
      alignment: Alignment.topRight,
      children: [
        // Container principal pour l'image
        Container(
          width: double.infinity,
          height: 250,
          decoration: BoxDecoration(
            color: Colors.white, // Fond blanc pur
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
            child: Image.asset(
              medicament.imageUrl,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  const Center(child: Icon(Icons.image_not_supported)),
            ),
          ),
        ),

        // Badge de prix flottant
        Padding(
          padding: const EdgeInsets.only(top: 10.0, right: 10.0),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "\$${medicament.price}",
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ),
      ],
    );
  }

  /// Construit une section de détails (Usage, Composition, Instruction)
  Widget _buildDetailSection(
    BuildContext context, {
    required String title,
    required String content,
    bool includeIcon = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (includeIcon)
                const Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: Icon(Icons.vaccines_outlined,
                      color: Colors.blue, size: 24), // Icône stylisée
                ),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Colors.black87,
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }
}
