import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:timezone/timezone.dart' as tz;

import '../main.dart';

class AddTask extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _AddTask createState() => _AddTask();
  final String useremail;

  const AddTask({super.key, required this.useremail});
}

class _AddTask extends State<AddTask> {
  late TextEditingController _titleController;
  late TextEditingController _noteController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedStartTime;
  late TimeOfDay _selectedEndTime;
  late Color _selectedColor;

  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<Color> _colors = [
    Colors.blue,
    Colors.red,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _noteController = TextEditingController();
    _selectedDate = DateTime.now();
    _selectedStartTime = TimeOfDay.now();
    _selectedEndTime = TimeOfDay.now();
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
        title: const Text('Thêm sự kiện'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _saveReminder(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Thêm thành công!'),
                      duration:
                          Duration(seconds: 2), // Độ dài hiển thị của SnackBar
                    ),
                  );
                }
              },
              child: const Text('Lưu'),
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
                readOnly:
                    true, // Đặt thuộc tính readOnly để ngăn người dùng chỉnh sửa trực tiếp
                controller: TextEditingController(
                  text: DateFormat('yyyy-MM-dd')
                      .format(_selectedDate), // Định dạng ngày tháng năm
                ),
                onTap: () {
                  _selectDate(
                      context); // Gọi hàm _selectEndTime khi người dùng chạm vào TextField
                },
                decoration: const InputDecoration(
                  suffixIcon: Icon(Icons
                      .calendar_today), // Sử dụng prefixIcon để thêm biểu tượng
                  hintText: 'Select date', // Thêm gợi ý khi không có giá trị
                ),
              ),
              const Text(
                'Bắt đầu:',
                style: TextStyle(fontSize: 18),
              ),
              TextFormField(
                readOnly:
                    true, // Đặt thuộc tính readOnly để ngăn người dùng chỉnh sửa trực tiếp
                controller: TextEditingController(
                  text: _selectedStartTime.format(
                      context), // Sử dụng phương thức format để chuyển đổi TimeOfDay thành chuỗi
                ),
                onTap: () {
                  _selectStartTime(
                      context); // Gọi hàm _selectEndTime khi người dùng chạm vào TextField
                },
                decoration: const InputDecoration(
                  suffixIcon: Icon(Icons
                      .access_time), // Sử dụng prefixIcon để thêm biểu tượng
                  hintText: 'Select time', // Thêm gợi ý khi không có giá trị
                ),
              ),
              const Text(
                'Kết thúc:',
                style: TextStyle(fontSize: 18),
              ),
              TextFormField(
                readOnly:
                    true, // Đặt thuộc tính readOnly để ngăn người dùng chỉnh sửa trực tiếp
                controller: TextEditingController(
                  text: _selectedEndTime.format(
                      context), // Sử dụng phương thức format để chuyển đổi TimeOfDay thành chuỗi
                ),
                onTap: () {
                  _selectEndTime(
                      context); // Gọi hàm _selectEndTime khi người dùng chạm vào TextField
                },
                decoration: const InputDecoration(
                  suffixIcon: Icon(Icons
                      .access_time), // Sử dụng prefixIcon để thêm biểu tượng
                  hintText: 'Select time', // Thêm gợi ý khi không có giá trị
                ),
              ),
              const Text(
                'Màu Sắc:',
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
      firstDate: DateTime.now(),
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
    // Lưu thông tin nhắc nhở ở đây
    
    String title = _titleController.text;
    String note = _noteController.text;

    // Lấy ngày từ _selectedDate
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
   
    // Sau khi lưu xong, quay trở lại màn hình trước đó
    // Lưu dữ liệu vào Firebase Database
    QuerySnapshot querySnapshot = await _firestore
        .collection(widget.useremail)
        .orderBy('id', descending: true)
        .limit(1)
        .get();

    int newId = 1; // Giá trị mặc định nếu không có tài liệu nào

    if (querySnapshot.docs.isNotEmpty) {
      DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
      int maxId = documentSnapshot['id'];
      newId = maxId + 1;
    }
    try {
      // Sử dụng phương thức push() để tạo một nút mới với một ID tự động
      await _firestore.collection(widget.useremail).doc(newId.toString()).set({
        'title': title,
        'date': Date,
        'note': note,
        'startTime': startTime,
        'endTime': endTime,
        'color': color.value,
        'Complete': 0,
        'id': newId,
      });

      // ignore: use_build_context_synchronously
      Navigator.pop(context, true);
    // ignore: empty_catches
    } catch (error) {
   
    }
    scheduleNotification();
  }

  void scheduleNotification() async {
    List<Map<String, dynamic>> notifications = [];

    // Lấy dữ liệu từ Firestore
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection(widget.useremail).get();

    // Lặp qua các tài liệu trong bộ sưu tập
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      if (data['startTime'] != null) {
        DateTime time = (data['startTime'] as Timestamp).toDate();
        notifications.add({
          'id': doc.id.hashCode,
          'title': data['title'],
          'body': data['note'],
          'time':
              DateTime(time.year, time.month, time.day, time.hour, time.minute),
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
        await flutterLocalNotificationsPlugin.zonedSchedule(
          notification['id'],
          notification['title'],
          notification['body'],
          scheduledDate,
          platformChannelSpecifics,
          payload: 'Payload',
          // ignore: deprecated_member_use
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    }
  }
}
