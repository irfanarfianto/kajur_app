import 'package:flutter/material.dart';
import 'package:kajur_app/design/system.dart';

class DescriptionForm extends StatelessWidget {
  final TextEditingController descriptionController;
  final FocusNode descriptionFocusNode = FocusNode();

  DescriptionForm({required this.descriptionController});

  @override
  Widget build(BuildContext context) {
    descriptionFocusNode.requestFocus();

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(
                        Icons.close,
                      )),
                  const Text(
                    'Lengkapi deskripsi',
                    style: Typo.headingTextStyle,
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  descriptionController.clear();
                },
                child: const Text(
                  'Hapus',
                  style: TextStyle(color: Col.redAccent),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          TextFormField(
            maxLines: 7,
            controller: descriptionController,
            focusNode: descriptionFocusNode,
            decoration: const InputDecoration(
              hintText: 'Tulis disini',
              border: OutlineInputBorder(),
            ),
            maxLength: 150,
            keyboardType: TextInputType.multiline,
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Simpan'),
          ),
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }
}
