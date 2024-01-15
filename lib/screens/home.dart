import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kajur_app/design/system.dart';
import 'package:kajur_app/global/common/toast.dart';
import 'package:kajur_app/screens/menu_button.dart';
import 'package:kajur_app/screens/products/add_products.dart';
import 'package:kajur_app/screens/products/list_products.dart';
import 'package:flutter/services.dart';
import 'package:kajur_app/screens/products/stok/stok_produk.dart';
import 'package:skeletonizer/skeletonizer.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late User? _currentUser;
  int totalProducts = 0;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  bool _enabled = false;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _fetchTotalProducts();
    _refreshData();
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

  Future<void> _refreshData() async {
    try {
      setState(() {
        _enabled = true;
      });

      // Simulate fetching new data from your data source
      await Future.delayed(Duration(seconds: 2));

      // After fetching new data, you can setState or update your variables
      // Example: setState(() { yourData = fetchedData; });
    } catch (error) {
      // Handle error if it occurs during data refresh
      print('Error refreshing data: $error');
    } finally {
      setState(() {
        _enabled = false;
      });
    }
  }

  Future<void> _getCurrentUser() async {
    _currentUser = FirebaseAuth.instance.currentUser;
    setState(() {});
  }

  Widget _buildAppBar() {
    return AppBar(
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      title: Text("Manajemen Kajur"),
      actions: [
        Builder(
          builder: (context) => GestureDetector(
            onTap: () {
              Scaffold.of(context).openEndDrawer();
            },
            child: _buildUserWidget(),
          ),
        ),
      ],
    );
  }

  Widget _buildUserWidget() {
    if (_currentUser == null) {
      return CircularProgressIndicator();
    } else {
      return Container(
        margin: EdgeInsets.only(right: 10),
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        alignment: Alignment.center,
        child: Text(
          "${_currentUser!.displayName}",
          style: TextStyle(
            fontWeight: FontWeight.w300,
            fontSize: 15,
            color: DesignSystem.blackColor,
          ),
        ),
      );
    }
  }

  Widget _buildDrawer() {
    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        _buildDrawerHeader(),
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
            style: ElevatedButton.styleFrom(primary: DesignSystem.redAccent),
            onPressed: _confirmSignOut,
            label: Text('Keluar'),
            icon: Icon(Icons.exit_to_app),
          ),
        ),
      ],
    );
  }

  Widget _buildDrawerHeader() {
    return DrawerHeader(
      decoration: BoxDecoration(color: DesignSystem.primaryColor),
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return true;
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: _buildAppBar(),
        ),
        endDrawer: Drawer(child: _buildDrawer()),
        body: Stack(
          children: [
            RefreshIndicator(
              color: DesignSystem.primaryColor,
              onRefresh: _refreshData,
              child: Skeletonizer(
                enabled: _enabled,
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      _buildTotalProductsWidget(),
                      _buildStockWidget(),
                      _buildRecentActivityWidget(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          color: Colors.transparent,
          elevation: 0,
          shape: const CircularNotchedRectangle(),
          clipBehavior: Clip.antiAlias,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                )),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return MenuButton();
                    },
                  );
                },
                child: Row(
                  children: [
                    Text(
                      'Menu',
                      style: TextStyle(
                        color: DesignSystem.whiteColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.rocket_launch_outlined),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTotalProductsWidget() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Center(
        child: Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: DesignSystem.primaryColor,
            border: Border.all(color: DesignSystem.greyColor.withOpacity(.10)),
            boxShadow: [
              BoxShadow(
                color: DesignSystem.greyColor.withOpacity(.10),
                offset: Offset(0, 5),
                blurRadius: 10,
              ),
            ],
          ),
          padding: EdgeInsets.all(20),
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
                        int totalProducts = snapshot.data!.size;
                        int totalFoodProducts = snapshot.data!.docs
                            .where((doc) => doc['kategori'] == 'Makanan')
                            .toList()
                            .length;
                        int totalDrinkProducts = snapshot.data!.docs
                            .where((doc) => doc['kategori'] == 'Minuman')
                            .toList()
                            .length;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  '$totalProducts',
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    color: DesignSystem.whiteColor,
                                  ),
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'Produk',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: DesignSystem.whiteColor,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 65,
                            ),
                            Divider(
                                color:
                                    DesignSystem.whiteColor.withOpacity(.20)),
                            SizedBox(height: 10),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ListProdukPage()));
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.restaurant,
                                        color: DesignSystem.whiteColor,
                                        size: 20,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        '$totalFoodProducts Makanan',
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: DesignSystem.whiteColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.local_cafe,
                                        color: DesignSystem.whiteColor,
                                        size: 20,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        '$totalDrinkProducts Minuman',
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: DesignSystem.whiteColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          ],
                        );
                    }
                  })
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStockWidget() {
    return Column(
      children: [
        Center(
          child: Container(
            margin: EdgeInsets.all(16.0),
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: DesignSystem.backgroundColor,
              border:
                  Border.all(color: DesignSystem.greyColor.withOpacity(.10)),
              boxShadow: [
                BoxShadow(
                  color: DesignSystem.greyColor.withOpacity(.10),
                  offset: Offset(0, 5),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Info Stok 📢',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: DesignSystem.blackColor,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      StockPage(),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                const begin = Offset(1.0, 0.0);
                                const end = Offset.zero;
                                const curve = Curves.easeInOut;

                                var tween = Tween(begin: begin, end: end).chain(
                                  CurveTween(curve: curve),
                                );

                                var offsetAnimation = animation.drive(tween);

                                return SlideTransition(
                                  position: offsetAnimation,
                                  child: child,
                                );
                              },
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            Text(
                              "Lihat semua",
                              style: TextStyle(
                                color: DesignSystem.blackColor,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            SizedBox(width: 5),
                            Icon(
                              Icons.east,
                              color: DesignSystem.blackColor,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  height: 200,
                  child: Scrollbar(
                    child: SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('kantin')
                                .snapshots(),
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.hasError) {
                                return Center(
                                  child: Text('Error: ${snapshot.error}'),
                                );
                              }

                              switch (snapshot.connectionState) {
                                case ConnectionState.waiting:
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                default:
                                  if (snapshot.data!.docs.isEmpty) {
                                    return Column(
                                      children: [
                                        Center(
                                          child: Text(
                                            'Belum ada info stok',
                                            style: TextStyle(
                                                color: DesignSystem.blackColor),
                                          ),
                                        ),
                                      ],
                                    );
                                  }

                                  List<Widget> stockWidgets = snapshot
                                      .data!.docs
                                      .map((DocumentSnapshot document) {
                                    Map<String, dynamic> data =
                                        document.data() as Map<String, dynamic>;
                                    String namaProduk = data['menu'];
                                    int stok = data['stok'];

                                    if (stok == 0) {
                                      return Skeleton.leaf(
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 20),
                                          margin:
                                              EdgeInsets.symmetric(vertical: 5),
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
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    } else if (stok <= 10 && stok > 4) {
                                      return Skeleton.leaf(
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 20),
                                          margin:
                                              EdgeInsets.symmetric(vertical: 5),
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
                                      return Skeleton.leaf(
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 20),
                                          margin:
                                              EdgeInsets.symmetric(vertical: 5),
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
                                    }

                                    return SizedBox.shrink();
                                  }).toList();

                                  return Column(
                                    children: stockWidgets,
                                  );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivityWidget() {
    return Column(
      children: [
        Center(
          child: Container(
            margin: EdgeInsets.all(16.0),
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: DesignSystem.backgroundColor,
              border:
                  Border.all(color: DesignSystem.greyColor.withOpacity(.10)),
              boxShadow: [
                BoxShadow(
                  color: DesignSystem.greyColor.withOpacity(.10),
                  offset: Offset(0, 5),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Aktivitas Terbaru',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: DesignSystem.blackColor,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/comingsoon');
                        },
                        child: Row(
                          children: [
                            Text(
                              "Lihat semua",
                              style: TextStyle(
                                color: DesignSystem.blackColor,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            SizedBox(width: 5),
                            Icon(
                              Icons.east,
                              color: DesignSystem.blackColor,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 5),
                Container(
                  height: 200,
                  // isi aktivitas user
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
