import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kajur_app/design/system.dart';
import 'package:kajur_app/global/common/toast.dart';
import 'package:kajur_app/screens/aktivitas/aktivitas.dart';
import 'package:kajur_app/screens/menu_button.dart';
import 'package:intl/intl.dart';
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
        // notification icon
        IconButton(
            onPressed: () {
              // TODO: implement notification icon
              Navigator.pushNamed(context, '/comingsoon');
            },
            icon: Icon(
              Icons.notifications_none_outlined,
            ))
      ],
    );
  }

  Widget _buildUserWidget() {
    if (_currentUser == null) {
      return CircularProgressIndicator(
        color: DesignSystem.whiteColor,
      );
    } else {
      return Container(
        alignment: Alignment.topLeft,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              child: CircleAvatar(
                backgroundImage: AssetImage('images/avatar.png'),
              ),
            ),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${_currentUser!.displayName}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: DesignSystem.whiteColor,
                  ),
                ),
                Skeleton.leaf(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    alignment: Alignment.center,
                    height: 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: DesignSystem.greyColor.withOpacity(.50),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.email,
                          color: Colors.white,
                          size: 12,
                        ),
                        SizedBox(width: 2),
                        Text(
                          "${_currentUser!.email}",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      );
    }
  }

  Widget _buildDrawer() {
    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        _buildDrawerHeader(),
        Spacer(),
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

  // Fungsi untuk mendapatkan ikon berdasarkan nilai action
  Icon _getActionIcon(String? action) {
    IconData iconData;
    Color iconColor;

    switch (action) {
      case 'Tambah Produk':
        iconData = Icons.add;
        iconColor = Colors.green;
        break;
      case 'Edit Produk':
        iconData = Icons.edit;
        iconColor = Colors.orange;
        break;
      case 'Hapus Produk':
        iconData = Icons.delete;
        iconColor = Colors.red;
        break;
      default:
        iconData = Icons.error;
        iconColor = Colors.grey;
    }

    return Icon(
      iconData,
      color: iconColor,
    );
  }

  // Fungsi untuk mendapatkan warna latar belakang ikon berdasarkan nilai action
  Color _getActionIconBackgroundColor(String? action) {
    Color backgroundColor;

    switch (action) {
      case 'Tambah Produk':
        backgroundColor = Colors.green.withOpacity(0.1);
        break;
      case 'Edit Produk':
        backgroundColor = Colors.orange.withOpacity(0.1);
        break;
      case 'Hapus Produk':
        backgroundColor = Colors.red.withOpacity(0.1);
        break;
      default:
        backgroundColor = Colors.grey.withOpacity(0.1);
    }

    return backgroundColor;
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Text("Konfirmasi"),
          content: Text("Aapakah kamu yakin untuk keluar?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Cancel",
                  style: TextStyle(color: DesignSystem.greyColor)),
            ),
            TextButton(
              onPressed: () {
                _signOut(); // Perform sign-out action
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Keluar",
                  style: TextStyle(color: DesignSystem.redAccent)),
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
      showToast(message: "Berhasil keluar");
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
        floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return MenuButton();
                },
              );
            },
            extendedPadding: EdgeInsets.symmetric(horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
            backgroundColor: DesignSystem.primaryColor,
            foregroundColor: DesignSystem.whiteColor,
            icon: Icon(Icons.rocket_launch_outlined),
            label: Text('Menu',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ))),
      ),
    );
  }

  Widget _buildTotalProductsWidget() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Center(
        child: Container(
          width: double.infinity,
          height: 260,
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
          padding: EdgeInsets.all(16),
          child: Stack(
            children: [
              Column(
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
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Builder(
                                      builder: (context) => GestureDetector(
                                        onTap: () {
                                          Scaffold.of(context).openEndDrawer();
                                        },
                                        child: _buildUserWidget(),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Divider(
                                        color: DesignSystem.whiteColor
                                            .withOpacity(.20)),
                                    SizedBox(height: 5),
                                    Text(
                                      'Total Produk $totalProducts',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: DesignSystem.whiteColor,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Expanded(
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 10),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                border: Border.all(
                                                  color: DesignSystem.whiteColor
                                                      .withOpacity(.20),
                                                )),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.restaurant,
                                                      color: DesignSystem
                                                          .whiteColor,
                                                      size: 25,
                                                    ),
                                                    SizedBox(width: 5),
                                                    Text(
                                                      '$totalFoodProducts',
                                                      style: TextStyle(
                                                        fontSize: 25,
                                                        color: DesignSystem
                                                            .whiteColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Text(
                                                  'Makanan',
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color:
                                                        DesignSystem.whiteColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 10),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                border: Border.all(
                                                  color: DesignSystem.whiteColor
                                                      .withOpacity(.20),
                                                )),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.local_cafe_outlined,
                                                      color: DesignSystem
                                                          .whiteColor,
                                                      size: 25,
                                                    ),
                                                    SizedBox(width: 5),
                                                    Text(
                                                      '$totalDrinkProducts',
                                                      style: TextStyle(
                                                        fontSize: 25,
                                                        color: DesignSystem
                                                            .whiteColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Text(
                                                  'Minuman',
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color:
                                                        DesignSystem.whiteColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            );
                        }
                      })
                ],
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            ListProdukPage(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
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
                  child: Skeleton.leaf(
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: DesignSystem.whiteColor.withOpacity(.20),
                      ),
                      child: Row(
                        children: [
                          Text(
                            "Lihat semua",
                            style: TextStyle(
                              color: DesignSystem.whiteColor,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          SizedBox(width: 5),
                          Icon(
                            Icons.east,
                            color: DesignSystem.whiteColor,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
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
                  height: 150,
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
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      AllActivitiesPage(),
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
                SizedBox(height: 5),
                Container(
                  height: 300,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('activity_log')
                        .orderBy('timestamp', descending: true)
                        .limit(5)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: DesignSystem.primaryColor,
                          ),
                        );
                      }

                      if (snapshot.data == null ||
                          snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Text('Tidak ada aktivitas terbaru'),
                        );
                      }

                      return Scrollbar(
                        child: ListView(
                          children:
                              snapshot.data!.docs.map((DocumentSnapshot doc) {
                            Map<String, dynamic> data =
                                doc.data() as Map<String, dynamic>;

                            return Column(
                              children: [
                                ListTile(
                                  leading: Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _getActionIconBackgroundColor(
                                          data['action']),
                                    ),
                                    child: _getActionIcon(data['action']),
                                  ),
                                  title: Flexible(
                                    child: Text(
                                      (data['action'] ?? '') +
                                          (data['productName'] != null
                                              ? ' - ${data['productName']}'
                                              : ''),
                                      maxLines: 1, // Hanya satu baris
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  subtitle: Text(
                                    (data['userName'] ?? '') +
                                        ' pada ' +
                                        (data['timestamp'] != null
                                            ? DateFormat(
                                                    'dd MMMM y • HH:mm ', 'id')
                                                .format((data['timestamp']
                                                        as Timestamp)
                                                    .toDate())
                                            : 'Timestamp tidak tersedia'),
                                    style: TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                Divider(
                                  color:
                                      DesignSystem.greyColor.withOpacity(.10),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
