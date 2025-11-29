import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:medishop/providers/medicament_provider.dart';
import 'package:medishop/models/medicament.dart';

class MedicamentListScreen extends StatefulWidget {
  const MedicamentListScreen({super.key});

  @override
  State<MedicamentListScreen> createState() => _MedicamentListScreenState();
}

class _MedicamentListScreenState extends State<MedicamentListScreen> {
  static const Color primaryColor = Color(0xFF009688); // Teal médical pro

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<MedicamentProvider>(context, listen: false)
          .fetchAllMedicaments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MedicamentProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F8),
      body: provider.isLoading && provider.allMedicaments.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(context, provider),
    );
  }

  Widget _buildBody(BuildContext context, MedicamentProvider provider) {
    if (provider.errorMessage != null) {
      return Center(
        child: Text(provider.errorMessage!,
            style: const TextStyle(color: Colors.red)),
      );
    }

    if (provider.allMedicaments.isEmpty && !provider.isLoading) {
      return RefreshIndicator(
        onRefresh: () => provider.fetchAllMedicaments(forceRefresh: true),
        child: ListView(
          children: const [
            SizedBox(height: 200),
            Center(child: Text("Aucun médicament enregistré.")),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.fetchAllMedicaments(forceRefresh: true),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: provider.allMedicaments.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final medicament = provider.allMedicaments[index];
          return MedicamentItemCard(medicament: medicament);
        },
      ),
    );
  }
}

class MedicamentItemCard extends StatelessWidget {
  final Medicament medicament;
  static const Color primaryColor = Color(0xFF009688);

  const MedicamentItemCard({super.key, required this.medicament});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context
          .go('/pharmacie/dashboard/medicaments/${medicament.id}'), // détail
      onLongPress: () => context.go(
        '/pharmacie/dashboard/medicaments/edit',
        extra: medicament,
      ),
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // ------------------ IMAGE GAUCHE ------------------
            Container(
              width: 110,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
              child: medicament.photoUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        medicament.photoUrl!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Icon(Icons.medication,
                      color: Colors.grey.shade400, size: 50),
            ),

            // ------------------ TEXTE DROITE ------------------
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Nom du médicament
                    Text(
                      medicament.nomCommercial,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    // Catégorie ou nom scientifique
                    Text(
                      medicament.categorie ??
                          medicament.nomScientifique ??
                          'Non spécifié',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    // Prix + bouton Modifier
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          medicament.getFormattedPrice(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: primaryColor,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.edit,
                              size: 20, color: primaryColor),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
