import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/order_screen.dart';
import '../screens/user_products_screen.dart';
import '../providers/auth_provider.dart';

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
          ListTile(
            leading: const Icon(Icons.logout_rounded),
            title: const Text('Logout'),
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/');
              Provider.of<Auth>(context, listen: false).logout();
            },
          ),
          const Divider(),
        ],
      ),
    );
  }
}
