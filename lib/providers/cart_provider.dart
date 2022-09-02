import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

//_items = {
// 'p1': {id, title, quantity, price},
// 'p2': {id, title, quantity, price},
// }
// i.e for the watch => {p6: Instance of 'Cart'}
class Cart with ChangeNotifier {
  final String id;
  final String title;
  final int quantity; // i.e i order 3 watches so the quantity is 3
  final double price; // price for each watch not the total

  Cart({
    required this.id,
    required this.title,
    required this.quantity,
    required this.price,
  });
}

class CartProvider with ChangeNotifier {
  final String _token;
  final String _userId;
  Map<String, Cart> _items = {};
  CartProvider(this._token, this._userId, this._items);

  Map<String, Cart> get getItems {
    return {..._items};
  }

  int get getCount {
    // count of the quantity
    int quantityCount = 0;
    _items.forEach((key, cartItem) {
      quantityCount += cartItem.quantity;
    });
    return quantityCount;
  }

  // String get getCartId {
  //   _items.map((key, value) {
  //     return
  //   });
  // }
  double get getTotalAmount {
    // price * quantity
    var totalAmount = 0.0;
    _items.forEach((key, cartItem) {
      totalAmount += cartItem.price * cartItem.quantity;
    });
    return totalAmount;
  }

  Future<void> fetchAndSetProducts() async {
    Uri uri = Uri.parse(
        'https://my-shop-33f05-default-rtdb.firebaseio.com/carts/$_userId.json?auth=$_token');
    try {
      final response = await http.get(uri);
      if (json.decode(response.body) == null) return;
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      Map<String, Cart> loadedCarts = {};
      extractedData.forEach((key, value) {
        loadedCarts.putIfAbsent(
            value['productId'],
            () => Cart(
                id: key,
                title: value['title'],
                quantity: value['quantity'],
                price: value['price']));
      });
      _items = loadedCarts;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> addToCart(String productId, String title, double price) async {
    late Cart cart;
    if (_items.containsKey(productId)) {
      // change quantity...
      _items.forEach((key, value) {
        if (productId == key) {
          cart = value;
        }
      });
      Uri uri = Uri.parse(
          'https://my-shop-33f05-default-rtdb.firebaseio.com/carts/$_userId/${cart.id}.json?auth=$_token');
      await http.patch(uri,
          body: json.encode({
            'quantity': cart.quantity + 1,
          }));
      _items.update(
        productId,
        (existingCartItem) => Cart(
          id: existingCartItem.id,
          title: existingCartItem.title,
          price: existingCartItem.price,
          quantity: existingCartItem.quantity + 1,
        ),
      );
    } else {
      // add new product to cart
      Uri uri = Uri.parse(
          'https://my-shop-33f05-default-rtdb.firebaseio.com/carts/$_userId.json?auth=$_token');
      final response = await http.post(uri,
          body: json.encode({
            'productId': productId,
            'title': title,
            'price': price,
            'quantity': 1,
          }));
      _items.putIfAbsent(
        productId,
        () => Cart(
          id: json.decode(response.body)['name'],
          title: title,
          price: price,
          quantity: 1,
        ),
      );
    }
    notifyListeners();
  }

  Future<void> removeItem(String productId) async {
    late Cart cart;
    Map<String, Cart>? myExistingCart = {};
    _items.forEach((key, value) {
      if (productId == key) {
        cart = value;
        myExistingCart!.putIfAbsent(
            productId,
            () => Cart(
                  id: cart.id,
                  title: cart.title,
                  price: cart.price,
                  quantity: cart.quantity,
                ));
      }
    });
    _items.remove(productId);
    notifyListeners();
    Uri uri = Uri.parse(
        'https://my-shop-33f05-default-rtdb.firebaseio.com/carts/$_userId/${cart.id}.json?auth=$_token');
    final response = await http.delete(uri);
    if (response.statusCode >= 400) {
      _items.putIfAbsent(
          productId,
          () => Cart(
                id: myExistingCart!.values.toList()[0].id,
                title: myExistingCart.values.toList()[0].title,
                price: myExistingCart.values.toList()[0].price,
                quantity: myExistingCart.values.toList()[0].quantity,
              ));
      notifyListeners();
      myExistingCart = null;
    }
    myExistingCart = null;
  }

  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) {
      return;
    }
    if (_items[productId]!.quantity > 1) {
      _items.update(productId, (existingCartItem) {
        return Cart(
            id: existingCartItem.id,
            title: existingCartItem.title,
            price: existingCartItem.price,
            quantity: existingCartItem.quantity - 1);
      });
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  void clear() async{
    Uri uri = Uri.parse(
        'https://my-shop-33f05-default-rtdb.firebaseio.com/carts/$_userId.json?auth=$_token');
    final response = await http.delete(uri);
    _items = {};
    notifyListeners();
  }
}
