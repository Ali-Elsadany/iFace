import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../core/utils/app_strings.dart';
import '../../core/utils/app_colors.dart';
import '../../facedetectionview.dart';
import '../../main.dart';
import '../../person.dart';


class LoginScreen extends StatefulWidget {

  final MyHomePage homePage;

 // final FaceRecognitionView faceRecognitionView;

   const LoginScreen({super.key, required this.homePage});


   @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  //final MyHomePage objName = MyHomePage();

 // get fun {
  //  objName.personList;
  //}

  final formKey = GlobalKey<FormState>();

  TextEditingController _idController = TextEditingController();


  String _errorMessage = '';

  var _counterText = "";

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          backgroundColor: AppColor.secondary,
          appBar: AppBar(
            backgroundColor: AppColor.primary,
            leading: IconButton(onPressed: (){
              Navigator.pop(context);
            },
              icon: const Icon(Icons.arrow_back,color: AppColor.stringColor,),),
            centerTitle: true,
            title: const Text(AppStrings.login,style: TextStyle(color: AppColor.stringColor,fontSize: 24),),
          ),
          body:  Center(
            child: Padding(
                padding: const EdgeInsets.all(10),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 55,
                      ),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => FaceRecognitionView(
                                      personList: widget.homePage.personList,
                                    )),
                              );

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
                )

            ),
          ),
        )
    );
  }
  Future<void> _submitForm() async {
    if (formKey.currentState!.validate()) {

      final id = _idController.text;

      // Call your API here
      final apiUrl = 'https://4de7-197-54-233-2.ngrok-free.app/auth/login'; // Replace with your API endpoint

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          body: json.encode({"id": id}),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200) {
          // Successfully signed up
          Fluttertoast.showToast(
            msg: "Login successful!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );
          // Navigate to the next screen or perform any other action
          // For example:
        } else {
          // Error handling
          Fluttertoast.showToast(
            msg: "Sign up First",
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
