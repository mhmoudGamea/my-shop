import 'package:flutter/material.dart';

import '../screens/order_screen.dart';
import '../screens/user_products_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 260,
      child: Column(
        children: [
          AppBar(
            title: const Text('Hi There!'),
            automaticallyImplyLeading: false,
            backgroundColor: Colors.greenAccent,
          ),
          ListTile(
            leading: const Icon(Icons.shopping_basket),
            title: const Text('Shop'),
            onTap: () => Navigator.of(context).pushReplacementNamed('/'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.payment),
            title: const Text('Orders'),
            onTap: () =>
                Navigator.of(context).pushReplacementNamed(OrderScreen.rn),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('User Products'),
            onTap: () => Navigator.of(context)
                .pushReplacementNamed(UserProductsScreen.rn),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
