import 'package:flutter/material.dart';
import 'package:kajur_app/design/system.dart';

class CategorySelector extends StatelessWidget {
  final String category;
  final String selectedCategory;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const CategorySelector({
    super.key,
    required this.category,
    required this.selectedCategory,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: selectedCategory == category
                        ? Col.primaryColor
                        : const Color(0x309E9E9E),
                  ),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 30,
                ),
              ),
              if (selectedCategory == category)
                Container(
                  decoration: BoxDecoration(
                    color: Col.primaryColor,
                    border: Border.all(
                      width: 1,
                      color: Col.whiteColor,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Col.greyColor.withOpacity(.5),
                        offset: const Offset(0, 5),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child:
                      const Icon(Icons.check, color: Col.whiteColor, size: 15),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            category,
            style: const TextStyle(fontSize: 12, color: Col.greyColor),
          )
        ],
      ),
    );
  }
}
