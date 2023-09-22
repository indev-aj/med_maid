import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:med_maid/util/controller.dart';

class InputPage extends StatefulWidget {
  const InputPage({super.key});

  @override
  State<InputPage> createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  final TextEditingController bpController = TextEditingController();
  final TextEditingController hrController = TextEditingController();

  final DataController dataController = Get.find();

  final _box = Hive.box("box");

  @override
  Widget build(BuildContext context) {
    var data = _box.get("data");
    var listData = data;

    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: clearDB),
      appBar: AppBar(
        title: const Text(
          "Input New Data",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Row(
              children: [
                const Text(
                  "BP",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(width: 25),
                Expanded(
                  child: TextField(
                    controller: bpController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                const Text(
                  "HR",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(width: 25),
                Expanded(
                  child: TextField(
                    controller: hrController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                var now = DateTime.now();

                var dateFormat = DateFormat("dd/MM/yyyy");
                var timeFormat = DateFormat("HH:mm");

                var today = dateFormat.format(now);
                var time = timeFormat.format(now);

                var data = {
                  'date': today,
                  'time': time,
                  'bp': bpController.text,
                  'hr': hrController.text,
                };

                listData ??= [];
                listData.add(data);

                _box.put("data", listData);

                Get.back();
              },
              child: const Text("Add Data"),
            ),
          ],
        ),
      ),
    );
  }

  void clearDB() {
    _box.delete('data');
  }
}
