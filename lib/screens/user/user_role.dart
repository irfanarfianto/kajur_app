import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageUserRolePage extends StatefulWidget {
  const ManageUserRolePage({Key? key}) : super(key: key);

  @override
  _ManageUserRolePageState createState() => _ManageUserRolePageState();
}

class _ManageUserRolePageState extends State<ManageUserRolePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _userRole;

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
          // Handle the case where 'role' field doesn't exist in the user document.
          setState(() {
            _userRole = 'biasa';
          });
        }
      }
    } catch (e) {
      print('Error getting user role: $e');
      // Handle the error by setting _userRole to a default value or displaying an error message.
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

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            var user = users[index];
            var userId = user.id;

            // Periksa keberadaan field role
            var role = user['role'] ?? 'biasa';
            var displayName = user['displayName'] ?? 'No Name';
            var email = user['email'];

            return ListTile(
              title: Text(displayName),
              subtitle: Text(email),
              trailing: DropdownButton<String>(
                value: role,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    _updateUserRole(userId, newValue);
                  }
                },
                items: <String>['admin', 'staf', 'biasa'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildUnauthorizedPage() {
    return Center(
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
}
