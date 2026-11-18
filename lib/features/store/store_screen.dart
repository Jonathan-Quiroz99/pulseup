import 'package:flutter/material.dart';

import 'models/product.dart';
import 'services/product_service.dart';

import 'controllers/cart_controller.dart';
import 'widgets/store_header.dart';
import 'widgets/category_chips.dart';
import 'widgets/product_card.dart';
import 'widgets/cart_bar.dart';
import 'package:pulseup/core/api_config.dart';
import 'package:pulseup/core/theme/app_colors.dart';
import 'package:pulseup/core/theme/app_spacing.dart';
import 'package:pulseup/widgets/ui/empty_state.dart';

import '../onboarding/section_guide.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  ProductService get service => ProductService(ApiConfig.fullUrl);

  List<Product> products = [];
  List<Product> filtered = [];

  String selected = "Todos";
  bool loading = true;
  String? error;

  // Mini tutorial de la Tienda.
  final _chipsKey = GlobalKey();
  final _productKey = GlobalKey();
  bool _guideChecked = false;

  @override
  void initState() {
    super.initState();
    SectionGuide.attach(this, () => SectionGuide.show(context, _guideSteps()));
    load();
  }

  @override
  void dispose() {
    SectionGuide.detach(this);
    super.dispose();
  }

  List<GuideStep> _guideSteps() => [
        GuideStep(
          target: _chipsKey,
          icon: Icons.filter_list,
          title: 'Filtra por categoría',
          body: 'Toca una categoría para ver solo esos productos.',
        ),
        GuideStep(
          target: _productKey,
          icon: Icons.add_shopping_cart,
          title: 'Agrega al carrito',
          body: 'Presiona el botón del producto para agregarlo. Puedes agregar '
              'varios.',
        ),
        const GuideStep(
          icon: Icons.shopping_cart_outlined,
          title: 'Tu carrito',
          body: 'Al agregar algo, abajo aparece "Ver carrito". Ahí eliges pagar '
              'en línea o pagar y recoger en recepción.',
        ),
      ];

  Future<void> load() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final data = await service.getProducts();

      if (!mounted) return;
      setState(() {
        products = data;
        filtered = data;
        loading = false;
      });
      if (!_guideChecked && data.isNotEmpty) {
        _guideChecked = true;
        SectionGuide.showIfFirstTime(context, 'tienda', _guideSteps);
      }
    } catch (e) {
      debugPrint("Store error: $e");
      if (!mounted) return;
      setState(() {
        loading = false;
        error = 'No se pudo cargar la tienda.';
      });
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
    // No own Scaffold here — this screen is swapped into HomeScreen's
    // Scaffold body, which already provides the gradient background and
    // the floating nav bar. A second nested Scaffold (with its own
    // background + bottom bar) was fighting the outer one for space,
    // hiding the gradient and causing a bottom overflow.
    return ColoredBox(
      color: AppColors.bg,
      // bottom: false — navBarClearance (lista y CartBar) ya incluye el margen
      // de los botones de Android. Con el SafeArea de abajo se contaba dos
      // veces: la barra del carrito quedaba flotando a media pantalla, tapando
      // productos, con un hueco vacío debajo.
      child: SafeArea(
        top: false,
        bottom: false,
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : error != null
                ? EmptyState(
                    icon: Icons.storefront_outlined,
                    title: error!,
                    actionLabel: 'Reintentar',
                    onAction: load,
                  )
                : Column(
                    children: [
                      const StoreHeader(title: 'Tienda'),
                      CategoryChips(
                        key: _chipsKey,
                        categories: categories,
                        selected: selected,
                        onSelect: filter,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Expanded(
                        child: filtered.isEmpty
                            ? const EmptyState(
                                icon: Icons.inventory_2_outlined,
                                title: 'Sin productos en esta categoría',
                              )
                            : ValueListenableBuilder(
                                valueListenable: CartController.instance.items,
                                builder: (context, cartItems, _) =>
                                    ListView.builder(
                                  padding: EdgeInsets.fromLTRB(
                                    AppSpacing.screenX,
                                    0,
                                    AppSpacing.screenX,
                                    // Con carrito lleno, la CartBar (abajo) ya
                                    // reserva el hueco de la nav flotante.
                                    cartItems.isEmpty
                                        ? AppSpacing.navBarClearance
                                        : AppSpacing.md,
                                  ),
                                  itemCount: filtered.length,
                                  itemBuilder: (_, i) => ProductCard(
                                    key: i == 0 ? _productKey : null,
                                    product: filtered[i],
                                  ),
                                ),
                              ),
                      ),
                      const CartBar(),
                    ],
                  ),
      ),
    );
  }
}
