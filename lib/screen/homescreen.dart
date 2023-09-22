// ignore_for_file: non_constant_identifier_names

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController systolicController = TextEditingController();
  final TextEditingController dystolicController = TextEditingController();
  final TextEditingController hrController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();

  final bp_box = Hive.box('bp_box');

  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _refreshItem();
  }

  void _showForm(BuildContext context, int? itemKey) async {
    getDateTime();

    showModalBottomSheet(
      context: context,
      elevation: 5,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 15,
          right: 15,
          left: 15,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: dateController,
                    decoration:
                        const InputDecoration(hintText: "Systolic Reading"),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: TextField(
                    controller: timeController,
                    decoration:
                        const InputDecoration(hintText: "Dystolic Reading"),
                  ),
                )
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: systolicController,
                    decoration:
                        const InputDecoration(hintText: "Systolic Reading"),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: TextField(
                    controller: dystolicController,
                    decoration:
                        const InputDecoration(hintText: "Dystolic Reading"),
                  ),
                )
              ],
            ),
            const SizedBox(height: 15),
            TextField(
              controller: hrController,
              decoration: const InputDecoration(hintText: "Heart Rate Reading"),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                _createItem({
                  "date": dateController.text,
                  "time": timeController.text,
                  "systolic": systolicController.text,
                  "dystolic": dystolicController.text,
                  "hr": hrController.text,
                });

                systolicController.text = '';
                dystolicController.text = '';
                hrController.text = '';

                Navigator.of(context).pop();
              },
              child: const Text("Add New Data"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.red,
        actions: [
          IconButton(
            onPressed: () async {
              _deleteAll();
            },
            icon: const Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
        ],
        title: const Text(
          'Med-Maid',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showForm(context, null),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            const Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Date"),
                Text("Time"),
                Text("BP"),
                Text("HR"),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final currentItem = _items[index];
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(currentItem["date"]),
                      Text(currentItem["time"]),
                      Text(currentItem["bp"]),
                      Text(currentItem["hr"]),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createItem(Map<String, dynamic> newItem) async {
    await bp_box.add(newItem);
    _refreshItem();
  }

  void _deleteAll() async {
    bp_box.deleteAll(bp_box.keys);

    setState(() {
      _items.clear();
    });
  }

  void _refreshItem() {
    final data = bp_box.keys.map((key) {
      final item = bp_box.get(key);

      return {
        "key": key,
        "date": item["date"],
        "time": item["time"],
        "bp": " ${item['systolic']} / ${item['dystolic']}",
        "hr": item["hr"],
      };
    }).toList();

    setState(() {
      _items = data.reversed.toList();
    });
  }

  void getDateTime() {
    var now = DateTime.now();

    var dateFormat = DateFormat("dd/MM/yyyy");
    var timeFormat = DateFormat("HH:mm");

    var today = dateFormat.format(now);
    var time = timeFormat.format(now);

    dateController.text = today;
    timeController.text = time;
  }
}
