import 'package:flutter/material.dart';
import 'package:kajur_app/utils/design/system.dart';

void showSortingOverlay(BuildContext context, String activeSortingCriteria,
    Function(String) setSortingCriteria) {
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
                title: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '🆕 Baru ditambahkan',
                      style: TextStyle(
                        fontWeight: activeSortingCriteria == 'terbaru'
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    if (activeSortingCriteria == 'terbaru')
                      const Icon(Icons.check, color: Col.primaryColor),
                  ],
                ),
                onTap: () {
                  setSortingCriteria('terbaru');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '🙌 Sudah lama',
                      style: TextStyle(
                        fontWeight: activeSortingCriteria == 'terlama'
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    if (activeSortingCriteria == 'terlama')
                      const Icon(Icons.check, color: Col.primaryColor),
                  ],
                ),
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
                title: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Urutan A-Z',
                      style: TextStyle(
                        fontWeight: activeSortingCriteria == 'A-Z'
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    if (activeSortingCriteria == 'A-Z')
                      const Icon(Icons.check, color: Col.primaryColor),
                  ],
                ),
                onTap: () {
                  setSortingCriteria('A-Z');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Urutan Z-A',
                      style: TextStyle(
                        fontWeight: activeSortingCriteria == 'Z-A'
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    if (activeSortingCriteria == 'Z-A')
                      const Icon(Icons.check, color: Col.primaryColor),
                  ],
                ),
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
                title: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Stok Terendah',
                      style: TextStyle(
                        fontWeight: activeSortingCriteria == 'stok terendah'
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    if (activeSortingCriteria == 'stok terendah')
                      const Icon(Icons.check, color: Col.primaryColor),
                  ],
                ),
                onTap: () {
                  setSortingCriteria('stok terendah');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Stok Terbanyak',
                      style: TextStyle(
                        fontWeight: activeSortingCriteria == 'stok terbanyak'
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    if (activeSortingCriteria == 'stok terbanyak')
                      const Icon(Icons.check, color: Col.primaryColor),
                  ],
                ),
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
