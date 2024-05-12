import 'package:flutter/material.dart';


import '../featuers/subject_screen/subject_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Face Recognition',
        theme: ThemeData(
          // Define the default brightness and colors.
          useMaterial3: true,
          brightness: Brightness.dark,
        ),
        //home: MyHomePage(title: 'Face Recognition'));
       // home: MyHomePage(title: 'face Recognition',));
        home: const SubjectScreen());
  }
}
