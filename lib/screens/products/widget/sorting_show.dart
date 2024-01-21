// sorting_overlay.dart

import 'package:flutter/material.dart';
import 'package:kajur_app/design/system.dart';

class SortingOverlay extends StatelessWidget {
  final bool isSelectedTerbaru;
  final bool isSelectedAZ;
  final bool isSelectedZA;
  final Function(bool?) onTerbaruChanged;
  final Function(bool?) onAZChanged;
  final Function(bool?) onZAChanged;
  final VoidCallback onReset;
  final VoidCallback onTerapkan;

  SortingOverlay({
    required this.isSelectedTerbaru,
    required this.isSelectedAZ,
    required this.isSelectedZA,
    required this.onTerbaruChanged,
    required this.onAZChanged,
    required this.onZAChanged,
    required this.onReset,
    required this.onTerapkan,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.4,
      maxChildSize: 0.4,
      minChildSize: 0.1,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: DesignSystem.backgroundColor,
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
                  color: DesignSystem.greyColor.withOpacity(.50),
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
                      color: DesignSystem.blackColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildSortingCheckbox(
                      'Terbaru', isSelectedTerbaru, onTerbaruChanged),
                  _buildSortingCheckbox('A-Z', isSelectedAZ, onAZChanged),
                  _buildSortingCheckbox('Z-A', isSelectedZA, onZAChanged),
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
      activeColor: DesignSystem.primaryColor,
      title: Text(
        title,
        style: DesignSystem.subtitleTextStyle,
      ),
      value: value,
      onChanged: onChanged,
    );
  }

  TextButton _buildTextButton(String label, VoidCallback onPressed) {
    return TextButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: DesignSystem.greyColor,
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
