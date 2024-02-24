import 'package:fluttertoast/fluttertoast.dart';
import 'package:kajur_app/utils/design/system.dart';

void showToast({required String message}) {
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: Col.greyColor.withOpacity(0.90),
      textColor: Col.whiteColor,
      fontSize: 16.0);
}
