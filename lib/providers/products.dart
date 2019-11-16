import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];
  // bool _showFavoritesOnly = false;

  final String authToken;
  final userId;
  Products(this.authToken, this.userId, this._items);

  List<Product> get items {
    // if(_showFavoritesOnly){
    //   return items.where((product) => product.isFavorite).toList();
    // }else {
    return [..._items];
    // }
  }

  List<Product> get favoriteItem {
    //print(_items.where((prodItem) => prodItem.isFavorite).toList());
    return [..._items.where((prodItem) => prodItem.isFavorite)];
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? 'orderBy="createrId"&equalTo="$userId"' : '';
    var url =
        'https://shopapp-484d6.firebaseio.com/products.json?auth=$authToken&$filterString';

    try {
      final response = await http.get(url);
      final List<Product> loadedProducts = [];
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      url =
          'https://shopapp-484d6.firebaseio.com/userFavorites/$userId.json?auth=$authToken';

      final favoriteResponse = await http.get(
        url,
      );
      final favoriteData = json.decode(favoriteResponse.body);
      extractedData.forEach((key, val) {
        loadedProducts.add(Product(
          id: key,
          description: val['description'],
          price: val['price'],
          isFavorite: favoriteData == null
              ? false
              : favoriteData[key] ??
                  false, //  if value is null code after ?? is executed
          imageUrl: val['imageUrl'],
          title: val['title'],
        ));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      print(error);
      throw (error);
    }
  }

  Future<void> addProduct(Product product) {
    final url =
        'https://shopapp-484d6.firebaseio.com/products.json?auth=$authToken';
    return http
        .post(
      url,
      body: json.encode(
        {
          'title': product.title,
          'decription': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'createrId': userId,
        },
      ),
    )
        .then((val) {
      final newProduct = Product(
        title: product.title,
        imageUrl: product.imageUrl,
        price: product.price,
        description: product.description,
        id: json.decode(val.body)['name'],
      );
      // _items.add(newProduct);
      _items.insert(0, newProduct);
      notifyListeners();
    }).catchError((error) {
      print(error);
    });
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final index = _items.indexWhere((prod) => prod.id == id);
    if (index >= 0) {
      final url =
          'https://shopapp-484d6.firebaseio.com/products/$id.json?auth=$authToken';
      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'price': newProduct.price,
            'imageUrl': newProduct.imageUrl,
          }));
      _items[index] = newProduct;
      notifyListeners();
    }
  }

  void deleteProduct(String id) {
    final url =
        'https://shopapp-484d6.firebaseio.com/products/$id.json?auth=$authToken';

    final productIndex = _items.indexWhere((prod) => prod.id == id);
    var product = _items[productIndex];

    http.delete(url).then((_) {
      product = null;
    }).catchError((_) {
      _items.insert(productIndex, product);
      notifyListeners();
    });
    _items.removeWhere((prod) => prod.id == id);
    notifyListeners();
  }
}
