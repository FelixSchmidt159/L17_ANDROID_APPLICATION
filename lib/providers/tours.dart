import 'package:flutter/material.dart';

import './tour.dart';

class Tours with ChangeNotifier {
  List<Tour> _items = [
    Tour(
        timestamp: DateTime.now(),
        distance: 101,
        licensePlate: 'VB-365 JG',
        mileageBegin: 100000,
        mileageEnd: 100005,
        roadCondition: 'nass/Regen',
        tourBegin: 'Graz',
        tourEnd: 'Graz-Stadt',
        attendant: 'Susanne'),
    Tour(
        timestamp: DateTime.now(),
        distance: 101,
        licensePlate: 'VB-365 JG',
        mileageBegin: 100000,
        mileageEnd: 100005,
        roadCondition: 'nass/Regen',
        tourBegin: 'Graz',
        tourEnd: 'Graz-Stadt',
        attendant: 'Susanne Haberl'),
    Tour(
        timestamp: DateTime.now(),
        distance: 101,
        licensePlate: 'VB-365 JG',
        mileageBegin: 100000,
        mileageEnd: 100005,
        roadCondition: 'nass/Regen',
        tourBegin: 'Graz',
        tourEnd: 'Graz-Stadt',
        attendant: 'Susanne Haberl'),
    Tour(
        timestamp: DateTime.now(),
        distance: 101,
        licensePlate: 'VB-365 JG',
        mileageBegin: 100000,
        mileageEnd: 100005,
        roadCondition: 'nass/Regen',
        tourBegin: 'Graz',
        tourEnd: 'Graz-Stadt',
        attendant: 'Susanne Haberl'),
    Tour(
        timestamp: DateTime.now(),
        distance: 101,
        licensePlate: 'VB-365 JG',
        mileageBegin: 100000,
        mileageEnd: 100005,
        roadCondition: 'nass/Regen',
        tourBegin: 'Graz',
        tourEnd: 'Graz-Stadt',
        attendant: 'Susanne Haberl'),
    Tour(
        timestamp: DateTime.now(),
        distance: 101,
        licensePlate: 'VB-365 JG',
        mileageBegin: 100000,
        mileageEnd: 100005,
        roadCondition: 'nass/Regen',
        tourBegin: 'Graz',
        tourEnd: 'Graz-Stadt',
        attendant: 'Susanne Haberl'),
    Tour(
        timestamp: DateTime.now(),
        distance: 101,
        licensePlate: 'VB-365 JG',
        mileageBegin: 100000,
        mileageEnd: 100005,
        roadCondition: 'nass/Regen',
        tourBegin: 'Graz',
        tourEnd: 'Graz-Stadt',
        attendant: 'Susanne Haberl'),
    Tour(
        timestamp: DateTime.now(),
        distance: 101,
        licensePlate: 'VB-365 JG',
        mileageBegin: 100000,
        mileageEnd: 100005,
        roadCondition: 'nass/Regen',
        tourBegin: 'Graz',
        tourEnd: 'Graz-Stadt',
        attendant: 'Susanne Haberl'),
    Tour(
        timestamp: DateTime.now(),
        distance: 101,
        licensePlate: 'VB-365 JG',
        mileageBegin: 100000,
        mileageEnd: 100005,
        roadCondition: 'nass/Regen',
        tourBegin: 'Graz',
        tourEnd: 'Graz-Stadt',
        attendant: 'Susanne Haberl'),
    Tour(
        timestamp: DateTime.now(),
        distance: 101,
        licensePlate: 'VB-365 JG',
        mileageBegin: 100000,
        mileageEnd: 100005,
        roadCondition: 'nass/Regen',
        tourBegin: 'Graz',
        tourEnd: 'Graz-Stadt',
        attendant: 'Susanne Haberl'),
    Tour(
        timestamp: DateTime.now(),
        distance: 101,
        licensePlate: 'VB-365 JG',
        mileageBegin: 100000,
        mileageEnd: 100005,
        roadCondition: 'nass/Regen',
        tourBegin: 'Graz',
        tourEnd: 'Graz-Stadt',
        attendant: 'Susanne Haberl'),
    Tour(
        timestamp: DateTime.now(),
        distance: 101,
        licensePlate: 'VB-365 JG',
        mileageBegin: 100000,
        mileageEnd: 100005,
        roadCondition: 'nass/Regen',
        tourBegin: 'Graz',
        tourEnd: 'Graz-Stadt',
        attendant: 'Susanne Haberl'),
    Tour(
        timestamp: DateTime.now(),
        distance: 101,
        licensePlate: 'VB-365 JG',
        mileageBegin: 100000,
        mileageEnd: 100005,
        roadCondition: 'nass/Regen',
        tourBegin: 'Graz',
        tourEnd: 'Graz-Stadt',
        attendant: 'Susanne Haberl'),
    Tour(
        timestamp: DateTime.now(),
        distance: 101,
        licensePlate: 'VB-365 JG',
        mileageBegin: 100000,
        mileageEnd: 100005,
        roadCondition: 'nass/Regen',
        tourBegin: 'Graz',
        tourEnd: 'Graz-Stadt',
        attendant: 'Susanne Haberl'),
    Tour(
        timestamp: DateTime.now(),
        distance: 101,
        licensePlate: 'VB-365 JG',
        mileageBegin: 100000,
        mileageEnd: 100005,
        roadCondition: 'nass/Regen',
        tourBegin: 'Graz',
        tourEnd: 'Graz-Stadt',
        attendant: 'Susanne Haberl'),
    Tour(
        timestamp: DateTime.now(),
        distance: 101,
        licensePlate: 'VB-365 JG',
        mileageBegin: 100000,
        mileageEnd: 100005,
        roadCondition: 'nass/Regen',
        tourBegin: 'Graz',
        tourEnd: 'Graz-Stadt',
        attendant: 'Susanne Haberl'),
    Tour(
        timestamp: DateTime.now(),
        distance: 101,
        licensePlate: 'VB-365 JG',
        mileageBegin: 100000,
        mileageEnd: 100005,
        roadCondition: 'nass/Regen',
        tourBegin: 'Graz',
        tourEnd: 'Graz-Stadt',
        attendant: 'Susanne Haberl'),
  ];

  List<Tour> get items {
    return [..._items];
  }

  int overallDistance() {
    int overallDistance = 0;

    for (Tour item in _items) {
      overallDistance += item.distance;
    }

    return overallDistance;
  }
  // var _showFavoritesOnly = false;

  // List<Product> get items {
  //   // if (_showFavoritesOnly) {
  //   //   return _items.where((prodItem) => prodItem.isFavorite).toList();
  //   // }
  //   return [..._items];
  // }

  // List<Product> get favoriteItems {
  //   return _items.where((prodItem) => prodItem.isFavorite).toList();
  // }

  // Product findById(String id) {
  //   return _items.firstWhere((prod) => prod.id == id);
  // }

  // void showFavoritesOnly() {
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }

  // Future<void> fetchAndSetProducts() async {
  //   const url = 'https://flutter-update.firebaseio.com/products.json';
  //   try {
  //     final response = await http.get(url);
  //     final extractedData = json.decode(response.body) as Map<String, dynamic>;
  //     if (extractedData == null) {
  //       return;
  //     }
  //     final List<Product> loadedProducts = [];
  //     extractedData.forEach((prodId, prodData) {
  //       loadedProducts.add(Product(
  //         id: prodId,
  //         title: prodData['title'],
  //         description: prodData['description'],
  //         price: prodData['price'],
  //         isFavorite: prodData['isFavorite'],
  //         imageUrl: prodData['imageUrl'],
  //       ));
  //     });
  //     _items = loadedProducts;
  //     notifyListeners();
  //   } catch (error) {
  //     throw (error);
  //   }
  // }

  // Future<void> addProduct(Product product) async {
  //   const url = 'https://flutter-update.firebaseio.com/products.json';
  //   try {
  //     final response = await http.post(
  //       url,
  //       body: json.encode({
  //         'title': product.title,
  //         'description': product.description,
  //         'imageUrl': product.imageUrl,
  //         'price': product.price,
  //         'isFavorite': product.isFavorite,
  //       }),
  //     );
  //     final newProduct = Product(
  //       title: product.title,
  //       description: product.description,
  //       price: product.price,
  //       imageUrl: product.imageUrl,
  //       id: json.decode(response.body)['name'],
  //     );
  //     _items.add(newProduct);
  //     // _items.insert(0, newProduct); // at the start of the list
  //     notifyListeners();
  //   } catch (error) {
  //     print(error);
  //     throw error;
  //   }
  // }

  // Future<void> updateProduct(String id, Product newProduct) async {
  //   final prodIndex = _items.indexWhere((prod) => prod.id == id);
  //   if (prodIndex >= 0) {
  //     final url = 'https://flutter-update.firebaseio.com/products/$id.json';
  //     await http.patch(url,
  //         body: json.encode({
  //           'title': newProduct.title,
  //           'description': newProduct.description,
  //           'imageUrl': newProduct.imageUrl,
  //           'price': newProduct.price
  //         }));
  //     _items[prodIndex] = newProduct;
  //     notifyListeners();
  //   } else {
  //     print('...');
  //   }
  // }

  // Future<void> deleteProduct(String id) async {
  //   final url = 'https://flutter-update.firebaseio.com/products/$id.json';
  //   final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
  //   var existingProduct = _items[existingProductIndex];
  //   _items.removeAt(existingProductIndex);
  //   notifyListeners();
  //   final response = await http.delete(url);
  //   if (response.statusCode >= 400) {
  //     _items.insert(existingProductIndex, existingProduct);
  //     notifyListeners();
  //     throw HttpException('Could not delete product.');
  //   }
  //   existingProduct = null;
  // }
}
