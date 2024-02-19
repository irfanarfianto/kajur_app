// sorting_overlay.dart

import 'package:flutter/material.dart';
import 'package:kajur_app/utils/design/system.dart';

class SortingOverlay extends StatelessWidget {
  final bool isSelectedTerbaru;
  final bool isSelectedAZ;
  final bool isSelectedZA;
  final bool isSelectedStokSedikit;
  final bool isSelectedStokBanyak;
  final Function(bool?) onTerbaruChanged;
  final Function(bool?) onAZChanged;
  final Function(bool?) onZAChanged;
  final Function(bool?) onStokSedikitChanged;
  final Function(bool?) onStokBanyakChanged;

  final VoidCallback onReset;
  final VoidCallback onTerapkan;

  const SortingOverlay({
    super.key,
    required this.isSelectedTerbaru,
    required this.isSelectedAZ,
    required this.isSelectedZA,
    required this.isSelectedStokSedikit,
    required this.isSelectedStokBanyak,
    required this.onTerbaruChanged,
    required this.onAZChanged,
    required this.onZAChanged,
    required this.onReset,
    required this.onTerapkan,
    required this.onStokSedikitChanged,
    required this.onStokBanyakChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.8,
      minChildSize: 0.1,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Col.backgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 5,
                width: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: Col.greyColor.withOpacity(.50),
                ),
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Urutkan berdasarkan',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Col.blackColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildSortingCheckbox(
                      'Terbaru', isSelectedTerbaru, onTerbaruChanged),
                  _buildSortingCheckbox('A-Z', isSelectedAZ, onAZChanged),
                  _buildSortingCheckbox('Z-A', isSelectedZA, onZAChanged),
                  _buildSortingCheckbox('Stok sedikit', isSelectedStokSedikit,
                      onStokSedikitChanged),
                  _buildSortingCheckbox(
                    'Stok banyak',
                    isSelectedStokBanyak,
                    onStokBanyakChanged,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildTextButton('Reset', onReset),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildElevatedButton('Terapkan', onTerapkan),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  CheckboxListTile _buildSortingCheckbox(
    String title,
    bool value,
    ValueChanged<bool?> onChanged,
  ) {
    return CheckboxListTile(
      activeColor: Col.primaryColor,
      title: Text(
        title,
        style: Typo.subtitleTextStyle,
      ),
      value: value,
      onChanged: onChanged,
    );
  }

  TextButton _buildTextButton(String label, VoidCallback onPressed) {
    return TextButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Col.greyColor,
        backgroundColor: Colors.transparent,
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }

  ElevatedButton _buildElevatedButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(label),
    );
  }
  
}
