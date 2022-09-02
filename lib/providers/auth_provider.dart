import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  String? _token;
  String? _userId;
  DateTime? _expiryDate;
  Timer? _authTimer;

  //Auth(this._token, this._userId, this._expiryDate);

  bool get isAuth {
    return getToken != null;
  }

  String? get getToken {
    if (_expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String? get getUserId {
    if (isAuth) {
      return _userId;
    }
    return null;
  }

  Future<void> signing(String email, String pass, Uri uri) async {
    try {
      final response = await http.post(uri,
          body: json.encode({
            'email': email,
            'password': pass,
            'returnSecureToken': true,
          }));
      final responseBody = json.decode(response.body);
      if (responseBody['error'] != null) {
        // there is an error
        throw Exception(responseBody['error']['message']);
      }
      _token = responseBody['idToken'];
      _userId = responseBody['localId'];
      _expiryDate = DateTime.now()
          .add(Duration(seconds: int.parse(responseBody['expiresIn'])));
      _autoLogout();
      notifyListeners();
      /*start saving user data in the device storage not in memory*/
      final prefs = await SharedPreferences.getInstance();//tunnel to sharedPreferences
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate!.toIso8601String(),
      });
      prefs.setString('userData', userData);
    } catch (error) {
      rethrow;
    }
  }

  Future<void> signUp(String email, String pass) async {
    Uri uri = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyACkaqCDcJQ8dcHObb6Vw_I6YgvOSe4X_U');
    return signing(email, pass, uri);
  }

  Future<void> logIn(String email, String pass) async {
    Uri uri = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyACkaqCDcJQ8dcHObb6Vw_I6YgvOSe4X_U');
    return signing(email, pass, uri);
  }

  Future<bool> tryAutoLogin() async{
    final prefs = await SharedPreferences.getInstance();
    if(!prefs.containsKey('userData')) {
      return false;
    }
    final extractedData = json.decode(prefs.getString('userData')!)  as Map<String, dynamic>;
    final expiryDate = DateTime.parse(extractedData['expiryDate']);
    if(expiryDate.isBefore(DateTime.now())) {
      return false;
    }
    _token = extractedData['token'];
    _userId = extractedData['userId'];
    _expiryDate = expiryDate;
    notifyListeners();
    _autoLogout();
    return true;
  }

  Future<void> logout() async{
    _userId = null;
    _token = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    // prefs.remove('userData'); to remove a specific key but prefs.clear(); to remove all stored keys
    prefs.clear();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer!.cancel();
    }
    final expiryTime = _expiryDate!.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: expiryTime), logout);
  }
}
