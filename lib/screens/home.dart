import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kajur_app/design/system.dart';
import 'package:kajur_app/global/common/toast.dart';
import 'package:kajur_app/screens/products/add_products.dart';
import 'package:kajur_app/screens/products/list_products.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:kajur_app/screens/products/stok.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late User? _currentUser;
  int totalProducts = 0;

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
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Kantin Kejujuaran"),
        actions: [
          Builder(
            builder: (context) => GestureDetector(
              onTap: () {
                Scaffold.of(context).openEndDrawer(); // Open the drawer
              },
              child: Container(
                margin: EdgeInsets.only(right: 20),
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                alignment: Alignment.center,
                child: _currentUser != null
                    ? Text(
                        "${_currentUser!.displayName}",
                        style: TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: 15,
                          color: DesignSystem.whiteColor,
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
                  )),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: 150,
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: DesignSystem.purpleAccent.withOpacity(.10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Saldo",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: DesignSystem.whiteColor,
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          width: 150,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: DesignSystem.purpleAccent,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Total Saldo",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: DesignSystem.whiteColor,
                                ),
                              ),
                              Text(
                                "Rp 5.000.000",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: DesignSystem.whiteColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10),
                  Container(
                    width: 150,
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: DesignSystem.orangeAccent.withOpacity(.10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Total Produk",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: DesignSystem.whiteColor,
                          ),
                        ),
                        SizedBox(height: 8),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
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
                            width: 150,
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: DesignSystem.orangeAccent,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Total Produk",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: DesignSystem.whiteColor,
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
                                        return Text(
                                          snapshot.data!.size.toString(),
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: DesignSystem.whiteColor,
                                          ),
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
                        'Pemberitahuan',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: DesignSystem.whiteColor,
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
                              return Column(
                                children: snapshot.data!.docs
                                    .map((DocumentSnapshot document) {
                                  Map<String, dynamic> data =
                                      document.data() as Map<String, dynamic>;
                                  String namaProduk = data['menu'];
                                  int stok = data['stok'];
                                  String documentId = document.id;

                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => EditStockPage(
                                            namaProduk: namaProduk,
                                            stok: stok,
                                            documentId: documentId,
                                          ),
                                        ),
                                      );
                                    },
                                    child: stok <= 10 && stok > 5
                                        ? Container(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 20),
                                            margin: EdgeInsets.symmetric(
                                                vertical: 10),
                                            decoration: BoxDecoration(
                                              color: Colors.yellow
                                                  .withOpacity(.10),
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
                                                Text(
                                                  'Pantau terus! $namaProduk sisa $stok, segera restock ya!',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : stok < 5
                                            ? Container(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 10,
                                                    horizontal: 20),
                                                margin: EdgeInsets.symmetric(
                                                    vertical: 10),
                                                decoration: BoxDecoration(
                                                  color: Colors.red
                                                      .withOpacity(.10),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  border: Border.all(
                                                    color: Colors.red
                                                        .withOpacity(.20),
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Woy! $namaProduk mau abis, sisa $stok!',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            : SizedBox(), // If stock is not low or medium, return an empty SizedBox
                                  );
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
      floatingActionButton: SpeedDial(
        // Both default and active icon can be set separately
        animatedIcon: AnimatedIcons.menu_close,
        animatedIconTheme: IconThemeData(size: 22.0),
        // This is ignored if animatedIcon is non-null
        icon: Icons.add,
        activeIcon: Icons.close,
        buttonSize: Size(56.0, 56.0),
        visible: true,
        closeManually: false,
        curve: Curves.bounceIn,
        overlayColor: Colors.black,
        overlayOpacity: 0.5,
        onOpen: () => print('Opening dial'),
        onClose: () => print('Dial closed'),
        tooltip: 'Speed Dial',
        heroTag: 'speed-dial-hero-tag',
        backgroundColor: Colors.purpleAccent,
        foregroundColor: Colors.white,
        elevation: 8.0,
        shape: CircleBorder(),
        children: [
          SpeedDialChild(
            child: Icon(Icons.add),
            // backgroundColor: DesignSystem.whiteColor,
            label: 'Tambah Produk',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddDataPage()),
              );
            },
            shape: CircleBorder(),
          ),
          SpeedDialChild(
            child: Icon(Icons.arrow_downward_outlined),
            backgroundColor: DesignSystem.whiteColor,
            label: 'Pemasukan',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () => print('Second action'),
            shape: CircleBorder(),
          ),
          SpeedDialChild(
            child: Icon(Icons.arrow_upward_outlined),
            backgroundColor: DesignSystem.whiteColor,
            label: 'Pengeluaran',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () => print('Second action'),
            shape: CircleBorder(),
          ),
          // Add more SpeedDialChild widgets for additional actions
        ],
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
      await FirebaseAuth.instance.signOut();
      Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
      showToast(message: "Successfully signed out");
    } catch (e) {
      showToast(message: "Error signing out: $e");
    }
  }
}
