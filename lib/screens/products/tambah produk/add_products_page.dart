import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kajur_app/screens/products/tambah%20produk/add_service.dart';
import 'package:kajur_app/utils/design/system.dart';
import 'package:kajur_app/screens/widget/inputan_rupiah.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class AddDataPage extends StatefulWidget {
  const AddDataPage({super.key});

  @override
  _AddDataPageState createState() => _AddDataPageState();
}

class _AddDataPageState extends State<AddDataPage> {
  final AddProductService _addProductService = AddProductService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = false;
  bool isInfoSnackbarVisible = false;
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  final int _totalSteps = 4;
  String result = '';

  void _setImage(File image) {
    setState(() {
      _addProductService.selectedImage = image;
    });
  }

  Future<void> _submitData() async {
    setState(() {
      _isLoading = true;
    });

    await _addProductService.submitData(context, _setLoading);

    setState(() {
      _isLoading = false;
    });
  }

  void _setLoading(bool isLoading) {
    setState(() {
      _isLoading = isLoading;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Scaffold(
            body: Center(
              child: LoadingAnimationWidget.prograssiveDots(
                  color: Col.primaryColor, size: 50),
            ),
          )
        : Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              surfaceTintColor: Colors.transparent,
              title: const Text('Tambah Produk'),
            ),
            body: Scrollbar(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Stepper(
                    connectorColor: const MaterialStatePropertyAll(
                      Col.primaryColor,
                    ),
                    elevation: 0,
                    connectorThickness: 1,
                    controlsBuilder:
                        (BuildContext context, ControlsDetails details) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 16),
                          Row(
                            children: <Widget>[
                              if (_currentStep != 0)
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      surfaceTintColor: Col.secondaryColor,
                                      elevation: 0,
                                      foregroundColor: Col.blackColor,
                                      backgroundColor: Col.secondaryColor,
                                    ),
                                    onPressed: details.onStepCancel,
                                    child: const Text('Kembali'),
                                  ),
                                ),
                              if (_currentStep != 0) const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _currentStep == _totalSteps - 1
                                      ? () {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            _isLoading ? null : _submitData();
                                          }
                                        }
                                      : details.onStepContinue,
                                  child: _isLoading
                                      ? const CircularProgressIndicator()
                                      : Text(_currentStep == _totalSteps - 1
                                          ? 'Selesai'
                                          : 'Selanjutnya'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                    physics: const BouncingScrollPhysics(),
                    currentStep: _currentStep,
                    onStepContinue: () {
                      setState(() {
                        if (_currentStep < _totalSteps - 1) {
                          _currentStep += 1;
                        } else {
                          _currentStep = 0;
                        }
                      });
                    },
                    onStepCancel: () {
                      setState(() {
                        if (_currentStep > 0) {
                          _currentStep -= 1;
                        } else {
                          _currentStep = 0;
                        }
                      });
                    },
                    steps: <Step>[
                      Step(
                        state: _currentStep == 0
                            ? StepState.editing
                            : (_addProductService.menuController.text.isEmpty ||
                                    _addProductService.selectedCategory.isEmpty)
                                ? StepState.error
                                : StepState.complete,
                        title: Text(
                          'Detail Produk',
                          style: (_addProductService
                                      .menuController.text.isEmpty ||
                                  _addProductService.selectedCategory.isEmpty)
                              ? Typo.emphasizedBodyTextStyle
                                  .copyWith(color: Col.greyColor)
                              : Typo.emphasizedBodyTextStyle,
                        ),
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Text(
                                      'Kode Produk',
                                      style: Typo.emphasizedBodyTextStyle,
                                    ),
                                    Text(
                                      '*',
                                      style: TextStyle(
                                        color: Col.redAccent,
                                        fontWeight: Fw.regular,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  'Masukan secara manual jika produk tidak memiliki barcode',
                                  style: Typo.emphasizedBodyTextStyle.copyWith(
                                    color: Col.greyColor,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: TextFormField(
                                        controller: _addProductService
                                            .kodeBarangController,
                                        keyboardType: TextInputType.name,
                                        textCapitalization:
                                            TextCapitalization.words,
                                        textInputAction: TextInputAction.next,
                                        style: const TextStyle(
                                            color: Col.blackColor),
                                        decoration: const InputDecoration(
                                          hintText: 'produk123',
                                          hintStyle: TextStyle(
                                            color: Col.greyColor,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Tidak boleh kosong';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8.0),
                                    IconButton(
                                        // border
                                        padding: const EdgeInsets.all(10),
                                        onPressed: () {
                                          _addProductService.scanBarcode(
                                              context); // Panggil fungsi scanBarcode
                                        },
                                        icon: const Icon(Icons.qr_code_scanner,
                                            color: Col.greyColor, size: 30.0)),
                                  ],
                                ),
                                const SizedBox(height: 16.0),
                                const Row(
                                  children: [
                                    Text(
                                      'Nama Produk',
                                      style: Typo.emphasizedBodyTextStyle,
                                    ),
                                    Text(
                                      '*',
                                      style: TextStyle(
                                        color: Col.redAccent,
                                        fontWeight: Fw.regular,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8.0),
                                TextFormField(
                                  controller: _addProductService.menuController,
                                  keyboardType: TextInputType.name,
                                  textCapitalization: TextCapitalization.words,
                                  textInputAction: TextInputAction.next,
                                  style: const TextStyle(color: Col.blackColor),
                                  decoration: const InputDecoration(
                                    hintText: 'Nama produk',
                                    hintStyle: TextStyle(
                                      color: Col.greyColor,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  maxLength: 500,
                                  inputFormatters: [
                                    FilteringTextInputFormatter
                                        .singleLineFormatter,
                                    TextInputFormatter.withFunction(
                                        (oldValue, newValue) {
                                      if (newValue.text.isEmpty) {
                                        return newValue;
                                      }
                                      return TextEditingValue(
                                        text: newValue.text
                                            .split(' ')
                                            .map((word) => word.isNotEmpty
                                                ? word[0].toUpperCase() +
                                                    word.substring(1)
                                                : '')
                                            .join(' '),
                                        selection: newValue.selection,
                                        composing: TextRange.empty,
                                      );
                                    }),
                                  ],
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Tidak boleh kosong';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 8.0,
                            ),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Text('Pilih kategori',
                                          style: Typo.emphasizedBodyTextStyle),
                                      Text(
                                        '*',
                                        style: TextStyle(
                                          color: Col.redAccent,
                                          fontWeight: Fw.regular,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8.0),
                                  DropdownButtonFormField2<String>(
                                    isExpanded: true,
                                    decoration: const InputDecoration(
                                      contentPadding:
                                          EdgeInsets.symmetric(vertical: 12),
                                    ),
                                    hint: const Text(
                                      'Pilih kategori',
                                      style: TextStyle(
                                        color: Col.greyColor,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 16,
                                      ),
                                    ),
                                    value: _addProductService
                                            .selectedCategory.isNotEmpty
                                        ? _addProductService.selectedCategory
                                        : null,
                                    style:
                                        const TextStyle(color: Col.greyColor),
                                    items: const [
                                      DropdownMenuItem<String>(
                                        value: 'Makanan',
                                        child: Text(
                                          'Makanan',
                                          style: TextStyle(
                                              color: Col.blackColor,
                                              fontSize: 16),
                                        ),
                                      ),
                                      DropdownMenuItem<String>(
                                        value: 'Minuman',
                                        child: Text(
                                          'Minuman',
                                          style: TextStyle(
                                              color: Col.blackColor,
                                              fontSize: 16),
                                        ),
                                      ),
                                    ],
                                    dropdownStyleData: DropdownStyleData(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: Col.backgroundColor,
                                          border: Border.all(
                                            color:
                                                Col.greyColor.withOpacity(.20),
                                          )),
                                    ),
                                    buttonStyleData: const ButtonStyleData(
                                      padding: EdgeInsets.only(right: 8),
                                    ),
                                    menuItemStyleData: const MenuItemStyleData(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 12),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Pilih salah satu kategori';
                                      }
                                      return null;
                                    },
                                    iconStyleData: const IconStyleData(
                                      icon: Icon(
                                        Icons.expand_more_outlined,
                                        color: Colors.black45,
                                      ),
                                      iconSize: 24,
                                    ),
                                    onChanged: (String? value) {
                                      setState(() {
                                        _addProductService.selectedCategory =
                                            value ?? '';
                                      });
                                    },
                                  ),
                                ]),
                            const SizedBox(height: 16.0),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Deskripsi (Opsional)',
                                  style: Typo.emphasizedBodyTextStyle,
                                ),
                                const SizedBox(height: 8.0),
                                TextFormField(
                                  controller:
                                      _addProductService.deskripsiController,
                                  decoration: const InputDecoration(
                                    hintText: 'Masukan deskripsi produk',
                                    hintStyle: TextStyle(
                                      color: Col.greyColor,
                                      fontWeight: FontWeight.normal,
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 10.0),
                                  ),
                                  style: const TextStyle(color: Col.blackColor),
                                  keyboardType: TextInputType.multiline,
                                  maxLines: 3,
                                  maxLength: 1000,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Step(
                        state: _currentStep == 1
                            ? StepState.editing
                            : _addProductService.selectedImage == null
                                ? StepState.error
                                : StepState.complete,
                        title: Text('Tambahkan Foto Produk',
                            style: _addProductService.selectedImage == null
                                ? Typo.emphasizedBodyTextStyle
                                    .copyWith(color: Col.greyColor)
                                : Typo.emphasizedBodyTextStyle),
                        content: Container(
                          height: 200,
                          width: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Col.greyColor.withOpacity(.50),
                              width: 1,
                            ),
                          ),
                          child: Stack(
                            children: [
                              if (_addProductService.selectedImage != null)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    _addProductService.selectedImage!,
                                    height: 200,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              // Hanya tampilkan jika belum ada gambar yang dipilih
                              Align(
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              surfaceTintColor:
                                                  Col.secondaryColor,
                                              title: const Text(
                                                "Pilih Sumber Gambar",
                                                style: TextStyle(
                                                  color: Col.blackColor,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              actions: <Widget>[
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                    _addProductService.getImage(
                                                        ImageSource.gallery,
                                                        _setImage);
                                                  },
                                                  child: const Text("Galeri"),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                    _addProductService.getImage(
                                                        ImageSource.camera,
                                                        _setImage);
                                                  },
                                                  child: const Text("Kamera"),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      icon: Icon(
                                        Icons.add_a_photo,
                                        size: 50,
                                        color: Col.greyColor.withOpacity(.20),
                                      ),
                                    ),
                                    if (_addProductService.selectedImage ==
                                        null)
                                      const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Upload Foto',
                                            style: Typo.emphasizedBodyTextStyle,
                                          ),
                                          Text(
                                            '*',
                                            style: TextStyle(
                                              color: Col.redAccent,
                                              fontWeight: Fw.regular,
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Step(
                        state: _currentStep == 2
                            ? StepState.editing
                            : (_addProductService
                                        .hargaPokokController.text.isEmpty ||
                                    _addProductService
                                        .jumlahIsiController.text.isEmpty)
                                ? StepState.error
                                : StepState.complete,
                        title: Text('Harga Pokok/Beli',
                            style: (_addProductService
                                        .hargaPokokController.text.isEmpty ||
                                    _addProductService
                                        .jumlahIsiController.text.isEmpty)
                                ? Typo.emphasizedBodyTextStyle
                                    .copyWith(color: Col.greyColor)
                                : Typo.emphasizedBodyTextStyle),
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Row(
                                        children: [
                                          Text('Harga pokok/beli',
                                              style:
                                                  Typo.emphasizedBodyTextStyle),
                                          Text(
                                            '*',
                                            style: TextStyle(
                                              color: Col.redAccent,
                                              fontWeight: Fw.regular,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8.0),
                                      TextFormField(
                                        style: const TextStyle(
                                            color: Col.blackColor),
                                        controller: _addProductService
                                            .hargaPokokController,
                                        decoration: const InputDecoration(
                                          hintText: 'Harga pokok/beli',
                                          hintStyle: TextStyle(
                                            color: Col.greyColor,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                          CurrencyInputFormatter()
                                        ],
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Tidak boleh kosong';
                                          }
                                          return null;
                                        },
                                        keyboardType: TextInputType.number,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Row(
                                        children: [
                                          Text('Jumlah isi satuan',
                                              style:
                                                  Typo.emphasizedBodyTextStyle),
                                          Text(
                                            '*',
                                            style: TextStyle(
                                              color: Col.redAccent,
                                              fontWeight: Fw.regular,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8.0),
                                      TextFormField(
                                        controller: _addProductService
                                            .jumlahIsiController,
                                        style: const TextStyle(
                                            color: Col.blackColor),
                                        decoration: const InputDecoration(
                                          hintText: 'Isi',
                                          hintStyle: TextStyle(
                                            color: Col.greyColor,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                        ],
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Tidak boleh kosong';
                                          }
                                          return null;
                                        },
                                        keyboardType: TextInputType.number,
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      Step(
                        state: _currentStep == 3
                            ? StepState.editing
                            : _addProductService
                                    .hargaJualController.text.isEmpty
                                ? StepState.error
                                : StepState.complete,
                        title: Text('Harga Jual',
                            style: _addProductService
                                    .hargaJualController.text.isEmpty
                                ? Typo.emphasizedBodyTextStyle
                                    .copyWith(color: Col.greyColor)
                                : Typo.emphasizedBodyTextStyle),
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Row(
                                        children: [
                                          Text('Harga jual',
                                              style:
                                                  Typo.emphasizedBodyTextStyle),
                                          Text(
                                            '*',
                                            style: TextStyle(
                                              color: Col.redAccent,
                                              fontWeight: Fw.regular,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8.0),
                                      TextFormField(
                                        style: const TextStyle(
                                            color: Col.blackColor),
                                        controller: _addProductService
                                            .hargaJualController,
                                        decoration: const InputDecoration(
                                          hintText: 'Harga jual',
                                          hintStyle: TextStyle(
                                            color: Col.greyColor,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                          CurrencyInputFormatter()
                                        ],
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Tidak boleh kosong';
                                          }
                                          return null;
                                        },
                                        keyboardType: TextInputType.number,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Row(
                                        children: [
                                          Text('Stok yang dijual',
                                              style:
                                                  Typo.emphasizedBodyTextStyle),
                                          Text(
                                            '*',
                                            style: TextStyle(
                                              color: Col.redAccent,
                                              fontWeight: Fw.regular,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8.0),
                                      TextFormField(
                                        controller:
                                            _addProductService.stokController,
                                        style: const TextStyle(
                                            color: Col.blackColor),
                                        decoration: const InputDecoration(
                                          hintText: 'Stok',
                                          hintStyle: TextStyle(
                                            color: Col.greyColor,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                        ],
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Tidak boleh kosong';
                                          }
                                          return null;
                                        },
                                        keyboardType: TextInputType.number,
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
