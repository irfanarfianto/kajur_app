import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kajur_app/design/system.dart';
import 'package:kajur_app/global/common/toast.dart';
import 'package:kajur_app/screens/home/tabs/keuangan/components/category_selector.dart';
import 'package:kajur_app/screens/home/tabs/keuangan/components/dialog_deskripsi.dart';
import 'package:kajur_app/screens/home/tabs/keuangan/numpad.dart';
import 'package:kajur_app/screens/widget/inputan_rupiah.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class IncomeForm extends StatefulWidget {
  @override
  _IncomeFormState createState() => _IncomeFormState();
}

class _IncomeFormState extends State<IncomeForm> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedCategory = ''; // Menyimpan kategori yang dipilih
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  bool _categoryNotSelected = false;
  final CurrencyInputFormatter currencyFormatter = CurrencyInputFormatter();
  DateTime _selectedDate = DateTime.now();
  late User? user;
  late bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize user in the initState
    user = FirebaseAuth.instance.currentUser;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _submitForm() async {
    try {
      if (_formKey.currentState!.validate()) {
        if (_selectedCategory.isEmpty) {
          setState(() {
            _categoryNotSelected = true;
          });
        } else {
          setState(() {
            _categoryNotSelected = false;
            _isLoading = true;
          });

          double amount = double.tryParse(_amountController.text
                  .replaceAll('Rp', '')
                  .replaceAll('.', '')) ??
              0.0;

          if (amount <= 0.0) {
            throw FormatException("Invalid amount");
          }

          // Save income data
          DocumentReference incomeRef =
              await _firestore.collection('income').add({
            'amount': amount,
            'description': _descriptionController.text,
            'category': _selectedCategory,
            'date': _selectedDate,
            'recordedBy': user?.displayName,
            'recordedById': user?.uid,
            'timestamp': DateTime.now(),
          });

          // Update total saldo
          await updateTotalSaldo(amount, 'Pemasukan');

          await _firestore.collection('transaction_history').add({
            'transactionType': 'Pemasukan',
            'transactionId': incomeRef.id,
            'amount': amount,
            'description': _descriptionController.text,
            'category': _selectedCategory,
            'date': _selectedDate,
            'recordedBy': user?.displayName,
            'recordedById': user?.uid,
            'timestamp': DateTime.now(),
          });

          _amountController.clear();
          _descriptionController.clear();
          setState(() {
            _selectedCategory = '';
            _isLoading = false;
          });

          showToast(message: 'Pemasukan berhasil dicatat');

          Navigator.pop(context);
        }
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      showToast(message: 'Terjadi kesalahan: $error');
    }
  }

  Future<void> updateTotalSaldo(double amount, String transactionType) async {
    DocumentReference totalSaldoRef =
        _firestore.collection('saldo').doc('total');

    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(totalSaldoRef);

      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        double totalSaldo = data['totalSaldo'] ?? 0;
        // Update total saldo based on transaction type
        if (transactionType == 'Pemasukan') {
          totalSaldo += amount;
        } else {
          totalSaldo -= amount;
        }

        // Update total saldo document with the new total saldo
        transaction.update(totalSaldoRef, {
          'totalSaldo': totalSaldo,
          'timestamp': FieldValue.serverTimestamp()
        });
      } else {
        // Total saldo document not found, create a new document
        transaction.set(totalSaldoRef,
            {'totalSaldo': amount, 'timestamp': FieldValue.serverTimestamp()});
      }
    }).then((_) {
      print('Total saldo successfully updated.');
    }).catchError((error) {
      print('Error updating total saldo: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Col.secondaryColor,
        backgroundColor: Col.secondaryColor,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Catat Pemasukan'),
            InkWell(
              onTap: () => _selectDate(context),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_month,
                    color: Col.blackColor,
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    DateFormat('dd MMMM yyyy', 'id').format(_selectedDate),
                    style: const TextStyle(
                      fontSize: 14.0,
                      color: Col.blackColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? Center(
              child: LoadingAnimationWidget.prograssiveDots(
                  color: Col.primaryColor, size: 50))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      width: 380,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Col.secondaryColor,
                        border: Border.all(
                            color: const Color(0x309E9E9E), width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Col.greyColor.withOpacity(.10),
                            offset: const Offset(0, 5),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 25,
                                  color: Col.blackColor,
                                  fontWeight: Fw.bold),
                              controller: _amountController,
                              decoration: const InputDecoration(
                                hintText: 'Rp',
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Col.greyColor, width: 1),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10.0),
                                    )),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Nggak boleh kosong yah';
                                }
                                return null;
                              },
                              keyboardType: TextInputType.none,
                            ),
                            const SizedBox(height: 16.0),
                            TextButton(
                              style: ButtonStyle(
                                textStyle: MaterialStateTextStyle.resolveWith(
                                    (states) => Typo.emphasizedBodyTextStyle),
                                side: MaterialStateBorderSide.resolveWith(
                                    (states) => BorderSide(
                                        color: Col.greyColor.withOpacity(0.2),
                                        width: 1)),
                              ),
                              onPressed: () async {
                                showModalBottomSheet(
                                  context: context,
                                  enableDrag: true,
                                  isScrollControlled: true,
                                  builder: (BuildContext context) {
                                    return DescriptionForm(
                                        descriptionController:
                                            _descriptionController);
                                  },
                                  constraints: BoxConstraints(
                                    maxHeight:
                                        MediaQuery.of(context).size.height *
                                            0.85,
                                  ),
                                ).then((value) {
                                  setState(() {});
                                });
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                        _descriptionController.text.isEmpty
                                            ? 'Tambahkan deskripsi jika perlu'
                                            : _descriptionController.text,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color:
                                              Col.blackColor.withOpacity(0.5),
                                        )),
                                  ),
                                  const SizedBox(width: 8.0),
                                  Icon(Icons.edit_document,
                                      color: Col.blackColor.withOpacity(0.5),
                                      size: 15),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      width: 380,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Col.secondaryColor,
                        border: _categoryNotSelected
                            ? Border.all(color: Colors.red, width: 1)
                            : Border.all(
                                color: const Color(0x309E9E9E), width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Col.greyColor.withOpacity(.10),
                            offset: const Offset(0, 5),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          CategorySelector(
                            category: 'Penjualan',
                            selectedCategory: _selectedCategory,
                            icon: Icons.shopping_bag,
                            iconColor: Col.greenAccent,
                            onTap: () {
                              setState(() {
                                _selectedCategory = 'Penjualan';
                                _categoryNotSelected = false;
                              });
                            },
                          ),
                          CategorySelector(
                            category: 'Hutang',
                            selectedCategory: _selectedCategory,
                            icon: Icons.money_off,
                            iconColor: Col.orangeAccent,
                            onTap: () {
                              setState(() {
                                _selectedCategory = 'Hutang';
                                _categoryNotSelected = false;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    if (_categoryNotSelected)
                      const Padding(
                        padding: EdgeInsets.only(left: 16.0),
                        child: Text(
                          'Pilih kategorinya dulu yah',
                          style: TextStyle(color: Col.redAccent, fontSize: 12),
                        ),
                      ),
                    const SizedBox(height: 16.0),
                    // numpad
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      width: 380,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Col.secondaryColor,
                      ),
                      child: NumPad(
                        delete: () {
                          setState(() {
                            if (_amountController.text.isNotEmpty) {
                              _amountController.text = _amountController.text
                                  .substring(
                                      0, _amountController.text.length - 1);
                            }
                          });
                        },
                        onSubmit: () {
                          _submitForm();
                        },
                        controller: _amountController,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
