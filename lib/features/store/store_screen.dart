import 'package:flutter/material.dart';

import 'models/product.dart';
import 'services/product_service.dart';

import 'widgets/store_header.dart';
import 'widgets/category_chips.dart';
import 'widgets/product_card.dart';
import 'widgets/cart_bar.dart';
import 'package:pulseup/core/api_config.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();}

class _StoreScreenState extends State<StoreScreen> {  

  final service = ProductService(ApiConfig.fullUrl);

  List<Product> products = [];
  List<Product> filtered = [];

  String selected = "Todos";
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final data = await service.getProducts();

      setState(() {
        products = data;
        filtered = data;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });

      debugPrint("Store error: $e");
    }
  }

  void filter(String cat) {
    setState(() {
      selected = cat;
      filtered = cat == "Todos"
          ? products
          : products.where((p) => p.categoria == cat).toList();
    });
  }

  List<String> get categories =>
      ["Todos", ...{...products.map((e) => e.categoria)}];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.background,

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const StoreHeader(title: "PulseUp Store"),

                CategoryChips(
                  categories: categories,
                  selected: selected,
                  onSelect: filter,
                ),

                const SizedBox(height: 10),

                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      return ProductCard(product: filtered[i]);
                    },
                  ),
                ),
              ],
            ),

      bottomNavigationBar: const CartBar(),
    );
  }
}