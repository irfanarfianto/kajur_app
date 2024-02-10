import 'package:flutter/material.dart';
import 'package:kajur_app/design/system.dart';

void showSortingOverlay(
    BuildContext context, Function(String) setSortingCriteria) {
  showModalBottomSheet(
    enableDrag: true,
    isScrollControlled: true,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.6,
    ),
    context: context,
    builder: (BuildContext context) {
      return Column(
        children: [
          const SizedBox(height: 16),
          Container(
            height: 5,
            width: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: Col.greyColor.withOpacity(.50),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Urutkan Berdasarkan', style: Typo.headingTextStyle),
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.close,
                    )),
              ],
            ),
          ),
          SizedBox(
            height: 12,
            child: Divider(
              thickness: 2,
              color: Col.greyColor.withOpacity(0.1),
            ),
          ),
          Wrap(
            children: [
              ListTile(
                title: const Text('🆕 Baru ditambahkan'),
                onTap: () {
                  setSortingCriteria('terbaru');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('🙌 Sudah lama'),
                onTap: () {
                  setSortingCriteria('terlama');
                  Navigator.pop(context);
                },
              ),
              Divider(
                thickness: 1,
                color: Col.greyColor.withOpacity(0.1),
              ),
              ListTile(
                title: const Text('Urutan A-Z'),
                onTap: () {
                  setSortingCriteria('A-Z');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Urutan Z-A'),
                onTap: () {
                  setSortingCriteria('Z-A');
                  Navigator.pop(context);
                },
              ),
              Divider(
                thickness: 1,
                color: Col.greyColor.withOpacity(0.1),
              ),
              ListTile(
                title: const Text('Stok Terendah'),
                onTap: () {
                  setSortingCriteria('stok terendah');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Stok Terbanyak'),
                onTap: () {
                  setSortingCriteria('stok terbanyak');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ],
      );
    },
  );
}
