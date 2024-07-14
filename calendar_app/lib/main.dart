import 'package:flutter/material.dart';

import 'package:calendar_app/widget/mainpage_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firebase_options.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
  );

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Form',
      theme: ThemeData(),
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('vi'),
      ],
    );
  }
}

class LoginScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double padding = size.width * 0.05;
    final double fontSize = size.width * 0.05;
    final double buttonHeight = size.height * 0.07;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 10, 10, 9),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'ĐĂNG NHẬP',
                style: TextStyle(
                  fontSize: fontSize * 1.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              SizedBox(height: size.height * 0.03),
              TextField(
                controller: emailController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle:
                      TextStyle(color: Colors.white, fontSize: fontSize),
                  prefixIcon: const Icon(
                    Icons.email,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.03),
              TextField(
                controller: passwordController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Mật khẩu',
                  labelStyle:
                      TextStyle(color: Colors.white, fontSize: fontSize),
                  prefixIcon: const Icon(
                    Icons.lock,
                    color: Colors.white,
                  ),
                ),
                obscureText: true,
              ),
              SizedBox(height: size.height * 0.01),
              TextButton(
                onPressed: () {
                  _sendPasswordResetEmail(context);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lock_open,
                      size: fontSize,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Quên mật khẩu',
                      style: TextStyle(
                        fontSize: fontSize * 0.8,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: size.height * 0.03),
              ElevatedButton(
                onPressed: () async {
                  _loginwithemail(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 54, 152, 244),
                  minimumSize: Size(double.infinity, buttonHeight),
                ),
                child: Text(
                  'Đăng Nhập',
                  style: TextStyle(
                    fontSize: fontSize,
                    color: const Color.fromARGB(255, 225, 225, 226),
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.03),
              ElevatedButton(
                onPressed: () async {
                  User? user = await signInWithGoogle();
                  if (user != null) {
                    scheduleNotification(user.email ?? '');
                    // Điều hướng đến trang chính (home) sau khi đăng nhập thành công
                    // ignore: use_build_context_synchronously
                    Navigator.pushReplacement(
                      // ignore: use_build_context_synchronously
                      context,
                      MaterialPageRoute(
                        builder: (context) => MainPage(
                          userId: user.uid,
                          useremail: user.email ?? '',
                        ),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                  minimumSize: Size(double.infinity, buttonHeight),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Image(
                      image: AssetImage(
                          'assets/logo_google.png'), // Đường dẫn đến biểu tượng Google
                      height: 30, // Chiều cao của biểu tượng
                      width: 30, // Chiều rộng của biểu tượng
                    ),
                    Text(
                      'Đăng nhập với Google ',
                      style: TextStyle(
                        fontSize: fontSize,
                        color: const Color.fromARGB(255, 2, 2, 2),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: size.height * 0.01),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterScreen()),
                  );
                },
                child: Text(
                  'Bạn chưa có tài khoản? Đăng ký ở đây',
                  style: TextStyle(
                    fontSize: fontSize * 0.8,
                    color: const Color.fromARGB(255, 225, 225, 226),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _loginwithemail(BuildContext context) async {
    // Handle login logic here
    String email = emailController.text;
    String password = passwordController.text;

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      String userId = userCredential.user!.uid;
      String useremail = userCredential.user!.email ?? '';

      // ignore: use_build_context_synchronously
      scheduleNotification(useremail);
      Navigator.push(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
          builder: (context) => MainPage(
            userId: userId,
            useremail: useremail,
          ),
        ),
      );
    } catch (e) {
      // ignore: use_build_context_synchronously

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Đăng nhập không thành công. Vui lòng kiểm tra lại tên người dùng và mật khẩu.'),
        ),
      );
    }
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  Future<User?> signInWithGoogle() async {
    try {
      // Step 1: Sign in with Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // Handle case where user cancels sign-in
      if (googleUser == null) {
        return null;
      }

      // Step 2: Get Google authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Step 3: Create Firebase credentials
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Step 4: Sign in with Firebase using credentials
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      // Return the authenticated user
      return userCredential.user;
    } catch (e) {
      // Handle any errorsprint

      return null;
    }
  }

  void _sendPasswordResetEmail(BuildContext context) async {
    final String email = emailController.text;

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập địa chỉ email.'),
        ),
      );
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã gửi email đặt lại mật khẩu đến $email'),
        ),
      );
    } catch (e) {
      String errorMessage = 'Có lỗi xảy ra. Vui lòng thử lại sau.';
      if (e is FirebaseAuthException) {
        if (e.code == 'invalid-email') {
          errorMessage = 'Email không hợp lệ. Vui lòng kiểm tra lại.';
        }
      }
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
        ),
      );
    }
  }

  void scheduleNotification(String useremail) async {
    List<Map<String, dynamic>> notifications = [];

    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection(useremail).get();

    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      if (data['startTime'] != null) {
        DateTime time = (data['startTime'] as Timestamp).toDate();
        notifications.add({
          'id': doc.id.hashCode,
          'title': data['title'],
          'body': data['note'],
          'time': DateTime(
            time.year,
            time.month,
            time.day,
            time.hour,
            time.minute,
          ),
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

    List<PendingNotificationRequest> pendingNotifications =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();

    for (var pendingNotification in pendingNotifications) {
      int id = pendingNotification.id;
      DateTime scheduledDate =
          tz.TZDateTime.now(tz.local).add(Duration(seconds: id));
      if (scheduledDate.isBefore(DateTime.now())) {
        await flutterLocalNotificationsPlugin.cancel(id);
      }
    }

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

class RegisterScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double padding = size.width * 0.05;
    final double buttonHeight = size.height * 0.07;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng Ký'),
      ),
      body: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(
                  Icons.email,
                  color: Color.fromARGB(255, 17, 17, 17),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Mật khẩu',
                prefixIcon: Icon(
                  Icons.lock,
                  color: Color.fromARGB(255, 17, 17, 17),
                ),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Xác nhận mật khẩu',
                prefixIcon: Icon(
                  Icons.lock,
                  color: Color.fromARGB(255, 17, 17, 17),
                ),
              ),
              obscureText: true,
            ),
            SizedBox(height: size.height * 0.03),
            ElevatedButton(
              onPressed: () async {
                _Register(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 54, 152, 244),
                minimumSize: Size(double.infinity, buttonHeight),
              ),
              child: const Text(
                'Đăng Ký',
                style: TextStyle(
                  fontSize: 20,
                  // ignore: unnecessary_const
                  color: const Color.fromARGB(255, 225, 225, 226),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  void _Register(BuildContext context) async {
    String email = emailController.text;
    String password = passwordController.text;
    String confirmPassword = confirmPasswordController.text;
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập địa chỉ email.'),
        ),
      );
      return;
    }
    if (password.length < 6) {
      // Điều kiện mật khẩu ít nhất 6 ký tự
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mật khẩu phải có ít nhất 6 ký tự.'),
        ),
      );
      return;
    }
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mật khẩu xác nhận không khớp.'),
        ),
      );
      return;
    }
    try {
      // ignore: unused_local_variable
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      Navigator.push(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(
            builder: (context) => LoginScreen(),
          ));
    } catch (e) {
      String errorMessage = '$e';
      if (e is FirebaseAuthException) {
        if (e.code == 'invalid-email') {
          errorMessage = 'Email không hợp lệ. Vui lòng kiểm tra lại.';
        } else if (e.code == 'email-already-in-use') {
          errorMessage =
              'Email này đã được sử dụng. Vui lòng sử dụng email khác.';
        }
      }
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
        ),
      );
    }
  }
}
