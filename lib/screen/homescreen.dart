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
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  var dateFormat = DateFormat("dd/MM/yyyy");
  var timeFormat = DateFormat("HH:mm");

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
          bottom: MediaQuery.of(context).viewInsets.bottom + 15,
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: dateController,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          _selectDate(context);
                        },
                        icon: const Icon(Icons.calendar_month_outlined),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: timeController,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          _selectTime(context);
                        },
                        icon: const Icon(Icons.access_time_rounded),
                      ),
                    ],
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Cancel"),
                ),
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
          ],
        ),
      ),
    );
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('This action is irreversible'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete all saved data?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Yes, delete all'),
              onPressed: () async {
                _deleteAll();
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
          ],
        );
      },
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
            onPressed: _showMyDialog,
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

  void _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate, // Refer step 1
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        dateController.text = dateFormat.format(selectedDate);
      });
    }
  }

  void _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked;
        var _hour = selectedTime.hour.toString();
        var _minute = selectedTime.minute.toString();
        var _time = "$_hour:$_minute";
        timeController.text = _time;
      });
    }
  }

  void getDateTime() {
    var now = DateTime.now();

    var today = dateFormat.format(now);
    var time = timeFormat.format(now);

    dateController.text = today;
    timeController.text = time;
  }
}
