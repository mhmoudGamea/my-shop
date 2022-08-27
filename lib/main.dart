//my-shop
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './providers/order_provider.dart';
import './providers/cart_provider.dart';
import './screens/product_details_screen.dart';
import './screens/products_overview_screen.dart';
import './screens/cart_screen.dart';
import './screens/order_screen.dart';
import './providers/products_provider.dart';
import './screens/user_products_screen.dart';
import './screens/edit_product_screen.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ProductsProvider()),
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(create: (context) => OrderProvider()),
      ],
      // i 'll use builder instead of create if i use Provider version 3 or less (create: (context) => ProductsProvider())
      // and will use (.value & value:) instead of them if i didn't won't the context
      child: MaterialApp(
        title: 'MyShop',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            //primarySwatch: Colors.purple,
            accentColor: Colors.greenAccent[100],
            fontFamily: 'Lato',
        appBarTheme: const AppBarTheme(backgroundColor: Colors.greenAccent,)),
        home: const ProductsOverviewScreen(),
        routes: {
          ProductDetailsScreen.rn: (context) => const ProductDetailsScreen(),
          CartScreen.rn: (context) => CartScreen(),
          OrderScreen.rn: (context) => OrderScreen(),
          UserProductsScreen.rn: (context) => UserProductsScreen(),
          EditProductScreen.rn: (context) => EditProductScreen(),
        },
      ),
    );
  }
}
