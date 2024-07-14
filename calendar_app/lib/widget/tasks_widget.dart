import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
// ignore: depend_on_referenced_packages
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskWidget extends StatefulWidget {
  final DateTime selectedDate;
  final String useremail;
  const TaskWidget(this.selectedDate, {super.key, required this.useremail});
  @override
  // ignore: library_private_types_in_public_api
  _TasksWidgetState createState() => _TasksWidgetState();
}

class _TasksWidgetState extends State<TaskWidget> {
  List<Appointment> appointments = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream:
            FirebaseFirestore.instance.collection(widget.useremail).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          appointments.clear();
          snapshot.data!.docs.forEach((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            DateTime startTime = data['startTime'].toDate();
            DateTime endTime = data['endTime'].toDate();
            String title = data['title'];
            Color color = Color(data['color']);
            appointments.add(Appointment(
              startTime: startTime,
              endTime: endTime,
              subject: title,
              color: color,
            ));
          });
          return SfCalendarTheme(
            data: const SfCalendarThemeData(),
            child: SfCalendar(
              view: CalendarView.timelineDay,
              dataSource: MeetingDataSource(appointments),
              timeSlotViewSettings: const TimeSlotViewSettings(
                startHour: 0,
                endHour: 24,
                timeInterval: Duration(hours: 1),
              ),
              onTap: (CalendarTapDetails details) {
                if (details.targetElement == CalendarElement.appointment) {
                  final appointment = details.appointments!.first;
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Tiêu đề'),
                        content: Text(appointment.subject),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('Đóng'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Appointment> appointments) {
    this.appointments = appointments;
  }
}
