import './receipt-model.dart';
import 'package:flutter/foundation.dart';

class ReceiptViewModel extends ChangeNotifier {
  final ReceiptModel model;
  List<Map<String,String>> items = [];
  String? errorMessage;
  ReceiptViewModel(this.model);

  Future<void> update() async {
    try {
      items = (await model.pickImage()).items;
    } catch (e) {
      errorMessage = 'Could not initialize counter';
    }
    notifyListeners();
  }

}