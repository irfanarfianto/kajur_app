import 'package:fluttertoast/fluttertoast.dart';
import 'package:kajur_app/design/system.dart';

void showToast({required String message}) {
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: Col.primaryColor,
      textColor: Col.whiteColor,
      fontSize: 16.0);
}
