import 'package:flutter/material.dart';
import 'package:khaanado/constants/route_constants.dart';
import 'package:khaanado/constants/string_constants.dart';
import 'package:khaanado/constants/tracking_strings.dart';
import 'package:khaanado/controller/toaster_controller.dart';
import 'package:khaanado/model/food_item.dart';
import 'package:khaanado/service_locator.dart';
import 'package:khaanado/services/app_logger.dart';
import 'package:khaanado/ui/custom_widgets/app_text_field.dart';
import 'package:khaanado/ui/custom_widgets/diet_filter_chips.dart';
import 'package:khaanado/ui/custom_widgets/empty_state.dart';
import 'package:khaanado/ui/custom_widgets/food_card.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key, required this.categoryId});

  static const routeName = RouteConstants.catalog;

  final String categoryId;

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  @override
  void initState() {
    super.initState();
    loyaltyController.addListener(_refresh);
  }

  @override
  void dispose() {
    loyaltyController.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final resolved = catalogController.resolveList(widget.categoryId);
    final items = widget.categoryId == 'favorites'
        ? catalogController.favoritesOf(loyaltyController.favorites)
        : catalogController.filterDiet(
            resolved.items,
            loyaltyController.dietFilter,
          );
    return Scaffold(
      appBar: AppBar(title: Text(resolved.title)),
      body: Column(
        children: [
          DietFilterChips(
            value: loyaltyController.dietFilter,
            onChanged: loyaltyController.setDietFilter,
          ),
          Expanded(
            child: items.isEmpty
                ? const EmptyState(
                    icon: Icons.restaurant_outlined,
                    title: StringConstants.noResults,
                    body: '',
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return FoodCard(
                        item: item,
                        isFavorite: loyaltyController.isFavorite(item.id),
                        onFavorite: () =>
                            loyaltyController.toggleFavorite(item.id),
                        onAdd: () async {
                          await cartController.add(item);
                          appNotifiers.cartCount.value =
                              cartController.itemCount;
                          if (!context.mounted) return;
                          toasterController.show(
                            context,
                            '${item.name} · ${StringConstants.addedToCart}',
                            kind: ToasterKind.success,
                          );
                        },
                        onTap: () {
                          AppTracker.track(
                            TrackingStrings.itemOpen,
                            {'id': item.id},
                          );
                          Navigator.pushNamed(
                            context,
                            RouteConstants.detail,
                            arguments: item,
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  static const routeName = RouteConstants.search;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _query = TextEditingController();
  List<FoodItem> _results = const [];

  @override
  void initState() {
    super.initState();
    _results = catalogController.items;
    loyaltyController.addListener(_refreshFav);
  }

  @override
  void dispose() {
    loyaltyController.removeListener(_refreshFav);
    _query.dispose();
    super.dispose();
  }

  void _refreshFav() {
    if (mounted) setState(() {});
  }

  void _onChanged(String value) {
    setState(() => _results = catalogController.search(value));
    if (value.trim().length > 1) {
      AppTracker.track(TrackingStrings.search, {'q': value.trim()});
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = catalogController.filterDiet(
      _results,
      loyaltyController.dietFilter,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: AppTextField(
              controller: _query,
              hint: StringConstants.searchHint,
              icon: Icons.search,
              onChanged: _onChanged,
            ),
          ),
          DietFilterChips(
            value: loyaltyController.dietFilter,
            onChanged: loyaltyController.setDietFilter,
          ),
          Expanded(
            child: filtered.isEmpty
                ? const EmptyState(
                    icon: Icons.search_off,
                    title: StringConstants.noResults,
                    body: '',
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return FoodCard(
                        item: item,
                        isFavorite: loyaltyController.isFavorite(item.id),
                        onFavorite: () =>
                            loyaltyController.toggleFavorite(item.id),
                        onAdd: () async {
                          await cartController.add(item);
                          appNotifiers.cartCount.value =
                              cartController.itemCount;
                          if (!context.mounted) return;
                          toasterController.show(
                            context,
                            '${item.name} · ${StringConstants.addedToCart}',
                            kind: ToasterKind.success,
                          );
                        },
                        onTap: () => Navigator.pushNamed(
                          context,
                          RouteConstants.detail,
                          arguments: item,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
