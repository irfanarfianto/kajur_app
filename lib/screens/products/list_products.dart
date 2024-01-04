import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kajur_app/design/system.dart';
import 'package:kajur_app/screens/products/edit_products.dart';

class ListProdukPage extends StatefulWidget {
  @override
  _ListProdukPageState createState() => _ListProdukPageState();
}

class _ListProdukPageState extends State<ListProdukPage> {
  late CollectionReference _produkCollection;
  late bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _produkCollection = FirebaseFirestore.instance.collection('kantin');
  }

  Future<void> _deleteProduct(String documentId) async {
    await _produkCollection.doc(documentId).delete();
  }

  Future<void> _refreshData() async {
    setState(() {
      _isRefreshing = true;
    });

    // Perform fetching or refreshing data here
    // For example, refetch Firestore data
    await Future.delayed(Duration(seconds: 2)); // Simulating a delay

    setState(() {
      _isRefreshing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('List Produk'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: StreamBuilder<QuerySnapshot>(
          stream: _produkCollection.snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting ||
                _isRefreshing) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text('No Products Available',
                    style: TextStyle(color: DesignSystem.whiteColor)),
              );
            }

            return ListView(
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;
                String documentId = document.id;
                Timestamp createdAt = data['createdAt'] ?? Timestamp.now();
                Timestamp updatedAt = data['updatedAt'] ?? Timestamp.now();

                return ListTile(
                  title: Text(
                    data['menu'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: DesignSystem.whiteColor,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Harga: ${data['harga']}',
                        style: TextStyle(
                          color: DesignSystem.whiteColor,
                        ),
                      ),
                      Text(
                        'Created At: ${createdAt.toDate()}',
                        style: TextStyle(
                          color: DesignSystem.whiteColor,
                        ),
                      ),
                      Text(
                        'Updated At: ${updatedAt.toDate()}',
                        style: TextStyle(
                          color: DesignSystem.whiteColor,
                        ),
                      ),
                    ],
                  ),
                  leading: Image.network(
                    data['image'],
                    height: 50,
                    width: 50,
                    fit: BoxFit.cover,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProdukPage(
                                documentId: documentId,
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Delete Product'),
                                content: Text(
                                    'Are you sure you want to delete this product?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      _deleteProduct(documentId);
                                      Navigator.pop(context);
                                    },
                                    child: Text('Delete'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}
