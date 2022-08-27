import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './cart_provider.dart';

class Order with ChangeNotifier {
  final String id;
  final double total; // = amount = price * quantity = total
  final List<Cart> products;
  final DateTime date;

  Order({
    required this.id,
    required this.total,
    required this.date,
    required this.products,
  });
}

class OrderProvider with ChangeNotifier {
  List<Order> _orders = [];

  List<Order> get getOrders {
    return [..._orders];
  }

  Future<void> addOrder(List<Cart> cartProducts, double total) async {
    Uri uri = Uri.parse(
        'https://my-shop-33f05-default-rtdb.firebaseio.com/orders.json');
    final timeStamp = DateTime.now();
    final response = await http.post(uri,
        body: json.encode({
          'amount': total,
          'date': timeStamp.toIso8601String(),
          'products': cartProducts
              .map((cp) => {
                    'id': cp.id,
                    'title': cp.title,
                    'quantity': cp.quantity,
                    'price': cp.price,
                  })
              .toList(),
        }));

    if (total != 0.0) {
      _orders.insert(
        0,
        Order(
          id: json.decode(response.body)['name'],
          total: total,
          products: cartProducts,
          date: timeStamp,
        ),
      );
      notifyListeners();
    } else {
      print('you cant order');
    }
  }

  Future<void> fetchAndSetOrders() async {
    Uri uri = Uri.parse(
        'https://my-shop-33f05-default-rtdb.firebaseio.com/orders.json');
    final response = await http.get(uri);
    print(response.body);
    if (json.decode(response.body) == null) return;
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    final List<Order> loadedOrders = [];
    extractedData.forEach((orderId, orderData) {
      // note that orderId here is of type String.
      // note that orderData here is a map {orderId: {orderData}, orderId: {orderData}} and so on.
      loadedOrders.add(Order(
        id: orderId,
        total: orderData['amount'], // amount = quantity * price = total
        date: DateTime.parse(orderData['date']),
        products: (orderData['products']
                as List<dynamic>) // products stored as a List
            .map((c) => Cart(
                id: c['id'],
                title: c['title'],
                quantity: c['quantity'],
                price: c['price']))
            .toList(),
      ));
    });
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> removeOrder(String orderId) async {
    Uri uri = Uri.parse(
        'https://my-shop-33f05-default-rtdb.firebaseio.com/orders/$orderId.json');
    final orderIndex = _orders.indexWhere((prod) => prod.id == orderId);
    Order? myOrder = _orders[orderIndex];
    _orders.removeAt(orderIndex);
    notifyListeners();
    final response = await http.delete(uri);
    if (response.statusCode >= 400) {
      _orders.insert(orderIndex, myOrder);
      notifyListeners();
      myOrder = null;
      throw Exception('Could\'t remove the order');
    }
    myOrder = null;
  }
}
