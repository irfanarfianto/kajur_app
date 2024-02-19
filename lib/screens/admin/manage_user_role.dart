import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kajur_app/utils/design/system.dart';

class ManageUserRolePage extends StatefulWidget {
  const ManageUserRolePage({super.key});

  @override
  _ManageUserRolePageState createState() => _ManageUserRolePageState();
}

class _ManageUserRolePageState extends State<ManageUserRolePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _userRole;
  List<String> selectedUsers = [];
  Map<String, String> dropdownValues = {};

  @override
  void initState() {
    super.initState();
    _getUserRole();
  }

  Future<void> _getUserRole() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (userData.exists) {
          setState(() {
            _userRole = userData['role'] ?? 'biasa';
          });
        } else {
          setState(() {
            _userRole = 'biasa';
          });
        }
      }
    } catch (e) {
      print('Error getting user role: $e');
      setState(() {
        _userRole = 'biasa';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: const ScrollBehavior().copyWith(overscroll: true),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Kelola Peran Pengguna'),
          actions: [
            if (selectedUsers.isNotEmpty)
              IconButton(
                onPressed: () {
                  // Handle delete action
                  _confirmDeleteSelectedUsers();
                },
                icon: const Icon(Icons.delete),
              ),
          ],
        ),
        body: _userRole == null
            ? const Center(child: CircularProgressIndicator())
            : _userRole == 'admin'
                ? _buildAdminPage()
                : _buildUnauthorizedPage(),
      ),
    );
  }

  Widget _buildAdminPage() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('users').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Terjadi kesalahan: ${snapshot.error}'),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('Tidak ada data pengguna.'),
          );
        }

        var users = snapshot.data!.docs;

        // Mengelompokkan pengguna berdasarkan peran
        var adminUsers = <DocumentSnapshot>[];
        var staffUsers = <DocumentSnapshot>[];
        var normalUsers = <DocumentSnapshot>[];

        for (var user in users) {
          var role = user['role'] ?? 'biasa';
          if (role == 'admin') {
            adminUsers.add(user);
          } else if (role == 'staf') {
            staffUsers.add(user);
          } else {
            normalUsers.add(user);
          }
        }

        return ListView.builder(
          itemCount:
              adminUsers.length + staffUsers.length + normalUsers.length + 2,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Divider(
                thickness: 1,
                color: Col.greyColor.withOpacity(0.1),
              );
            }
            if (index == adminUsers.length + 1) {
              return Divider(
                thickness: 1,
                color: Col.greyColor.withOpacity(0.1),
              );
            }
            if (index == adminUsers.length + staffUsers.length + 2) {
              return Divider(
                thickness: 1,
                color: Col.greyColor.withOpacity(0.1),
              );
            }
            DocumentSnapshot<Object?> user;
            if (index <= adminUsers.length) {
              user = adminUsers[index - 1];
            } else if (index <= adminUsers.length + staffUsers.length + 1) {
              user = staffUsers[index - adminUsers.length - 2];
            } else {
              user = normalUsers[
                  index - adminUsers.length - staffUsers.length - 3];
            }

            var userId = user.id;
            var role = user['role'] ?? 'biasa';
            var displayName = user['displayName'] ?? 'No Name';
            var email = user['email'];
            var username = user['username'] ?? 'No Username';

            Color badgeColor;
            switch (role) {
              case 'admin':
                badgeColor = Colors.red;
                break;
              case 'staf':
                badgeColor = Colors.blue;
                break;
              default:
                badgeColor = Colors.green;
            }

            return ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(displayName),
                      const SizedBox(width: 10),
                      Badge(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        label: Text(role),
                        backgroundColor: badgeColor,
                      ),
                    ],
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (String newValue) {
                      setState(() {
                        dropdownValues[userId] = newValue;
                      });
                      _updateUserRole(userId, newValue);
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'admin',
                        child: Text('Admin'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'staf',
                        child: Text('Staf'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'biasa',
                        child: Text('Biasa'),
                      ),
                    ],
                  ),
                ],
              ),
              subtitle: Text('$username | $email',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Col.greyColor,
                  )),
              tileColor: selectedUsers.contains(userId)
                  ? Colors.grey.withOpacity(0.5)
                  : null,
              onLongPress: () {
                setState(() {
                  if (selectedUsers.contains(userId)) {
                    selectedUsers.remove(userId);
                  } else {
                    selectedUsers.add(userId);
                  }
                });
              },
            );
          },
        );
      },
    );
  }

  Widget _buildUnauthorizedPage() {
    return const Center(
      child: Text('Anda tidak diizinkan mengakses halaman ini.'),
    );
  }

  Future<void> _updateUserRole(String userId, String newRole) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({'role': newRole});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Peran pengguna berhasil diperbarui.'),
        ),
      );
    } catch (e) {
      print('Error updating user role: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terjadi kesalahan saat memperbarui peran pengguna.'),
        ),
      );
    }
  }

  Future<void> _confirmDeleteSelectedUsers() async {
    // Tampilkan dialog konfirmasi penghapusan
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Konfirmasi"),
          content: const Text(
              "Apakah Anda yakin ingin menghapus pengguna terpilih?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteSelectedUsers();
              },
              child: const Text("Hapus"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteSelectedUsers() async {
    try {
      for (var userId in selectedUsers) {
        await _firestore.collection('users').doc(userId).delete();
      }
      setState(() {
        selectedUsers.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pengguna terpilih berhasil dihapus.'),
        ),
      );
    } catch (e) {
      print('Error deleting selected users: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terjadi kesalahan saat menghapus pengguna terpilih.'),
        ),
      );
    }
  }
}
