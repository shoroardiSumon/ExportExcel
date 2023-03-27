import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:my_app/notification/notification_manager.dart';
import 'package:open_filex/open_filex.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';
import 'dart:io';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  NotificationManager notificationManager = NotificationManager();
  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
      notificationManager.initialiseNotificaton();
    }
  }

  @override
  void initState() {
    super.initState();
    notificationManager.initialiseNotificaton();
  }

  final List<Map<String, dynamic>> data = [
    {'Name': 'John Doe', 'Age': 30, 'Email': 'johndoe@example.com'},
    {'Name': 'Jane Smith', 'Age': 25, 'Email': 'janesmith@example.com'},
    {'Name': 'Bob Johnson', 'Age': 40, 'Email': 'bobjohnson@example.com'},
  ];

  Future<void> _exportExcel() async {
    // Create a new workbook
    Workbook workbook = Workbook();

    // Add a new worksheet to the workbook
    Worksheet sheet = workbook.worksheets[0];

    // Add data to the worksheet
    sheet.getRangeByName('A1').setText('Name');
    sheet.getRangeByName('B1').setText('Age');
    sheet.getRangeByName('C1').setText('Email');

    for (var i = 0; i < data.length; i++) {
      sheet.getRangeByName('A${i + 2}').setText(data[i]['Name']);
      sheet.getRangeByName('B${i + 2}').setNumber(data[i]['Age']?.toDouble());
      sheet.getRangeByName('C${i + 2}').setText(data[i]['Email']);
    }

    // Save the workbook to a file
    List<int> bytes = workbook.saveAsStream();
    // final directory = await getApplicationDocumentsDirectory();
    Directory? directory;
    directory = Directory('/storage/emulated/0/Download');
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final file = File('${directory.path}/Issue_Data_$timestamp.xlsx');
    //await file.writeAsBytes(bytes);
    await file.writeAsBytes(bytes).whenComplete(() => {
          showNotification(file)
          //notificationManager.sendNotification("File Saved", "The file has been saved successfully.") //
        });

    OpenFilex.open(file.path);
  }

  // Create a notification
  showNotification(var file) async {
    var androidDetails =
        const AndroidNotificationDetails("channelId", "channelName", importance: Importance.max, priority: Priority.high);
    var platformDetails = NotificationDetails(android: androidDetails, iOS: null);

    // Show the notification
    await FlutterLocalNotificationsPlugin()
        .show(0, "File Saved", "The file has been saved successfully.", platformDetails, payload: file.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export to Excel'),
        elevation: 0,
      ),
      body: Container(
          alignment: Alignment.center,
          //color: Colors.white,
          height: 500,
          //width: double.maxFinite,
          child: MaterialButton(
            color: Colors.green[900],
            onPressed: _exportExcel,
            child: const Text("Generate Excel", style: TextStyle(color: Colors.white)),
          )),
    );
  }
}
