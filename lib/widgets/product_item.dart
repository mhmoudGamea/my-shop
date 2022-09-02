import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/products_provider.dart';
import '../screens/product_details_screen.dart';

class ProductItem extends StatelessWidget {
  const ProductItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context); // a disaster will happen if u set listen: false
    final cartsData = Provider.of<CartProvider>(context, listen: false);
    final auth = Provider.of<Auth>(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        footer: GridTileBar(
          backgroundColor: Colors.grey[600]?.withOpacity(0.7),
          leading: Consumer<Product>(
            builder: (context, product, child) => IconButton(
              icon:
              Icon(product.isFav ? Icons.favorite : Icons.favorite_border),
              color: Colors.greenAccent[400],
              onPressed: () => product.toggleFav(product.id, auth.getUserId!, auth.getToken!),
            ),
          ),
          title: Text(
            product.title,
            textAlign: TextAlign.center,
          ),
          trailing: IconButton(
              icon: const Icon(Icons.shopping_basket),
              color: Colors.greenAccent[400],
              onPressed: () async{
                await cartsData.addToCart(product.id, product.title, product.price);
                scaffoldMessenger.hideCurrentSnackBar();
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: const Text('Item is added to the Cart..',
                        style: TextStyle(
                            fontSize: 16, letterSpacing: 1, color: Colors.white)),
                    duration: const Duration(seconds: 2),
                    backgroundColor: Colors.grey[400]?.withOpacity(0.7),
                    action: SnackBarAction(
                      label: 'UNDO',
                      textColor: Colors.red,
                      onPressed: () {
                        cartsData.removeSingleItem(product.id);
                      },
                    ),
                  ),
                );
              },
          ),
        ),
        child: InkWell(
          onTap: () {
            Navigator.of(context)
                .pushNamed(ProductDetailsScreen.rn, arguments: product.id);
          },
          child: Image.network(
            product.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
