import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../widgets/cart_item.dart';

class CartScreen extends StatelessWidget {
  static const rn = '/cart_screen';

  @override
  Widget build(BuildContext context) {
    final cartsData = Provider.of<CartProvider>(context);

    bool orderNowIndicator = false;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.greenAccent,
        title: const Text('Your Cart'),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(15),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(fontSize: 21, color: Colors.grey),
                  ),
                  const Spacer(),
                  Chip(
                    label: Text(
                      '\$${cartsData.getTotalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.greenAccent.withOpacity(0.8),
                  ),
                  OrderButton(cartsData),
                ],
              ),
            ),
          ),
          cartsData.getItems.isEmpty
              ? const Expanded(
                  child: Center(
                      child: Text(
                    'Cart Is Empty',
                    style: TextStyle(fontSize: 21, color: Colors.grey),
                  )),
                )
              : Expanded(
                  child: ListView.builder(
                  itemBuilder: (context, index) => CartItem(
                    // u also could use ChangeNotifierProvider<Cart>.value here instead of passing all of this arguments like i already implement in products_grid.dart
                    cartsData.getItems.values.toList()[index].id,
                    cartsData.getItems.keys.toList()[index],
                    cartsData.getItems.values.toList()[index].title,
                    cartsData.getItems.values.toList()[index].price,
                    cartsData.getItems.values.toList()[index].quantity,
                  ),
                  itemCount: cartsData.getItems.length,
                )),
        ],
      ),
    );
  }
}

class OrderButton extends StatefulWidget {
  final CartProvider cartsData;

  const OrderButton(this.cartsData);

  @override
  State<OrderButton> createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(primary: Colors.greenAccent),
      onPressed: (widget.cartsData.getTotalAmount <= 0 || _isLoading)
          ? null
          : () async {
              setState(() {
                _isLoading = true;
              });
              await Provider.of<OrderProvider>(context, listen: false).addOrder(
                  widget.cartsData.getItems.values.toList(),
                  widget.cartsData.getTotalAmount);
              setState(() {
                _isLoading = false;
              });
              widget.cartsData.clear();
            },
      child: _isLoading
          ? const CircularProgressIndicator(
              color: Colors.greenAccent,
              strokeWidth: 2,
            )
          : const Text('Order Now'),
    );
  }
}
