import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showSuccessSnackBar(String message) {
  Get.snackbar(
    'Berhasil',
    message,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: Colors.green,
    colorText: Colors.white,
  );
}

void showErrorSnackBar(String message) {
  Get.snackbar(
    'Gagal',
    message,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: Colors.red,
    colorText: Colors.white,
  );
}

void showInfoSnackBar(String message) {
  Get.snackbar(
    'Informasi',
    message,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: Colors.blue,
    colorText: Colors.white,
  );
}