import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product(
      {@required this.description,
      @required this.id,
      @required this.imageUrl,
      this.isFavorite = false,
      @required this.price,
      @required this.title});

  void toggleFavorite(String token, String userId) {
    final url =
        'https://shopapp-484d6.firebaseio.com/userFavorites/$userId/$id.json?auth=$token';

    isFavorite = !isFavorite;
    http.put(
      url,
      body: json.encode(
        isFavorite,
      ),
    );
    notifyListeners();
  }
}
