import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_strings.dart';
import '../../main.dart';


class SignUpScreen extends StatefulWidget {

  //final MyHomePage homePage;
  final MyHomePageState homePage;

  const SignUpScreen({super.key, required this.homePage});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {

 // final MyHomePageState? enroll;

  //final MyHomePageState objName = MyHomePageState();

  final formKey = GlobalKey<FormState>();

  TextEditingController _nameController = TextEditingController();

  TextEditingController _idController = TextEditingController();

  var _counterText ="";

  String _errorMessage = '';

 // void callingFunciton() {
  //objName.enrollPerson();
//}

  @override
  Widget build(BuildContext context) {
    return  SafeArea(
        child: Scaffold(
          backgroundColor: AppColor.secondary,
          appBar: AppBar(
            backgroundColor: AppColor.primary,
            leading: IconButton(onPressed: (){
              Navigator.pop(context);
            },
              icon: const Icon(Icons.arrow_back,color: AppColor.stringColor,),),
            centerTitle: true,
            title: const Text(AppStrings.signup,style: TextStyle(color: AppColor.stringColor,fontSize: 24),),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20,),

                    /// Name

                    TextFormField(
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp('[a-z A-Z]'))
                      ],
                      style: const TextStyle(color: AppColor.stringColor),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.name,
                      controller: _nameController,
                      decoration: InputDecoration(
                        //prefixIcon: Icon(Icons.mail,color: AppColor.primary,),
                          hintText: AppStrings.enterName,
                          hintStyle: const TextStyle(color: AppColor.stringColor),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: AppColor.stringColor),borderRadius:BorderRadius.circular(20),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: AppColor.stringColor),borderRadius:BorderRadius.circular(20),
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                          errorBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.red),borderRadius: BorderRadius.circular(20)),
                          labelText: AppStrings.name,
                          labelStyle: const TextStyle(color: AppColor.stringColor)

                      ),
                      validator: (value){
                        // final RegExp regex = RegExp('[a-zA-Z]');
                        if(value == null || value.isEmpty ){
                          return 'Enter Your Name';
                        }
/*
                        if(!regex.hasMatch(value)){
                          return 'Name Contains number ?!';
                        }
*/
                        return null;
                      },

                    ),
                    SizedBox(height: 20,),

                    /// ID

                    TextFormField(
                      onChanged: (value){
                        setState(() {
                          _counterText = (8 - value.length).toString();
                        });
                      },
                      maxLength: 8,
                      style: const TextStyle(color: AppColor.stringColor),
                      keyboardType: TextInputType.number,
                      controller: _idController,
                      decoration: InputDecoration(
                        //prefixIcon: Icon(Icons.mail,color: AppColor.primary,),
                          counterStyle: const TextStyle(
                            color: AppColor.stringColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          counterText: 'Remaining: $_counterText',
                          hintText: AppStrings.enterId,
                          hintStyle: const TextStyle(color: AppColor.stringColor),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: AppColor.stringColor),borderRadius:BorderRadius.circular(20),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: AppColor.stringColor),borderRadius:BorderRadius.circular(20),
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                          errorBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.red),borderRadius: BorderRadius.circular(20)),
                          labelText: AppStrings.id,
                          labelStyle: const TextStyle(color: AppColor.stringColor)

                      ),
                      validator: (value){
                        if(value == null || value.isEmpty){
                          return 'Enter Your ID';
                        }

                        if(value.length < 8){
                          return 'ID not Valid';
                        }

                        return null;
                      },

                    ),
                    const Spacer(),

                    /// Open Camera button

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _submitForm();
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.primary,
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                              textStyle: const TextStyle(
                                fontSize: 30,
                              ),
                              shadowColor: AppColor.primary
                          ),
                          child: const Text(AppStrings.openImage,style: TextStyle(color: AppColor.stringColor),),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 50,
                    )
                  ],
                ),
              ),
            ),
          ),
        )
    );
  }
  Future<void> _submitForm() async {
    if (formKey.currentState!.validate()) {
      final name = _nameController.text;
      final id = _idController.text;

      /// Call your API here

      final apiUrl = 'https://24ec-197-54-131-80.ngrok-free.app/auth/register'; // Replace with your API endpoint

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          body: json.encode({"userName": name, "id": id}),
          headers: {'Content-Type': 'application/json'},
        );
        //widget.homePage.enrollPerson();

        if (response.statusCode == 200) {
          // Successfully signed up

            print('Name and id sent successfully');

         widget.homePage.enrollPerson();
          // Navigate to the next screen or perform any other action
          // For example:
        } else {
          // Error handling
          Fluttertoast.showToast(
            msg: "You are already existed",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
      } catch (e) {
        // Exception handling
        setState(() {
          _errorMessage = 'Error: $e';
        });
      }
    }
  }
}

