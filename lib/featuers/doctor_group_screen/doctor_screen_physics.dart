import 'package:flutter/material.dart';

import '../../core/utils/app_colors.dart';
import '../home_screen/home_screen.dart';


class DoctorPhysicsScreen extends StatelessWidget {
  const DoctorPhysicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.secondary,
      appBar: AppBar(
        backgroundColor: AppColor.primary,
        title: const Text('Doctor',style: TextStyle(color: AppColor.stringColor,fontSize: 24)),
        centerTitle: true,
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        },
          icon: const Icon(Icons.arrow_back,color: AppColor.stringColor,),),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 30,right: 30,top: 15,bottom: 15),
          child: Column(
            children: [
              const SizedBox(height: 20,),
              InkWell(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) =>
                      const HomeScreen()));
                },
                child: Container(
                  height: 62,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColor.primary,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Center(child: Text('Dr.Mohammed - G.1',style: TextStyle(color: AppColor.stringColor,fontSize: 24))),
                ),
              ),
              const SizedBox(height: 20,),
              InkWell(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) =>
                      const HomeScreen()));
                },
                child: Container(
                  height: 62,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColor.primary,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Center(child: Text('Dr.Khaled - G.2',style: TextStyle(color: AppColor.stringColor,fontSize: 24))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
