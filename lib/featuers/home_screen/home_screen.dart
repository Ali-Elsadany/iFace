import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import '../../../core/utils/app_assets.dart';
import '../../../core/utils/app_strings.dart';
import '../../core/utils/app_colors.dart';
import '../../main.dart';
import '../sign_up_screen/sign_up_screen.dart';
import '../subject_screen/subject_screen.dart';

class HomeScreen extends StatefulWidget {

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final formKey = GlobalKey<FormState>();

  bool _isTextVisible = false;
  final TextEditingController _emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return  SafeArea(
      child: Scaffold(
        backgroundColor: AppColor.primary,
        body: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 32,
              ),
              SizedBox(
                  height: 200,
                  width: 200,
                  child: Image.asset(AppAssets.appLogo)),
              const SizedBox(
                height: 45,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 535,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage(AppAssets.background),

                  ),
                ),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(31),
                child:  Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Help',style: TextStyle(color: AppColor.stringColor,fontSize: 20),),
                        IconButton(
                          icon: const Icon(Icons.help,color: AppColor.stringColor,),
                          onPressed: () {
                            setState(() {
                              _isTextVisible = !_isTextVisible;
                            });
                          },
                        ),
                      ],
                    ),

                    Visibility(
                      visible: _isTextVisible,
                      child: const Text(AppStrings.text1,style: TextStyle(color: AppColor.stringColor,fontSize: 26),textAlign: TextAlign.center),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Visibility(
                      visible: _isTextVisible,
                      child: const Text(AppStrings.text2,style: TextStyle(color: AppColor.stringColor,fontSize: 26),textAlign: TextAlign.center),
                    ),
                    Visibility(
                      visible: _isTextVisible,
                      child: const Text('- When the Lecture is over click Finish',style: TextStyle(color: AppColor.stringColor,fontSize: 26),textAlign: TextAlign.center),
                    ),

                   // const SizedBox(
                    //  height: 15,
                    //),
                    const Spacer(),

                    /// finish button

                    ElevatedButton(
                      onPressed: (){
                        showModalBottomSheet(
                          isScrollControlled: true,
                          context: context,
                          builder: (BuildContext context) {
                            return Padding(
                              padding: EdgeInsets.only(
                                  bottom: MediaQuery.of(context).viewInsets.bottom),
                              child: Container(
                                height: 400,
                                decoration: const BoxDecoration(
                                    color: AppColor.secondary,
                                    borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20))
                                ),

                                padding: const EdgeInsets.all(10),
                                child: Form(
                                  key: formKey,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,

                                    children: [
                                      const Text('*Note: Please enter valid Email to send you the attendance',style: TextStyle(color: AppColor.stringColor),textAlign: TextAlign.center),
                                      const SizedBox(height: 50,),

                                      TextFormField(

                                        style: const TextStyle(color: AppColor.stringColor),
                                        textInputAction: TextInputAction.done,
                                        keyboardType: TextInputType.name,
                                        controller: _emailController,
                                        decoration: InputDecoration(
                                            prefixIcon: const Icon(Icons.mail,color: AppColor.primary,),
                                            hintText: 'Enter your Email',
                                            hintStyle: const TextStyle(color: AppColor.stringColor),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(color: AppColor.stringColor),borderRadius:BorderRadius.circular(20),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(color: AppColor.stringColor),borderRadius:BorderRadius.circular(20),
                                            ),
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                                            errorBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.red),borderRadius: BorderRadius.circular(20)),
                                            labelText: 'Email',
                                            labelStyle: const TextStyle(color: AppColor.stringColor)

                                        ),
                                        validator: (value){
                                          // final RegExp regex = RegExp('[a-zA-Z]');
                                          if(value!.isEmpty){
                                            return 'Enter Your Email';
                                          }
                                          if(!value.contains('@gmail.com')){
                                            return 'Enter Valid Email *example@gmail.com*';

                                          }
                                          /*
                                                             if(!regex.hasMatch(value)){
                                                               return 'Name Contains number ?!';
                                                             }
                                                                            */
                                          return null;
                                        },

                                      ),

                                      const SizedBox(height: 100),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [

                                          /// close button

                                          ElevatedButton(onPressed: (){
                                            Navigator.pop(context);
                                          },
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: AppColor.primary,
                                                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                                textStyle: const TextStyle(
                                                  fontSize: 30,
                                                ),
                                                shadowColor: AppColor.primary
                                            ),
                                            child: const Text('Close',style: TextStyle(color: AppColor.stringColor),),),
                                          const SizedBox(width: 40,),

                                          /// send button

                                          ElevatedButton(onPressed: (){
                                            // hnb3t 3ala el email hna

                                            if (formKey.currentState!.validate()) {
                                              sendEmail(_emailController.text);
                                            }
                                          },
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: AppColor.primary,
                                                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                                textStyle: const TextStyle(
                                                  fontSize: 30,
                                                ),
                                                shadowColor: AppColor.primary
                                            ),
                                            child: const Text('Send',style: TextStyle(color: AppColor.stringColor),),),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
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
                      child: const Text('Finish',style: TextStyle(color: AppColor.stringColor),),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [

                        /// Login button

                        ElevatedButton(
                          onPressed: (){

                            Navigator.push(context, MaterialPageRoute(builder: (context) =>
                            // LoginScreen(homePage: MyHomePage(title: 'face Recognition',),)
                              MyHomePage(title: 'face Recognition')
                            ));
                          },

                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.primary,
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                              textStyle: const TextStyle(
                                fontSize: 30,
                              ),
                              shadowColor: AppColor.primary
                          ),
                          child: const Text(AppStrings.login,style: TextStyle(color: AppColor.stringColor),),
                        ),
                        const SizedBox(
                          width: 35,
                        ),

                        /// SignUp button

                        ElevatedButton(
                          onPressed: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                SignUpScreen( homePage: MyHomePageState(),)));

                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.primary,
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                              textStyle: const TextStyle(
                                fontSize: 30,
                              )),
                          child: const Text(AppStrings.signup,style: TextStyle(color: AppColor.stringColor),),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 52,
                    )
                  ],
                ),

              ),



            ],
          ),

        ),
      ),
    );
  }
  Future<void> sendEmail(String email) async {
    final url = Uri.parse('https://24ec-197-54-131-80.ngrok-free.app/auth/attendance');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: '{"doctorEmail": "$email"}',
    );

    if (response.statusCode == 200) {
      // Email sent successfully
      Fluttertoast.showToast(
        msg: 'Email sent successfully',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) =>
      const SubjectScreen()));

    } else {
      // Failed to send email
      print('Failed to send email');
      Fluttertoast.showToast(
        msg: 'Failed to send email',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }
}
