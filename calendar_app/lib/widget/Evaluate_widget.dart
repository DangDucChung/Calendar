// ignore: duplicate_ignore
// ignore: file_names
// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class AppColors {
  static const contentColorBlue = Color(0xff0293ee);
  static const contentColorYellow = Color(0xfff8b250);
  static const contentColorPurple = Color(0xff845bef);
  static const contentColorGreen = Color(0xff13d38e);
  static const mainTextColor1 = Color(0xff000000);
}

class Indicator extends StatelessWidget {
  final Color color;
  final String text;
  final bool isSquare;

  // ignore: use_super_parameters
  const Indicator({
    super.key,
    required this.color,
    required this.text,
    this.isSquare = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class PieChartSample2 extends StatefulWidget {
  final String useremail;

  // ignore: use_super_parameters
  const PieChartSample2({Key? key, required this.useremail}) : super(key: key);

  @override
  State<StatefulWidget> createState() => PieChart2State();
}

class PieChart2State extends State<PieChartSample2> {
  int touchedIndex = -1;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  void _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tạo DateTime cho ngày đầu tiên và ngày cuối cùng của tháng đã chọn
    DateTime startOfMonth = DateTime(_selectedDate.year, _selectedDate.month);
    DateTime endOfMonth = DateTime(_selectedDate.year, _selectedDate.month + 1);
  
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đánh giá'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection(widget.useremail)
            .where('date', isGreaterThanOrEqualTo: startOfMonth)
            .where('date', isLessThan: endOfMonth)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
         

          // Extract data from Firestore and build UI
          List<Map<String, dynamic>> tasks = snapshot.data!.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();

          // Calculate data for the pie chart
          List<PieChartSectionData> pieChartData = _generatePieChartData(tasks);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 1.3,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: PieChart(
                          PieChartData(
                            // pieTouchData: PieTouchData(
                            //   touchCallback:
                            //       (FlTouchEvent event, pieTouchResponse) {
                            //     setState(() {
                            //       if (!event.isInterestedForInteractions ||
                            //           pieTouchResponse == null ||
                            //           pieTouchResponse.touchedSection == null) {
                            //         touchedIndex = -1;
                            //         return;
                            //       }
                            //       touchedIndex = pieTouchResponse
                            //           .touchedSection!.touchedSectionIndex;
                            //     });
                            //   },
                            // ),
                            borderData: FlBorderData(show: false),
                            sectionsSpace: 0,
                            centerSpaceRadius: 50,
                            sections: pieChartData,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Padding(
                      padding: EdgeInsets.all(5.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Indicator(
                            color: AppColors.contentColorBlue,
                            text: 'Hoàn thành',
                            isSquare: true,
                          ),
                          SizedBox(height: 8),
                          Indicator(
                            color: AppColors.contentColorYellow,
                            text: 'Chưa hoàn thành',
                            isSquare: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  readOnly: true,
                  textAlign: TextAlign.center,
                  controller: TextEditingController(
                    text: DateFormat.yMMM('vi_VN').format(_selectedDate),
                  ),
                  onTap: () {
                    _selectDate(context);
                  },
                  decoration: const InputDecoration(
                    suffixIcon: Icon(Icons.calendar_today),
                    hintText: 'Select date',
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> task = tasks[index];
                
                    

                    Timestamp? startTimeTimestamp = task['startTime'];
                    Timestamp? endTimeTimestamp = task['endTime'];
                    DateTime? startTime = startTimeTimestamp?.toDate();
                    DateTime? endTime = endTimeTimestamp?.toDate();
                    String title = task['title'] ??
                        ''; // Lấy tiêu đề, sử dụng ?? để xử lý trường hợp giá trị null
                    String note = task['note'] ?? ''; // Lấy ghi chú
                    Color cardColor = task['Complete'] == 1
                        ? AppColors.contentColorBlue
                        : AppColors.contentColorYellow;

                    return GestureDetector(
                      onLongPress: () {
                     
                        // Call function to show bottom sheet or perform other action
                      },
                      child: Card(
                        elevation: 1,
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: cardColor,
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
                                if (task['Complete'] == 1)
                                  const Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        'Hoàn thành!!',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontStyle: FontStyle.italic,
                                          color:
                                              Color.fromARGB(255, 34, 230, 40),
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

                    //if
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<PieChartSectionData> _generatePieChartData(
      List<Map<String, dynamic>> tasks) {
    // Calculate percentages for pie chart based on task data
    int totalTasks = tasks.length;
    int completeCount = tasks.where((task) => task['Complete'] == 1).length;
    int incompleteCount = totalTasks - completeCount;

    // Generate pie chart data
    return [
      PieChartSectionData(
        color: AppColors.contentColorBlue,
        value: completeCount.toDouble(),
        title: '${(completeCount / totalTasks * 100).toStringAsFixed(0)}%',
        titleStyle: TextStyle(
          fontSize: touchedIndex == 0 ? 25.0 : 16.0,
          fontWeight: FontWeight.bold,
          color: AppColors.mainTextColor1,
          shadows: const [BoxShadow(color: Colors.black, blurRadius: 2)],
        ),
        radius: touchedIndex == 0 ? 60.0 : 50.0,
      ),
      PieChartSectionData(
        color: AppColors.contentColorYellow,
        value: incompleteCount.toDouble(),
        title: '${(incompleteCount / totalTasks * 100).toStringAsFixed(0)}%',
        titleStyle: TextStyle(
          fontSize: touchedIndex == 1 ? 25.0 : 16.0,
          fontWeight: FontWeight.bold,
          color: AppColors.mainTextColor1,
          shadows: const [BoxShadow(color: Colors.black, blurRadius: 2)],
        ),
        radius: touchedIndex == 1 ? 60.0 : 50.0,
      ),
    ];
  }
}
