import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/providers/products.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';
import './product_item.dart';

class ProductsGrid extends StatelessWidget {
  final bool showFavs;
  ProductsGrid(this.showFavs);
  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    //print(showFavs);
    final loadedProduct =
        showFavs ? productsData.favoriteItem : productsData.items;
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      itemBuilder: (ctx, i) {
        return ChangeNotifierProvider.value(
          value: loadedProduct[i],
          child: ProductItem(
              // loadedProduct[i].id,
              // loadedProduct[i].title,
              // loadedProduct[i].imageUrl,
              ),
        );
      },
      itemCount: loadedProduct.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          mainAxisSpacing: 10,
          crossAxisCount: 2,
          childAspectRatio: 3 / 2,
          crossAxisSpacing: 10),
    );
  }
}
