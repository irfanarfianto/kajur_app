import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kajur_app/design/system.dart';
import 'package:kajur_app/global/common/toast.dart';
import 'package:kajur_app/screens/menu_button.dart';
import 'package:kajur_app/screens/products/add_products.dart';
import 'package:kajur_app/screens/products/list_products.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:kajur_app/screens/products/stok.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late User? _currentUser;
  int totalProducts = 0;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _fetchTotalProducts();
  }

  Future<void> _fetchTotalProducts() async {
    int total = await getTotalProducts();
    setState(() {
      totalProducts = total;
    });
  }

  Future<int> getTotalProducts() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('kantin').get();

      return querySnapshot.size;
    } catch (e) {
      print('Error: $e');
      return 0;
    }
  }

  Future<void> _getCurrentUser() async {
    _currentUser = FirebaseAuth.instance.currentUser;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text("Manajemen Kajur"),
          actions: [
            Builder(
              builder: (context) => GestureDetector(
                onTap: () {
                  Scaffold.of(context).openEndDrawer();
                },
                child: Container(
                  margin: EdgeInsets.only(right: 10),
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  alignment: Alignment.center,
                  child: _currentUser != null
                      ? Text(
                          "${_currentUser!.displayName}",
                          style: TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: 15,
                            color: DesignSystem.blackColor,
                          ),
                        )
                      : CircularProgressIndicator(), // Show loading indicator while fetching user data
                ),
              ),
            ),
          ],
        ),
        endDrawer: Drawer(
          // Define the drawer with user profile details
          child: _buildDrawer(),
        ),
        body: Column(
          children: [
            Center(
              child: Container(
                padding: EdgeInsets.all(20),
                margin: EdgeInsets.all(20),
                width: 500,
                decoration: BoxDecoration(
                  color: DesignSystem.greyColor.withOpacity(.20),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: DesignSystem.greyColor.withOpacity(.20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Total Produk",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: DesignSystem.blackColor,
                            ),
                          ),
                          SizedBox(height: 8),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                PageRouteBuilder(
                                  pageBuilder: (context, animation,
                                          secondaryAnimation) =>
                                      ListProdukPage(),
                                  transitionsBuilder: (context, animation,
                                      secondaryAnimation, child) {
                                    const begin = Offset(1.0, 0.0);
                                    const end = Offset.zero;
                                    const curve = Curves.ease;

                                    var tween =
                                        Tween(begin: begin, end: end).chain(
                                      CurveTween(curve: curve),
                                    );

                                    return SlideTransition(
                                      position: animation.drive(tween),
                                      child: child,
                                    );
                                  },
                                ),
                              );
                            },
                            child: Container(
                              width: 310,
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: DesignSystem.orangeAccent,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection('kantin')
                                        .snapshots(),
                                    builder: (BuildContext context,
                                        AsyncSnapshot<QuerySnapshot> snapshot) {
                                      if (snapshot.hasError) {
                                        return Text('Error: ${snapshot.error}');
                                      }
                                      switch (snapshot.connectionState) {
                                        case ConnectionState.waiting:
                                          return CircularProgressIndicator();
                                        default:
                                          int totalProducts =
                                              snapshot.data!.size;
                                          int totalFoodProducts = snapshot
                                              .data!.docs
                                              .where((doc) =>
                                                  doc['kategori'] == 'Makanan')
                                              .toList()
                                              .length;
                                          int totalDrinkProducts = snapshot
                                              .data!.docs
                                              .where((doc) =>
                                                  doc['kategori'] == 'Minuman')
                                              .toList()
                                              .length;
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    '$totalProducts',
                                                    style: TextStyle(
                                                      fontSize: 30,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: DesignSystem
                                                          .whiteColor,
                                                    ),
                                                  ),
                                                  SizedBox(width: 5),
                                                  Text('Produk',
                                                      style: TextStyle(
                                                          fontSize: 22,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: DesignSystem
                                                              .whiteColor))
                                                ],
                                              ),
                                              Divider(
                                                  color: DesignSystem.whiteColor
                                                      .withOpacity(.20)),
                                              Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Icon(Icons.restaurant,
                                                            color: DesignSystem
                                                                .whiteColor,
                                                            size: 20),
                                                        SizedBox(width: 5),
                                                        Text(
                                                          '$totalFoodProducts Makanan',
                                                          style: TextStyle(
                                                            fontSize: 15,
                                                            color: DesignSystem
                                                                .whiteColor,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        Icon(Icons.local_cafe,
                                                            color: DesignSystem
                                                                .whiteColor,
                                                            size: 20),
                                                        SizedBox(width: 5),
                                                        Text(
                                                          '$totalDrinkProducts Minuman',
                                                          style: TextStyle(
                                                            fontSize: 15,
                                                            color: DesignSystem
                                                                .whiteColor,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ]),
                                            ],
                                          );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            Column(
              children: [
                Center(
                  child: Container(
                    padding: EdgeInsets.all(20),
                    width: 500,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pemberitahuan 📢',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: DesignSystem.blackColor,
                          ),
                        ),
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('kantin')
                              .snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            }

                            switch (snapshot.connectionState) {
                              case ConnectionState.waiting:
                                return CircularProgressIndicator();
                              default:
                                if (snapshot.data!.docs.isEmpty) {
                                  return Text('Belum ada info baru');
                                }
                                return Column(
                                  children: snapshot.data!.docs
                                      .map((DocumentSnapshot document) {
                                    Map<String, dynamic> data =
                                        document.data() as Map<String, dynamic>;
                                    String namaProduk = data['menu'];
                                    int stok = data['stok'];
                                    String documentId = document.id;

                                    if (stok == 0) {
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  EditStockPage(
                                                namaProduk: namaProduk,
                                                stok: stok,
                                                documentId: documentId,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 20),
                                          margin: EdgeInsets.symmetric(
                                              vertical: 10),
                                          decoration: BoxDecoration(
                                            color: Colors.red.withOpacity(.10),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                              color:
                                                  Colors.red.withOpacity(.50),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  'Produk $namaProduk sudah habis!',
                                                  style: TextStyle(
                                                    color:
                                                        DesignSystem.blackColor,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      );
                                    } else if (stok <= 10 && stok > 4) {
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  EditStockPage(
                                                namaProduk: namaProduk,
                                                stok: stok,
                                                documentId: documentId,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 20),
                                          margin: EdgeInsets.symmetric(
                                              vertical: 10),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.yellow.withOpacity(.30),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                              color: Colors.yellow
                                                  .withOpacity(.20),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  'Pantau terus! $namaProduk sisa $stok, segera restock ya!',
                                                  style: TextStyle(
                                                    color:
                                                        DesignSystem.blackColor,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    } else if (stok < 5) {
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  EditStockPage(
                                                namaProduk: namaProduk,
                                                stok: stok,
                                                documentId: documentId,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 20),
                                          margin: EdgeInsets.symmetric(
                                              vertical: 10),
                                          decoration: BoxDecoration(
                                            color: Colors.red.withOpacity(.10),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                              color:
                                                  Colors.red.withOpacity(.20),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  'Woy! $namaProduk mau abis, sisa $stok!',
                                                  style: TextStyle(
                                                    color:
                                                        DesignSystem.blackColor,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    } else {
                                      return SizedBox(); // Jika stok tidak rendah atau sedang, kembalikan SizedBox kosong
                                    }
                                  }).toList(),
                                );
                            }
                          },
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: DesignSystem.purpleAccent,
          elevation: 10,
          tooltip: 'Menu',
          foregroundColor: Colors.white,
          splashColor: DesignSystem.purpleAccent,
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return MenuButton();
              },
            );
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          icon: Icon(Icons.menu_rounded,
              color: DesignSystem.whiteColor, size: 20),
          label: Text('Menu',
              style: TextStyle(color: DesignSystem.whiteColor, fontSize: 16)),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        DrawerHeader(
          decoration: BoxDecoration(
            color: DesignSystem.primaryColor,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(height: 10),
              _currentUser != null
                  ? Text(
                      "${_currentUser!.displayName}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    )
                  : CircularProgressIndicator(), // Show loading indicator while fetching user data
              SizedBox(height: 5),
              _currentUser != null
                  ? Text(
                      "${_currentUser!.email}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    )
                  : CircularProgressIndicator(), // Show loading indicator while fetching user data
            ],
          ),
        ),
        ListTile(
          title: Text('Tambah Produk'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddDataPage()),
            );
          },
        ),
        ListTile(
          title: Text('Daftar Produk'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ListProdukPage()),
            );
          },
        ),
        SizedBox(height: 350),
        Container(
          margin: EdgeInsets.only(left: 10, right: 10),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              primary: DesignSystem.redAccent,
            ),
            onPressed: () {
              _confirmSignOut();
            },
            label: Text('Keluar'),
            icon: Icon(Icons.exit_to_app),
          ),
        ),
      ],
    );
  }

  void _confirmSignOut() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Sign Out"),
          content: Text("Are you sure you want to sign out?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _signOut(); // Perform sign-out action
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Sign Out"),
            ),
          ],
        );
      },
    );
  }

  void _signOut() async {
    try {
      await _googleSignIn.signOut();
      await FirebaseAuth.instance.signOut();
      Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
      showToast(message: "Successfully signed out");
    } catch (e) {
      showToast(message: "Error signing out: $e");
    }
  }
}
