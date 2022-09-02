import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFav;

  Product(
      {required this.id,
      required this.title,
      required this.description,
      required this.price,
      required this.imageUrl,
      this.isFav = false});

  void _setFav(bool value) {
    isFav = value;
    notifyListeners();
  }

  Future<void> toggleFav(String productId, String userId, String token) async {
    var oldStatus = isFav;
    isFav = !isFav;
    notifyListeners();
    Uri uri = Uri.parse(
        'https://my-shop-33f05-default-rtdb.firebaseio.com/userFavorites/$userId/$productId.json?auth=$token');
    try {
      final response = await http.put(uri, body: json.encode(isFav));
      if (response.statusCode >= 400) {
        _setFav(oldStatus);
      }
    } catch (error) {
      _setFav(oldStatus);
    }
  }
}

class ProductsProvider with ChangeNotifier {
  final String _token;
  final String _userId;
  List<Product> _items = [];

  ProductsProvider(this._token, this._userId, this._items);

  List<Product> get getItems {
    return [..._items];
    // = return _items.toList() // return a copy of _items not the _items itself
  }

  List<Product> get getFavorites {
    return [..._items.where((item) => item.isFav)];
    // loop for all items & return only items that have isFav = true
  }

  set setItems(List<Product> n) {
    _items = n;
  }

  Product findById(Object? id) {
    return _items.firstWhere((element) => element.id == id);
  }

  //get request
  Future<void> fetchAndSetProducts([var filterOption = false]) async {
    Uri uri = filterOption
        ? Uri.parse(
            'https://my-shop-33f05-default-rtdb.firebaseio.com/products.json?auth=$_token&orderBy="creatorId"&equalTo="$_userId"')
        : Uri.parse(
            'https://my-shop-33f05-default-rtdb.firebaseio.com/products.json?auth=$_token');
    try {
      final response = await http.get(uri);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (json.decode(response.body) == null) {
        return;
      } // error type null can't assigned to type int
      uri = Uri.parse(
          'https://my-shop-33f05-default-rtdb.firebaseio.com/userFavorites/$_userId.json?auth=$_token');
      final favResponse = await http.get(uri);
      final favData = json.decode(favResponse.body); //{'productId', bool}
      final List<Product> loadedProducts = [];
      extractedData.forEach((productId, productData) {
        loadedProducts.add(Product(
          id: productId,
          title: productData['title'],
          description: productData['description'],
          price: productData['price'],
          imageUrl: productData['imageUrl'],
          isFav: favData == null ? false : favData[productId] ?? false,
        ));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  //post request
  Future<void> addProduct(Product product) async {
    Uri uri = Uri.parse(
        'https://my-shop-33f05-default-rtdb.firebaseio.com/products.json?auth=$_token');
    try {
      final response = await http.post(uri,
          body: json.encode(<String, dynamic>{
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'imageUrl': product.imageUrl,
            'creatorId': _userId,
          }));
      final newProduct = Product(
          id: json.decode(response.body)['name'],
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl);
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      //print(error);
      rethrow;
    }
  }

  //patch request
  Future<void> editProduct(String id, Product newProduct) async {
    int productIndex = _items.indexWhere((element) => element.id == id);
    if (productIndex >= 0) {
      Uri uri = Uri.parse(
          'https://my-shop-33f05-default-rtdb.firebaseio.com/products/$id.json?auth=$_token');
      try {
        await http.patch(uri,
            body: json.encode(<String, dynamic>{
              'title': newProduct.title,
              'description': newProduct.description,
              'price': newProduct.price,
              'imageUrl': newProduct.imageUrl,
            }));
      } catch (error) {
        rethrow;
      }
      _items[productIndex] = newProduct;
      notifyListeners();
    } else {
      debugPrint('there are no item with this id');
    }
  }

  //delete request
  // here i use optimistic updating pattern where i roll back deletion if there are any error in delete process
  Future<void> deleteProduct(String id) async {
    Uri uri = Uri.parse(
        'https://my-shop-33f05-default-rtdb.firebaseio.com/products/$id.json?auth=$_token');
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    Product? myProductReference = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(uri);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, myProductReference);
      notifyListeners();
      myProductReference = null;
      throw Exception('Could\'t remove the item');
    }
    myProductReference = null;
  }
}
