import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:med_maid/page/inputpage.dart';
import 'package:med_maid/util/controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _box = Hive.box("box");
  final DataController dataController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Med-Maid',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.red,
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            Get.to(const InputPage());
          },
        ),
        body: SingleChildScrollView(
          child: FittedBox(
            child: createDataTable(),
          ),
        ));
  }

  DataTable createDataTable() {
    return DataTable(columns: createDataColumn(), rows: createDataRow());
  }

  List<DataColumn> createDataColumn() {
    return const [
      DataColumn(label: Text('Date')),
      DataColumn(label: Text('Time')),
      DataColumn(label: Text('BP')),
      DataColumn(label: Text('Heart Rate')),
    ];
  }

  List<DataRow> createDataRow() {
    List? datas = _box.get("data");
    // List? datas = dataController.get();
    print(datas);

    if (datas == null) {
      return const [
        DataRow(cells: [
          DataCell(Text("")),
          DataCell(Text("")),
          DataCell(Text("")),
          DataCell(Text("")),
        ])
      ];
    }

    return datas
        .map((data) => DataRow(cells: [
              DataCell(Text(data['date'])),
              DataCell(Text(data['time'])),
              DataCell(Text(data['bp'])),
              DataCell(Text(data['hr'])),
            ]))
        .toList();
  }
}
