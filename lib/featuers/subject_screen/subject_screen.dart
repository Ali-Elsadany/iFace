import 'package:flutter/material.dart';

import '../../core/utils/app_colors.dart';
import '../doctor_group_screen/doctor_screen_math.dart';
import '../doctor_group_screen/doctor_screen_physics.dart';

class SubjectScreen extends StatefulWidget {
  const SubjectScreen({super.key});

  @override
  State<SubjectScreen> createState() => _SubjectScreenState();
}

class _SubjectScreenState extends State<SubjectScreen> {
  bool _isTextVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.secondary,
      appBar: AppBar(
        leading: IconButton(onPressed: (){

        },
          icon: const Icon(Icons.arrow_back,color: AppColor.primary,),),
        actions: [IconButton(
          icon: const Icon(Icons.help,color: AppColor.stringColor,),
          onPressed: () {
            setState(() {
              _isTextVisible = !_isTextVisible;
            });
          },
        ),],
        backgroundColor: AppColor.primary,
        title: const Text('Subjects',style: TextStyle(color: AppColor.stringColor,fontSize: 24),),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 30,right: 30,top: 15,bottom: 15),
          child: Column(
            children: [
              //Text('Tip: Teacher or Doctor choose their subject',style: TextStyle(color: AppColor.stringColor,fontSize: 24),textAlign: TextAlign.center),
              Visibility(
                visible: _isTextVisible,
                child: const Text('Teacher or Doctor choose their subject',style: TextStyle(color: AppColor.stringColor,fontSize: 24),textAlign: TextAlign.center),
              ),
              const SizedBox(height: 20,),
              InkWell(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) =>
                      const DoctorMathScreen()));
                },
                child: Container(
                  height: 62,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColor.primary,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Center(child: Text('Math',style: TextStyle(color: AppColor.stringColor,fontSize: 24))),
                ),
              ),
              const SizedBox(height: 20,),
              InkWell(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) =>
                      const DoctorPhysicsScreen()));
                },
                child: Container(
                  height: 62,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColor.primary,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Center(child: Text('Physics',style: TextStyle(color: AppColor.stringColor,fontSize: 24))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}