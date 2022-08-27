import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';

class CartItem extends StatelessWidget {
  final String id;
  final String productId;
  final String title;
  final double price;
  final int quantity;

  const CartItem(this.id, this.productId, this.title, this.price, this.quantity);

  @override
  Widget build(BuildContext context) {
    var total = price * quantity;
    return Dismissible(
      key: ValueKey(id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 30,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        Provider.of<CartProvider>(context, listen: false).removeItem(productId);
      },
      confirmDismiss: (direction) {
        return showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'Are you sure',
              style: TextStyle(fontSize: 19, color: Colors.grey[600]),
            ),
            content: Text(
              'Do you want to remove the whole ${title.toLowerCase()} quantity from the cart ?',
              style: TextStyle(fontSize: 17, color: Colors.grey[500], letterSpacing: 1),
            ),
            actions: [
              TextButton(onPressed: (){Navigator.of(context).pop(false);}, child: const Text('NO')),
              TextButton(onPressed: () {Navigator.of(context).pop(true);}, child: const Text('YES')),
            ],
            actionsAlignment: MainAxisAlignment.end,
            elevation: 5,
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
              width: 75,
              //alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.greenAccent.withOpacity(0.8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '\$${price.toStringAsFixed(2)}',
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
            title: Text(title),
            subtitle: Text('Total: \$${total.toStringAsFixed(2)}'),
            trailing: Text('$quantity x'),
          ),
        ),
      ),
    );
  }
}
