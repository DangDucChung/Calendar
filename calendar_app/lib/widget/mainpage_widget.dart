import 'package:flutter/material.dart';
import 'package:calendar_app/main.dart';
import 'package:calendar_app/widget/Evaluate_widget.dart';
import 'package:calendar_app/widget/ask_widget.dart';
import 'package:calendar_app/widget/calendar_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';


class MainPage extends StatelessWidget {
  
  final String userId;
  final String useremail;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

 MainPage({super.key, required this.userId, required this.useremail});
  
  @override
  Widget build(BuildContext context) => Scaffold(
    
        drawer: Drawer(
            child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.indigo,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.account_circle,
                    color: Colors.white70,
                    size: 100,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    useremail,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(
               Icons.bar_chart,
                color: Colors.indigo,
              ),
              title: const Text('Đánh giá'),
              onTap: () {
                 Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  PieChartSample2(useremail: useremail)),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.chat,
                color: Colors.indigo,
              ),
              title: const Text('Đặt câu hỏi cho AI'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AskAiPage()),
                );

              },
            ),
            ListTile(
              leading: const Icon(
                Icons.logout_outlined,
                color: Colors.indigo,
              ),
              title: const Text('Đăng xuất'),
              onTap: () async {
                FirebaseAuth.instance.signOut();
                 await _googleSignIn.signOut();

                flutterLocalNotificationsPlugin.cancelAll();
                Navigator.push(
                  // ignore: use_build_context_synchronously
                  context,
                  MaterialPageRoute(builder: (context) => const MyApp()),
                );
              },
            )
          ],
        )),
        appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 0, 0, 0),
            title: const Text("Lịch Biểu",
                style: TextStyle(color: Colors.white)),
            centerTitle: true,
            leading: const SizedBox.shrink(),
            actions: [
              Builder(builder: (BuildContext context) {
                return IconButton(
                  icon: const Icon(Icons.account_circle), // Icon người dùng
                  color: Colors.white, // Đặt màu của biểu tượng là màu trắng
                  iconSize: 40,
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                    
                  },
                );
              })
            ]),
        body: CalendarWidget(useremail: useremail),
      );
}
