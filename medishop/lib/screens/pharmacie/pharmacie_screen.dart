import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:medishop/providers/pharmacie_provider.dart';

class PharmacieScreen extends StatefulWidget {
  const PharmacieScreen({super.key});

  @override
  State<PharmacieScreen> createState() => _PharmacieScreenState();
}

class _PharmacieScreenState extends State<PharmacieScreen> {
  @override
  void initState() {
    super.initState();

    // 🔵 Charger UNE SEULE FOIS à l'ouverture de l'écran
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PharmacieProvider>(context, listen: false)
          .fetchMyPharmacies();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PharmacieProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Pharmacies'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          if (provider.hasAnyPharmacy)
            IconButton(
              icon: const Icon(Icons.add_business),
              onPressed: () => context.go('/pharmacie/add'),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => provider.fetchMyPharmacies(forceRefresh: true),
          ),
        ],
      ),
      body: _buildBody(context, provider),
    );
  }

  Widget _buildBody(BuildContext context, PharmacieProvider provider) {
    if (provider.isLoading && provider.myPharmacies.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.myPharmacies.isEmpty) {
      return _buildEmptyState(context, provider);
    }

    return RefreshIndicator(
      onRefresh: () => provider.fetchMyPharmacies(forceRefresh: true),
      child: ListView.builder(
        itemCount: provider.myPharmacies.length,
        itemBuilder: (context, index) {
          final pharmacie = provider.myPharmacies[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            elevation: 2,
            child: ListTile(
              leading: const Icon(Icons.local_pharmacy,
                  color: Colors.teal, size: 30),
              title: Text(
                pharmacie.nomPharmacie,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Licence: ${pharmacie.licenceNumero}',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit, color: Colors.blueGrey),
                onPressed: () {},
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, PharmacieProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_business, size: 80, color: Colors.teal),
            const SizedBox(height: 16),
            const Text(
              'Aucune pharmacie associée à votre compte.',
              style: TextStyle(fontSize: 18, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.add_circle_outline),
              label: const Text("Ajouter ma Pharmacie"),
              onPressed: () => context.go('/pharmacie/add'),
            ),
            TextButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text("Actualiser"),
              onPressed: () => provider.fetchMyPharmacies(forceRefresh: true),
            ),
          ],
        ),
      ),
    );
  }
}
