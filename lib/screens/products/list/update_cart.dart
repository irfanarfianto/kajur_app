import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:kajur_app/screens/widget/inputan_rupiah.dart';
import 'package:kajur_app/utils/design/system.dart';

class UpdateCart extends StatefulWidget {
  final String productName;
  final TextEditingController priceController;
  final TextEditingController quantityController;
  final Function(String, String) onUpdate;
  final Function() onDelete;

  const UpdateCart({
    Key? key, // Tambahkan key
    required this.productName,
    required this.priceController,
    required this.quantityController,
    required this.onUpdate,
    required this.onDelete,
  }) : super(key: key); // Sertakan key di constructor

  @override
  _UpdateCartState createState() => _UpdateCartState();
}

class _UpdateCartState extends State<UpdateCart> {
  bool isPriceChanged = false;
  bool isPriceEditable = false;

  @override
  void initState() {
    super.initState();
    // Format nilai awal pada controller priceController dengan format rupiah
    widget.priceController.text = formatRupiah(widget.priceController.text);
    // Tambahkan listener untuk mendeteksi perubahan pada priceController
    widget.priceController.addListener(_handlePriceChange);
  }

  @override
  void dispose() {
    widget.priceController.removeListener(_handlePriceChange);
    super.dispose();
  }

  String formatRupiah(String text) {
    var formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(double.parse(text));
  }

  void _handlePriceChange() {
    setState(() {
      isPriceChanged = true;
    });
  }

  void _handleQuantityUpdate() {
    // Ambil nilai jumlah dari controller
    String newQuantity = widget.quantityController.text;

    // Panggil fungsi onUpdate dengan hanya memperbarui jumlah
    widget.onUpdate(widget.priceController.text, newQuantity);
  }

  // void _handlePriceUpdate() {
  //   // Ambil nilai harga dari controller
  //   String newPrice = widget.priceController.text;

  //   // Panggil fungsi onUpdate dengan hanya memperbarui harga pokok
  //   widget.onUpdate(newPrice, widget.quantityController.text);
  // }

  @override
  Widget build(BuildContext context) {
    int currentValue = int.tryParse(widget.quantityController.text) ?? 0;

    return SizedBox(
      width: MediaQuery.of(context).size.width * 1.0,
      height: MediaQuery.of(context).size.height * 0.25,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              widget.productName,
              style: Typo.titleTextStyle,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextField(
                  style: Typo.titleTextStyle.copyWith(fontWeight: Fw.medium),
                  readOnly: isPriceEditable ? false : true,
                  controller: widget.priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    label: const Text(
                      'Harga Pokok (satuan)',
                    ),
                    labelStyle: Typo.bodyTextStyle
                        .copyWith(color: Col.greyColor, fontSize: 18),
                    prefix: Text(
                      '${widget.quantityController.text}x ',
                    ),
                    contentPadding: const EdgeInsets.all(0),
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    CurrencyInputFormatter()
                  ],
                ),
              ),
              if (!isPriceEditable)
                InkWell(
                  onTap: () {
                    setState(() {
                      isPriceEditable = true;
                    });
                  },
                  child: Text(
                    'Ubah Harga',
                    style: Typo.emphasizedBodyTextStyle.copyWith(
                      color: Col.primaryColor,
                      fontWeight: Fw.bold,
                    ),
                  ),
                ),
              if (isPriceChanged && isPriceEditable)
                InkWell(
                  onTap: () {
                    setState(() {
                      isPriceEditable = false;
                      isPriceChanged = false;
                    });
                    // _handlePriceUpdate();
                  },
                  child: Text(
                    'Perbarui',
                    style: Typo.emphasizedBodyTextStyle.copyWith(
                      color: Col.primaryColor,
                      fontWeight: Fw.bold,
                    ),
                  ),
                ),
            ],
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: currentValue > 0
                    ? () {
                        setState(() {
                          widget.quantityController.text =
                              (currentValue - 1).toString();
                        });
                        // _handleQuantityUpdate();
                      }
                    : null,
                icon: const Icon(Icons.remove),
              ),
              SizedBox(
                width: 50,
                height: 50,
                child: TextField(
                  controller: widget.quantityController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    widget.quantityController.text =
                        (currentValue + 1).toString();
                  });
                  _handleQuantityUpdate();
                },
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Batal',
                  style: TextStyle(color: Col.greyColor),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: currentValue > 0
                      ? Theme.of(context).primaryColor
                      : Colors.red,
                ),
                onPressed: currentValue > 0
                    ? () {
                        widget.onUpdate(
                          widget.priceController.text,
                          widget.quantityController.text,
                        );
                        Navigator.pop(context);
                      }
                    : () {
                        widget.onDelete();
                      },
                child: Text(
                  currentValue > 0 ? 'Simpan' : 'Hapus dari Keranjang',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
