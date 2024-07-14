import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timezone/timezone.dart' as tz;
import '../main.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class UpdateTask extends StatefulWidget {
  final String useremail;
  final String title;
  final String note;
  final DateTime startTime;
  final DateTime endTime;
  final int color;
  final DateTime date;
  final String documentId;
  const UpdateTask({
    super.key,
    required this.useremail,
    required this.title,
    required this.note,
    required this.startTime,
    required this.endTime,
    required this.color,
    required this.date,
    required this.documentId,
  });

  @override
  // ignore: library_private_types_in_public_api
  _UpdateTaskState createState() => _UpdateTaskState();
}

class _UpdateTaskState extends State<UpdateTask> {
  late TextEditingController _titleController;
  late TextEditingController _noteController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedStartTime;
  late TimeOfDay _selectedEndTime;
  late Color _selectedColor;

  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ignore: prefer_final_fields
  List<Color> _colors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title);
    _noteController = TextEditingController(text: widget.note);
    _selectedDate = widget.date;
    _selectedStartTime = TimeOfDay.fromDateTime(widget.startTime);
    _selectedEndTime = TimeOfDay.fromDateTime(widget.endTime);
    _selectedColor = _colors[0];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sửa sự kiện'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _saveReminder(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sửa thành công!'),
                      duration:
                          Duration(seconds: 2), // Độ dài hiển thị của SnackBar
                    ),
                  );
                }
              },
              child: const Text('Cập Nhật'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tiêu đề:',
                style: TextStyle(fontSize: 18),
              ),
              TextFormField(
                controller: _titleController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tiêu đề';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Ghi chú:',
                style: TextStyle(fontSize: 18),
              ),
              TextFormField(
                controller: _noteController,
              ),
              const SizedBox(height: 20),
              const Text(
                'Ngày:',
                style: TextStyle(fontSize: 18),
              ),
              TextFormField(
                readOnly: true,
                controller: TextEditingController(
                  text: DateFormat('yyyy-MM-dd').format(_selectedDate),
                ),
                onTap: () {
                  _selectDate(context);
                },
                decoration: const InputDecoration(
                  suffixIcon: Icon(Icons.calendar_today),
                  hintText: 'Select date',
                ),
              ),
              const Text(
                'Bắt đầu:',
                style: TextStyle(fontSize: 18),
              ),
              TextFormField(
                readOnly: true,
                controller: TextEditingController(
                  text: _selectedStartTime.format(context),
                ),
                onTap: () {
                  _selectStartTime(context);
                },
                decoration: const InputDecoration(
                  suffixIcon: Icon(Icons.access_time),
                  hintText: 'Select time',
                ),
              ),
              const Text(
                'Kết thúc:',
                style: TextStyle(fontSize: 18),
              ),
              TextFormField(
                readOnly: true,
                controller: TextEditingController(
                  text: _selectedEndTime.format(context),
                ),
                onTap: () {
                  _selectEndTime(context);
                },
                decoration: const InputDecoration(
                  suffixIcon: Icon(Icons.access_time),
                  hintText: 'Select time',
                ),
              ),
              const Text(
                'Màu sắc:',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 10),
              DropdownButton<Color>(
                value: _selectedColor,
                onChanged: (Color? newValue) {
                  setState(() {
                    _selectedColor = newValue!;
                  });
                },
                items: _colors.map<DropdownMenuItem<Color>>((Color color) {
                  return DropdownMenuItem<Color>(
                    value: color,
                    child: Container(
                      width: 20,
                      height: 20,
                      color: color,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900), // Bất kỳ ngày trong quá khứ nào
      lastDate: DateTime(2100),
       
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _selectStartTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedStartTime,
    );
    if (pickedTime != null) {
      setState(() {
        _selectedStartTime = pickedTime;
      });
    }
  }

  void _selectEndTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedEndTime,
    );
    if (pickedTime != null) {
      setState(() {
        _selectedEndTime = pickedTime;
      });
    }
  }

  void _saveReminder(BuildContext context) async {
    String title = _titleController.text;
    String note = _noteController.text;

    // ignore: non_constant_identifier_names
    DateTime Date = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );

    DateTime startTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedStartTime.hour,
      _selectedStartTime.minute,
    );
    DateTime endTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedEndTime.hour,
      _selectedEndTime.minute,
    );
    Color color = _selectedColor;

    try {
      await _firestore
          .collection(widget.useremail)
          .doc(widget.documentId)
          .update({
        'title': title,
        'date': Date,
        'note': note,
        'startTime': startTime,
        'endTime': endTime,
        'color': color.value,
      });
      // ignore: empty_catches
    } catch (error) {}
    scheduleNotification();
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }

  void scheduleNotification() async {
    List<Map<String, dynamic>> notifications = [];

    // Lấy dữ liệu từ Firestore
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection(widget.useremail).get();

    // Lặp qua các tài liệu trong bộ sưu tập
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      // Timestamp? startTimeTimestamp = data['startTime'];
      // var time = startTimeTimestamp?.toDate();
      if (data['startTime'] != null) {
        DateTime time = (data['startTime'] as Timestamp).toDate();
        notifications.add({
          'id': doc.id
              .hashCode, // Sử dụng hashCode để chuyển ID chuỗi thành số nguyên
          'title': data['title'],
          'body': data['body'],
          'time': DateTime(time.year, time.month, time.day, time.hour,
              time.minute), // Tạo DateTime từ Timestamp
          // 'time': DateTime(2024, 6, 4, 16, 43) // 10:00 AM, June 4, 2024
        });
      }
    }

    var androidDetails = const AndroidNotificationDetails(
      'channelId',
      'channelName',
      importance: Importance.high,
    );

    var platformChannelSpecifics = NotificationDetails(
      android: androidDetails,
    );

    for (var notification in notifications) {
      final tz.TZDateTime scheduledDate =
          tz.TZDateTime.from(notification['time'], tz.local);
      if (scheduledDate.isAfter(tz.TZDateTime.now(tz.local))) {
        // Kiểm tra nếu thời gian thông báo là trong tương lai
        await flutterLocalNotificationsPlugin.zonedSchedule(
          notification['id'], // ID của thông báo
          notification['title'], // Tiêu đề
          notification['body'], // Nội dung
          scheduledDate,
          platformChannelSpecifics,
          payload: 'Payload', // Payload tùy chọn
          // ignore: deprecated_member_use
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    }
    // ignore: empty_statements
    ;
  }
}
