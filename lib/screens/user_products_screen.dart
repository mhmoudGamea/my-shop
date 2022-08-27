import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products_provider.dart';
import '../screens/edit_product_screen.dart';
import '../widgets/app_drawer.dart';
import '../widgets/user_product_item.dart';

class UserProductsScreen extends StatelessWidget {
  static const rn = '/user_products';

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<ProductsProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(EditProductScreen.rn),
              icon: const Icon(Icons.add)),
        ],
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          await Provider.of<ProductsProvider>(context, listen: false)
              .fetchAndSetProducts();
        },
        color: Colors.greenAccent,
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: ListView.builder(
            itemBuilder: (context, index) => Column(
              children: [
                UserProductItem(
                    productsData.getItems[index].id,
                    productsData.getItems[index].imageUrl,
                    productsData.getItems[index].title),
                const Divider(),
              ],
            ),
            itemCount: productsData.getItems.length,
          ),
        ),
      ),
    );
  }
}
