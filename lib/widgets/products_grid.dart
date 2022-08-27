import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products_provider.dart';
import '../widgets/product_item.dart';

class ProductsGrid extends StatelessWidget {
  final bool _isFavorites;

  const ProductsGrid(
    this._isFavorites,
  );

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<ProductsProvider>(
        context); // u have an object from ProductsProvider class
    final products = _isFavorites
        ? productsData
            .getFavorites // u get a list of fav Products [Product 0, Product 3]
        : productsData
            .getItems; // u get a list of Products [Product 0, Product 1, ..., Product n]
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // number of columns in GridView
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 10, // spacing between columns
        mainAxisSpacing: 10, // spacing between rows
      ),
      itemBuilder: (context, index) {
        return ChangeNotifierProvider.value(
          // products[index] an instance of a single product (i only interested with changes happen in one product)
          value: products[index],
          child: const ProductItem(),
        );
      },
      itemCount: products.length,
    );
  }
}
