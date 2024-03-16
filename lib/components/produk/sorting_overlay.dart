import 'package:flutter/material.dart';
import 'package:kajur_app/utils/design/system.dart';

void showSortingOverlay(BuildContext context, String activeSortingCriteria,
    Function(String) setSortingCriteria) {
  // Menentukan apakah tombol reset harus di-disable
  bool isResetDisabled = activeSortingCriteria == 'default';

  showModalBottomSheet(
    enableDrag: true,
    showDragHandle: true,
    isScrollControlled: true,
    isDismissible: true,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.55,
    ),
    context: context,
    builder: (BuildContext context) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Urutkan Berdasarkan', style: Typo.titleTextStyle),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.close),
                ),
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
          ListTile(
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Baru ditambahkan 🆕',
                    style: Typo.emphasizedBodyTextStyle.copyWith(
                      fontWeight: activeSortingCriteria == 'baru'
                          ? FontWeight.bold
                          : FontWeight.normal,
                    )),
                if (activeSortingCriteria == 'baru')
                  const Icon(Icons.check, color: Col.primaryColor),
              ],
            ),
            onTap: () {
              setSortingCriteria('baru');
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Urutan A-Z',
                    style: Typo.emphasizedBodyTextStyle.copyWith(
                      fontWeight: activeSortingCriteria == 'A-Z'
                          ? FontWeight.bold
                          : FontWeight.normal,
                    )),
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
                Text('Urutan Z-A',
                    style: Typo.emphasizedBodyTextStyle.copyWith(
                      fontWeight: activeSortingCriteria == 'Z-A'
                          ? FontWeight.bold
                          : FontWeight.normal,
                    )),
                if (activeSortingCriteria == 'Z-A')
                  const Icon(Icons.check, color: Col.primaryColor),
              ],
            ),
            onTap: () {
              setSortingCriteria('Z-A');
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Stok Terendah',
                    style: Typo.emphasizedBodyTextStyle.copyWith(
                      fontWeight: activeSortingCriteria == 'stok terendah'
                          ? FontWeight.bold
                          : FontWeight.normal,
                    )),
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
                Text('Stok Terbanyak',
                    style: Typo.emphasizedBodyTextStyle.copyWith(
                      fontWeight: activeSortingCriteria == 'stok terbanyak'
                          ? FontWeight.bold
                          : FontWeight.normal,
                    )),
                if (activeSortingCriteria == 'stok terbanyak')
                  const Icon(Icons.check, color: Col.primaryColor),
              ],
            ),
            onTap: () {
              setSortingCriteria('stok terbanyak');
              Navigator.pop(context);
            },
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: isResetDisabled
                      ? null
                      : () {
                          setSortingCriteria('default');
                          Navigator.pop(context);
                        },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor:
                        isResetDisabled ? Colors.transparent : Col.primaryColor,
                  ),
                  child: const Text('Reset'),
                ),
              ],
            ),
          ),
        ],
      );
    },
  );
}
