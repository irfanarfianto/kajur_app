import 'package:flutter/material.dart';
import 'package:kajur_app/design/system.dart';

class DescriptionForm extends StatelessWidget {
  final TextEditingController descriptionController;

  DescriptionForm({required this.descriptionController});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Lengkapi deskripsi',
                    style: Typo.headingTextStyle,
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
              TextField(
                maxLines: 7,
                controller: descriptionController,
                decoration: const InputDecoration(
                  hintText: 'Tulis disini',
                  border: OutlineInputBorder(),
                ),
                maxLength: 150,
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Simpan'),
              ),
            ],
          ),
        );
      },
    );
  }
}
