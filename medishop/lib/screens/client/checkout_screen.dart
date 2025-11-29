import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:medishop/providers/commande_provider.dart';
import 'package:medishop/providers/panier_provider.dart';
import 'package:medishop/providers/payment_provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _addressController =
      TextEditingController(text: '123 Rue de la Liberté, Casablanca');

  PaymentMethod _selectedMethod = PaymentMethod.paiementLivraison;
  int? _pendingCommandeId;

  final Map<PaymentMethod, String> _paymentMethodsMap = {
    PaymentMethod.paiementLivraison: 'Paiement à la livraison (COD)',
    PaymentMethod.carteBancaire: 'Carte bancaire (Simulé)',
    PaymentMethod.virement: 'Virement bancaire',
  };

  @override
  void initState() {
    super.initState();
    Future.microtask(_createPendingOrder);
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _createPendingOrder() async {
    final commandeProvider =
        Provider.of<CommandeProvider>(context, listen: false);
    final panierProvider = Provider.of<PanierProvider>(context, listen: false);

    if (panierProvider.articles.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Le panier est vide, impossible de commander.')),
        );
        context.go('/client/home');
      });
      return;
    }

    try {
      // Créer la commande à partir des articles du panier et de l'adresse
      final Map<String, dynamic> commandeData = {
        'adresse_livraison': _addressController.text,
        'articles': panierProvider.articles
            .map((e) => {'medicament': e.medicament.id, 'quantite': e.quantite})
            .toList(),
      };

      final newCommande = await commandeProvider.createCommande(commandeData);

      setState(() {
        _pendingCommandeId = newCommande.id;
      });
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Erreur lors de la création de la commande: ${e.toString().replaceFirst('Exception: ', '')}')),
        );
        context.go('/client/home/panier');
      });
    }
  }

  Future<void> _handleFinalizeOrder() async {
    if (!_formKey.currentState!.validate() || _pendingCommandeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Veuillez vérifier l\'adresse et la commande.')),
      );
      return;
    }

    final panierProvider = Provider.of<PanierProvider>(context, listen: false);
    final paymentProvider =
        Provider.of<PaymentProvider>(context, listen: false);
    final total = panierProvider.totalAmount;

    try {
      await paymentProvider.submitPayment(
        commandeId: _pendingCommandeId!,
        method: _selectedMethod,
        montant: total,
      );

      panierProvider.clearPanier();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Commande de ${total.toStringAsFixed(2)} DH passée avec succès!'),
          backgroundColor: Colors.green,
        ),
      );

      context.go('/client/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final panierProvider = Provider.of<PanierProvider>(context);
    final paymentProvider = Provider.of<PaymentProvider>(context);
    final commandeProvider = Provider.of<CommandeProvider>(context);

    final bool isLoading =
        commandeProvider.isLoading || paymentProvider.isProcessingPayment;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Finaliser la Commande'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('1. Récapitulatif',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Card(
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Articles (${panierProvider.itemCount})'),
                      Text(
                        'Total: ${panierProvider.totalAmount.toStringAsFixed(2)} DH',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.deepOrange),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(),
              const SizedBox(height: 10),
              const Text('2. Adresse de Livraison',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextFormField(
                controller: _addressController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Adresse complète',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Veuillez entrer une adresse de livraison.'
                    : null,
                enabled: !isLoading,
              ),
              const SizedBox(height: 30),
              const Text('3. Méthode de Paiement',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ..._paymentMethodsMap.entries
                  .map((entry) => RadioListTile<PaymentMethod>(
                        title: Text(entry.value),
                        value: entry.key,
                        groupValue: _selectedMethod,
                        onChanged: isLoading
                            ? null
                            : (PaymentMethod? value) {
                                setState(() {
                                  _selectedMethod = value!;
                                });
                              },
                      ))
                  .toList(),
              const SizedBox(height: 40),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: panierProvider.articles.isEmpty ||
                              _pendingCommandeId == null
                          ? null
                          : _handleFinalizeOrder,
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text(
                        'CONFIRMER ET COMMANDER',
                        style: TextStyle(fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 60),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
              if (_pendingCommandeId != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Center(
                      child: Text('Commande en attente #$_pendingCommandeId')),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
