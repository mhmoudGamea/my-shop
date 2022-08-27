import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products_provider.dart';

class EditProductScreen extends StatefulWidget {
  static const rn = '/edit_product';

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceNode = FocusNode();
  final _descriptionNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _editingProduct = Product(
      id: DateTime.now().toString(),
      title: '',
      description: '',
      price: 0,
      imageUrl: '');
  var _isInit = true;
  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };

  var indicator;

  var _isLoading = false;

  @override
  void initState() {
    _imageNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context)!.settings.arguments;
      indicator = productId;
      //print(indicator);
      if (productId != null) {
        // if u load this screen by + ur productId 'll  = null then u 'll have an error
        // if u load this screen by edit icon so u will have an id so you should first check
        var editingProduct =
            Provider.of<ProductsProvider>(context, listen: false)
                .findById(productId); // error if productId = null
        _initValues = {
          'title': editingProduct.title,
          'description': editingProduct.description,
          'price': editingProduct.price.toString(),
          'imageUrl': '',
        };
        _imageUrlController.text = editingProduct.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  void _updateImageUrl() {
    // will be executed when ever the focus changes
    if (!_imageNode.hasFocus) {
      if (!_imageUrlController.text.contains('http') &&
              !_imageUrlController.text.contains('https') ||
          !_imageUrlController.text.endsWith('.jpg') &&
              !_imageUrlController.text.endsWith('.png') &&
              !_imageUrlController.text.endsWith('.jpeg')) {
        return;
      }
      setState(() {});
    }
  }

  @override
  void dispose() {
    _priceNode.dispose();
    _descriptionNode.dispose();
    _imageNode.dispose();
    _imageUrlController.dispose();
    _imageNode.removeListener(_updateImageUrl);
    super.dispose();
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState!
        .validate(); // return true if no error in any text field, false if there are error in any text field
    if (!isValid) return; // condition = false so there are errors then return
    _form.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    if (indicator != null) {
      // i am in editing mode
      await Provider.of<ProductsProvider>(context, listen: false)
          .editProduct(indicator, _editingProduct);
    } else {
      // i am in adding mode
      try {
        await Provider.of<ProductsProvider>(context, listen: false)
            .addProduct(_editingProduct);
      } catch (error) {
        await showDialog(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: const Text(
                  'Error!',
                  style: TextStyle(color: Colors.red, fontSize: 19),
                ),
                content: const Text('Un expected error occurred in the server'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Okay'),
                  )
                ],
              );
            });
      } //finally {
      //   setState(() {
      //     _isLoading = true;
      //   });
      // }
    }
    setState(() {
      _isLoading = false;
    });
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  String _pageTitle() {
    if (indicator != null) {
      return 'Edit Product';
    } else {
      return 'Add Product';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitle()),
        actions: [
          IconButton(
              onPressed: _saveForm,
              icon: const Icon(
                Icons.save,
                color: Colors.white,
              ))
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.greenAccent),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  Form(
                    key: _form,
                    child: Column(
                      children: [
                        TextFormField(
                          initialValue: _initValues['title'],
                          decoration: const InputDecoration(labelText: 'Title'),
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) =>
                              FocusScope.of(context).requestFocus(_priceNode),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter a value.';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _editingProduct = Product(
                              id: _editingProduct.id,
                              isFav: _editingProduct.isFav,
                              title: value!,
                              description: _editingProduct.description,
                              price: _editingProduct.price,
                              imageUrl: _editingProduct.imageUrl,
                            );
                          },
                        ),
                        TextFormField(
                          initialValue: _initValues['price'],
                          decoration: const InputDecoration(labelText: 'Price'),
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.number,
                          focusNode: _priceNode,
                          onFieldSubmitted: (_) => FocusScope.of(context)
                              .requestFocus(_descriptionNode),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Enter a double value ex: 2.6';
                            } else if (value.contains(',')) {
                              return 'Value can\'t contains ( , )';
                            } else if (double.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            } else if (double.parse(value) <= 0) {
                              return 'A value must be greater than zero';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _editingProduct = Product(
                              id: _editingProduct.id,
                              isFav: _editingProduct.isFav,
                              title: _editingProduct.title,
                              description: _editingProduct.description,
                              price: double.parse(value!),
                              imageUrl: _editingProduct.imageUrl,
                            );
                          },
                        ),
                        TextFormField(
                          initialValue: _initValues['description'],
                          decoration:
                              const InputDecoration(labelText: 'Description'),
                          maxLines: 2,
                          keyboardType: TextInputType.multiline,
                          focusNode: _descriptionNode,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter a value.';
                            } else if (value.length < 10) {
                              return 'A value must be greater than 15 character';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _editingProduct = Product(
                              id: _editingProduct.id,
                              isFav: _editingProduct.isFav,
                              title: _editingProduct.title,
                              description: value!,
                              price: _editingProduct.price,
                              imageUrl: _editingProduct.imageUrl,
                            );
                          },
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              width: 70,
                              height: 70,
                              margin: const EdgeInsets.only(top: 10, right: 10),
                              decoration: BoxDecoration(
                                  border:
                                      Border.all(width: 1, color: Colors.grey)),
                              child: Container(
                                child: _imageUrlController.text.isEmpty
                                    ? const Text(
                                        'Enter Url',
                                        textAlign: TextAlign.center,
                                      )
                                    : Image.network(
                                        _imageUrlController.text,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                            Expanded(
                              child: TextFormField(
                                decoration: const InputDecoration(
                                    labelText: 'ImageUrl'),
                                textInputAction: TextInputAction.done,
                                keyboardType: TextInputType.url,
                                controller: _imageUrlController,
                                focusNode: _imageNode,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter a value.';
                                  } else if (!value.contains('http') &&
                                      !value.contains('https')) {
                                    return 'A url must starts with http or https';
                                  } else if (!value.endsWith('.jpg') &&
                                      !value.endsWith('.png') &&
                                      !value.endsWith('.jpeg')) {
                                    return 'A url must ends with .jpg, .png or .jpeg';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _editingProduct = Product(
                                    id: _editingProduct.id,
                                    isFav: _editingProduct.isFav,
                                    title: _editingProduct.title,
                                    description: _editingProduct.description,
                                    price: _editingProduct.price,
                                    imageUrl: value!,
                                  );
                                },
                                onFieldSubmitted: (_) => _saveForm,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              )),
    );
  }
}
