import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/order_provider.dart';

class OrderItem extends StatefulWidget {
  final Order order;

  const OrderItem(this.order);

  @override
  State<OrderItem> createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(widget.order.id),
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        padding: EdgeInsets.only(right: 15),
        alignment: Alignment.centerRight,
        color: Colors.red,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 30,
        ),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) {
        return showDialog(context: context, builder: (ctx) {
          return AlertDialog(
            title: Text(
              'Are you sure',
              style: TextStyle(fontSize: 19, color: Colors.grey[600]),
            ),
            content: Text(
              'Do you want to remove this item from the order list ?',
              style: TextStyle(fontSize: 17, color: Colors.grey[500], letterSpacing: 1),
            ),
            actions: [
              TextButton(onPressed: (){Navigator.of(context).pop(false);}, child: const Text('NO')),
              TextButton(onPressed: () {Navigator.of(context).pop(true);}, child: const Text('YES')),
            ],
            actionsAlignment: MainAxisAlignment.end,
            elevation: 5,
          );
        });
      },
      onDismissed: (direction) {
       print(widget.order.products.length);
        Provider.of<OrderProvider>(context, listen: false).removeOrder(widget.order.id);
        print(widget.order.products.length);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 15),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(
            children: [
              ListTile(
                title: Text(
                  '\$${widget.order.total.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 17),
                ),
                subtitle: Text(
                  DateFormat('MMM d, yyyy   hh:mm').format(widget.order.date),
                  style: const TextStyle(color: Colors.grey, fontSize: 15),
                ),
                trailing: IconButton(
                  icon: Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _expanded = !_expanded;
                    });
                  },
                ),
              ),
              if(_expanded) Container(
                height: min(widget.order.products.length * 20.0 + 10, 110),
                margin: EdgeInsets.symmetric(horizontal: 15),
                child: ListView(
                  children: widget.order.products.map((e) {
                    return Row(children: [
                      Text(e.title, style: const TextStyle(fontSize: 17, color: Colors.grey),),
                      const Spacer(),
                      Text('${e.quantity}x  \$${e.price}', style: const TextStyle(fontSize: 17, color: Colors.grey),)
                    ],);
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/*

 */
