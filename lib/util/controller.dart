import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DataController extends GetxController {
  final _box = Hive.box("box");
  RxList data = [].obs;

  void add(dynamic x) {
    data.add(x);
    _box.put("data", x);
  }

  List get() {
    var data = _box.get("data");
    return data;
  }
}
