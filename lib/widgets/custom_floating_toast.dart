import 'package:fluttertoast/fluttertoast.dart';
import 'package:task_new/utils/app_colors.dart';

class CustomFloatingToast {
  static void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: AppColors.darkGreen,
      textColor: AppColors.white,
      gravity: ToastGravity.BOTTOM,
    );
  }
}
