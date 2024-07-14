import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:calendar_app/widget/addtask_widget.dart';
import 'package:calendar_app/widget/listtask_widget.dart';

import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:calendar_app/widget/tasks_widget.dart'; // Thêm import TasksWidget

class CalendarWidget extends StatelessWidget {
  final String useremail;

  const CalendarWidget({super.key, required this.useremail});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection(useremail).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          List<Appointment> appointments = [];
          // ignore: avoid_function_literals_in_foreach_calls
          snapshot.data!.docs.forEach((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            DateTime startTime = data['startTime'].toDate();
            DateTime endTime = data['endTime'].toDate();
            String title = data['title'];
            Color color = Color(
                data['color']); // Chuyển đổi số nguyên thành đối tượng màu
          
            appointments.add(Appointment(
              startTime: startTime,
              endTime: endTime,
              subject: title,
              color: color,
            ));
          });

          return SfCalendar(
            view: CalendarView.month,
            dataSource: MeetingDataSource(appointments),
            initialSelectedDate: DateTime.now(),
            onTap: (CalendarTapDetails details) {
              if (details.targetElement == CalendarElement.calendarCell) {
              
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ListTask(selectedDate: details.date!, useremail: useremail),
                  ),
                );
                
              }
              
            },
            
          );
          
        },
        
      ),
      
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue,
            child: IconButton(
              color: Colors.white,
              icon: const Icon(Icons.show_chart),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) =>
                      TaskWidget(DateTime.now(), useremail: useremail),
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            onPressed: () {
             
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddTask(useremail: useremail),
                ),
              );
            
            },
            backgroundColor: Colors.blue,
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Appointment> appointments) {
    this.appointments = appointments;
  }
}
