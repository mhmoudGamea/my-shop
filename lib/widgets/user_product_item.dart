import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products_provider.dart';
import '../screens/edit_product_screen.dart';

class UserProductItem extends StatelessWidget {
  final String id;
  final String imageUrl;
  final String title;

  const UserProductItem(this.id, this.imageUrl, this.title);

  @override
  Widget build(BuildContext context) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    return ListTile(
      leading: CircleAvatar(
          backgroundImage: NetworkImage(imageUrl),
          backgroundColor: Colors.white,
          radius: 23),
      title: Text(title),
      trailing: SizedBox(
        width: 100,
        child: Row(
          children: [
            const Spacer(),
            IconButton(
              onPressed: () => Navigator.of(context)
                  .pushNamed(EditProductScreen.rn, arguments: id),
              icon: const Icon(Icons.edit),
              color: Colors.blue[300],
            ),
            IconButton(
                onPressed: () async {
                  try {
                    await Provider.of<ProductsProvider>(context, listen: false)
                        .deleteProduct(id);
                  } catch (error) {
                    scaffoldMessenger.showSnackBar(SnackBar(
                      content: const Text('Could\'t remove the item' ,
                          style: TextStyle(
                              fontSize: 16, letterSpacing: 1, color: Colors.redAccent)),
                      duration: const Duration(seconds: 2),
                      backgroundColor: Colors.grey[400]?.withOpacity(0.7),
                    ));
                  }
                },
                icon: const Icon(
                  Icons.delete,
                  color: Colors.red,
                )),
          ],
        ),
      ),
    );
  }
}
