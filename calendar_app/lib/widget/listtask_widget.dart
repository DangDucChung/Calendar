import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:calendar_app/widget/updatetask_widget.dart';
import 'package:intl/intl.dart';

class ListTask extends StatefulWidget {
  final DateTime selectedDate;
  final String useremail;

  const ListTask({
    super.key,
    required this.selectedDate,
    required this.useremail,
  });

  @override
  // ignore: library_private_types_in_public_api
  _ListTaskState createState() => _ListTaskState();
}

class _ListTaskState extends State<ListTask> {
  String? title;
  String? note;
  String? startTime;
  String? endTime;
  String? id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat.yMMMd('vi_VN').format(widget.selectedDate),
            style: const TextStyle(color: Color.fromARGB(255, 13, 13, 13))),
        backgroundColor: const Color.fromARGB(255, 86, 181, 183),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection(widget.useremail).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(); // Hiển thị widget loading khi dữ liệu đang được tải
          }
          if (snapshot.hasError) {
            return const Text(
                'Something went wrong'); // Hiển thị thông báo lỗi nếu có lỗi xảy ra
          }

          return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                DocumentSnapshot<Object?> docSnapshot =
                    snapshot.data!.docs[index];
                Map<String, dynamic> task =
                    docSnapshot.data() as Map<String, dynamic>;
                Timestamp? datetime = task['date'];
                DateTime? date = datetime?.toDate();
                int complete = task["Complete"];
                if ('$date' == '${widget.selectedDate}') {
                  String title = task[
                      'title']; // Lấy tiêu đề, sử dụng ?? để xử lý trường hợp giá trị null
                  String note = task['note'] ?? ''; // Lấy ghi chú
                  Timestamp? startTimeTimestamp = task['startTime'];
                  Timestamp? endTimeTimestamp = task['endTime'];
                  Color color = Color(task[
                      'color']); // Chuyển đổi số nguyên thành đối tượng màu
                  DateTime? startTime = startTimeTimestamp?.toDate();
                  DateTime? endTime = endTimeTimestamp?.toDate();

                  // Tạo Card để hiển thị dữ liệu
                  return GestureDetector(
                    onLongPress: () {
                      _showBottomSheet(context, docSnapshot);
                    },
                    child: Card(
                      elevation: 1,
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                note,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.access_time,
                                      color: Colors.white),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Bắt đầu: $startTime',
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.white),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.access_time,
                                      color: Colors.white),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Kết thúc: $endTime',
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.white),
                                  ),
                                ],
                              ),
                              if ('$complete' == '1')
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Hoàn thành!!',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontStyle: FontStyle.italic,
                                        color: Color.fromARGB(
                                            255, 34, 230, 40), // Màu xanh
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                } else {
                  // Nếu không trùng, trả về một widget trống
                  return const SizedBox.shrink();
                }
              });
        },
      ),
    );
  }

  void _showBottomSheet(
      BuildContext context, DocumentSnapshot<Object?> document) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 230,
          width: 400,
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  document.reference.delete();

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Xóa thành công!'),
                    duration:
                        Duration(seconds: 2), // Độ dài hiển thị của SnackBar
                  ));

                  // Xử lý khi nhấn nút Delete
                },
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 120, vertical: 15),
                    backgroundColor: Colors.red),
                child: const Text(
                  'Xóa',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // Xử lý khi nhấn nút Update

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => UpdateTask(
                              useremail: widget.useremail,
                              title: document['title'],
                              note: document['note'],
                              date: (document['date'] as Timestamp)
                                  .toDate(), // Chuyển đổi Timestamp thành DateTime
                              startTime: (document['startTime'] as Timestamp)
                                  .toDate(), // Chuyển đổi Timestamp thành DateTime
                              endTime: (document['endTime'] as Timestamp)
                                  .toDate(), // Chuyển đổi Timestamp thành DateTime
                              color: document['color'],
                              documentId: document.id,
                            )),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 120, vertical: 15), //
                ),
                child: const Text(
                  'Sửa',
                  style: TextStyle(color: Color.fromARGB(255, 26, 60, 129)),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Xử lý khi nhấn nút Close
                  FirebaseFirestore.instance
                      .collection(widget.useremail)
                      .doc(document.id)
                      .update({'Complete': 1}).then((value) {});
                },
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 100,
                      vertical: 15,
                    ),
                    backgroundColor: const Color.fromARGB(
                        255, 54, 244, 73) // Thêm padding cho nút Close
                    ),
                child: const Text(
                  'Hoàn thành',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
