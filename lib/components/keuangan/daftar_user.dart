import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kajur_app/services/produk/produk_services.dart';
import 'package:kajur_app/utils/design/system.dart';
import 'package:kajur_app/utils/global/common/toast.dart';
import 'package:url_launcher/url_launcher.dart';

class ListUser extends StatelessWidget {
  final ProdukService _produkService = ProdukService();

  ListUser({super.key});

  void openWhatsApp(BuildContext context, String whatsappNumber) async {
    String messageText = "Hello kak";
    String whatsappURL = "https://wa.me/$whatsappNumber?text=$messageText";

    if (await canLaunch(whatsappURL)) {
      await launch(whatsappURL);
    } else {
      showToast(message: "WhatsApp is not installed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _produkService.getAllUserProfiles(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            final List<Map<String, dynamic>> userProfiles = snapshot.data ?? [];

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'Daftar Pengurus',
                    style: Typo.titleTextStyle.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 310,
                    child: ScrollConfiguration(
                      behavior:
                          const ScrollBehavior().copyWith(overscroll: true),
                      child: Scrollbar(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: userProfiles.length,
                                itemBuilder: (context, index) {
                                  final Map<String, dynamic> userProfile =
                                      userProfiles[index];

                                  final String photoUrl =
                                      userProfile['photoUrl'] ?? '';

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 5.0),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        radius: 25,
                                        backgroundColor: Col.greyColor,
                                        backgroundImage: photoUrl.isNotEmpty
                                            ? NetworkImage(photoUrl)
                                            : null,
                                        child: photoUrl.isEmpty
                                            ? const FaIcon(
                                                FontAwesomeIcons.solidUser,
                                                size: 30,
                                                color: Colors.white,
                                              )
                                            : null,
                                      ),
                                      title: Text(userProfile['displayName']),
                                      subtitle: Text(userProfile['email']),
                                      trailing: InkWell(
                                        onTap: () {
                                          if (userProfile
                                              .containsKey('whatsapp')) {
                                            openWhatsApp(
                                                context,
                                                userProfile['whatsapp']
                                                    .toString());
                                          } else {
                                            showToast(
                                                message:
                                                    'User belum memasukan nomor whatsapp');
                                          }
                                        },
                                        child: const FaIcon(
                                          FontAwesomeIcons.whatsapp,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Tutup'),
                  ),
                ],
              ),
            );
          }
        }
      },
    );
  }
}
