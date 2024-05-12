// ignore_for_file: depend_on_referenced_packages
//import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:facesdk_plugin/facesdk_plugin.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
//import 'package:path/path.dart' as Path;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;
import 'about.dart';
import 'app/app.dart';
import 'core/utils/app_assets.dart';
import 'core/utils/app_colors.dart';
import 'core/utils/app_strings.dart';
import 'featuers/home_screen/home_screen.dart';
import 'featuers/login_screen/login_screen.dart';
import 'featuers/sign_up_screen/sign_up_screen.dart';
import 'featuers/subject_screen/subject_screen.dart';
import 'settings.dart';
import 'person.dart';
import 'personview.dart';
import 'facedetectionview.dart';

void main() {
  runApp(const MyApp());
}


// ignore: must_be_immutable
class MyHomePage extends StatefulWidget {
  final String title;
  var personList = <Person>[];

  MyHomePage({super.key, required this.title});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  String _warningState = "";
  bool _visibleWarning = false;

  final _facesdkPlugin = FacesdkPlugin();

  @override
  void initState() {
    super.initState();

    init();
  }

  Future<void> init() async {
    int facepluginState = -1;
    String warningState = "";
    bool visibleWarning = false;

    /// licence

    try {
      if (Platform.isAndroid) {
        await _facesdkPlugin
            .setActivation(
                "CFO+UUpNLaDMlmdjoDlhBMbgCwT27CzQJ4xHpqe9rDOErwoEUeCGPRTfQkZEAFAFdO0+rTNRIwnQ"
                 "wpqqGxBbfnLkfyFeViVS5bpWZFk15QXP3ZtTEuU1rK5zsFwcZrqRUxsG9dXImc+Vw5Ddc9zBp9GE"
                 "UuDycHLqC9KgQGVb0TS2u9Kz67HQOSDw9hskjBpjRbqiG+F/h5DBLPzjgFh1Y6vzgg6I59FzTOcd"
                 "rdEbX7kI15Nwgf1hvHGtSgON/a0Fmw+XNdnxH2pVY96mcTemHYZAtxh8lA/t1DtTyZXpHjW8N6nq"
                 "4UN2YDlKLXSrDzLpLHJmBsdpH71AXb7dfAq94Q==")
            .then((value) => facepluginState = value ?? -1);
      } else {
        await _facesdkPlugin
            .setActivation(
                "nWsdDhTp12Ay5yAm4cHGqx2rfEv0U+Wyq/tDPopH2yz6RqyKmRU+eovPeDcAp3T3IJJYm2LbPSEz"
                "+e+YlQ4hz+1n8BNlh2gHo+UTVll40OEWkZ0VyxkhszsKN+3UIdNXGaQ6QL0lQunTwfamWuDNx7Ss"
                "efK/3IojqJAF0Bv7spdll3sfhE1IO/m7OyDcrbl5hkT9pFhFA/iCGARcCuCLk4A6r3mLkK57be4r"
                "T52DKtyutnu0PDTzPeaOVZRJdF0eifYXNvhE41CLGiAWwfjqOQOHfKdunXMDqF17s+LFLWwkeNAD"
                "PKMT+F/kRCjnTcC8WPX3bgNzyUBGsFw9fcneKA==")
            .then((value) => facepluginState = value ?? -1);
      }

      if (facepluginState == 0) {
        await _facesdkPlugin
            .init()
            .then((value) => facepluginState = value ?? -1);
      }
    } catch (e) {}



    List<Person> personList = await loadAllPersons();
    await SettingsPageState.initSettings();

    final prefs = await SharedPreferences.getInstance();
    int? livenessLevel = prefs.getInt("liveness_level");

    try {
      await _facesdkPlugin
          .setParam({'check_liveness_level': livenessLevel ?? 0});
    } catch (e) {}

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    if (facepluginState == -1) {
      warningState = "Invalid license!";
      visibleWarning = true;
    } else if (facepluginState == -2) {
      warningState = "License expired!";
      visibleWarning = true;
    } else if (facepluginState == -3) {
      warningState = "Invalid license!";
      visibleWarning = true;
    } else if (facepluginState == -4) {
      warningState = "No activated!";
      visibleWarning = true;
    } else if (facepluginState == -5) {
      warningState = "Init error!";
      visibleWarning = true;
    }

    setState(() {
      _warningState = warningState;
      _visibleWarning = visibleWarning;
      widget.personList = personList;
    });
  }
  ///ends here
      // Database hnaa b sql

  Future<Database> createDB() async {
    final database = openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), 'person.db'),
      // When the database is first created, create a table to store dogs.
      onCreate: (db, version) {
        // Run the CREATE TABLE statement on the database.
        return db.execute(
          'CREATE TABLE person(name text, faceJpg blob, templates blob)',
        );
      },
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: 1,
    );

    return database;
  }

  // A method that retrieves all the dogs from the dogs table.
  Future<List<Person>> loadAllPersons() async {
    // Get a reference to the database.
    final db = await createDB();

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('person');

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return Person.fromMap(maps[i]);
    });
  }

  Future<void> insertPerson(Person person) async {
    // Get a reference to the database.
    final db = await createDB();

    // Insert the Dog into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same dog is inserted twice.
    //
    // In this case, replace any previous data.
    await db.insert(
      'person',
      person.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    setState(() {
      widget.personList.add(person);
    });
  }

  Future<void> deleteAllPerson() async {
    final db = await createDB();
    await db.delete('person');

    setState(() {
      widget.personList.clear();
    });

    Fluttertoast.showToast(
        msg: "All person deleted!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  Future<void> deletePerson(index) async {
    // ignore: invalid_use_of_protected_member

    final db = await createDB();
    await db.delete('person',
        where: 'name=?', whereArgs: [widget.personList[index].name]);

    // ignore: invalid_use_of_protected_member
    setState(() {
      widget.personList.removeAt(index);
    });

    Fluttertoast.showToast(
        msg: "Person removed!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

        /// enroll ll sora el adeema elly htb2a f el signUp

  Future<void> enrollPerson() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.camera);     /// hna hn8yr en el sora tta5d mn camera msh mn el gallary
      if (image == null) return;

      var rotatedImage =
          await FlutterExifRotation.rotateImage(path: image.path);

      final faces = await _facesdkPlugin.extractFaces(rotatedImage.path);
      for (var face in faces) {
        num randomNumber =
            10000 + Random().nextInt(10000); // from 0 upto 99 included
        Person person = Person(
            name: 'Person' + randomNumber.toString(),
            faceJpg: face['faceJpg'],
            templates: face['templates']);
        insertPerson(person);
      }

      if (faces.length == 0) {
        Fluttertoast.showToast(
            msg: "No face detected!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      } else {
        Fluttertoast.showToast(
            msg: "Sign up successful!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } catch (e) {}
  }

/// Default
/*
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Face Recognition'),
        toolbarHeight: 70,
        centerTitle: true,
      ),
      body: Container(
        margin: const EdgeInsets.only(left: 16.0, right: 16.0),
        child: Column(
          children: <Widget>[
            const Card(
                color: Color.fromARGB(255, 0x49, 0x45, 0x4F),
                child: ListTile(
                  leading: Icon(Icons.tips_and_updates),
                  subtitle: Text(
                    'KBY-AI offers SDKs for face recognition, liveness detection, and id document recognition.',
                    style: TextStyle(fontSize: 13),
                  ),
                )),
            const SizedBox(
              height: 6,
            ),
            Row(
              children: <Widget>[
                Expanded(
                  flex: 1,

                  /// Zorar el enroll hna hyb2a mkan el SignUp

                  child: ElevatedButton.icon(
                      label: const Text('Enroll'),
                      icon: const Icon(
                        Icons.person_add,
                        // color: Colors.white70,
                      ),
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                          // foregroundColor: Colors.white70,
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12.0)),
                          )),
                      onPressed: enrollPerson),
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 1,

                  /// zorar el identify hnaa mkan Zoraar el Login

                  child: ElevatedButton.icon(
                      label: const Text('Identify'),
                      icon: const Icon(
                        Icons.person_search,
                      ),
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12.0)),
                          )),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FaceRecognitionView(
                                    personList: widget.personList,
                                  )),
                        );
                      }),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: ElevatedButton.icon(
                      label: const Text('Settings'),
                      icon: const Icon(
                        Icons.settings,
                      ),
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12.0)),
                          )),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SettingsPage(
                                    homePageState: this,
                                  )),
                        );
                      }),
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 1,
                  child: ElevatedButton.icon(
                      label: const Text('About'),
                      icon: const Icon(
                        Icons.info,
                      ),
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12.0)),
                          )),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AboutPage()),
                        );
                      }),
                ),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            Expanded(
                child: Stack(
              children: [
                PersonView(
                  personList: widget.personList,
                  homePageState: this,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Visibility(
                        visible: _visibleWarning,
                        child: Container(
                          width: double.infinity,
                          height: 40,
                          color: Colors.redAccent,
                          child: Center(
                            child: Text(
                              _warningState,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        ))
                  ],
                )
              ],
            )),
            const SizedBox(
              height: 4,
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image(
                  image: AssetImage('assets/ic_kby.png'),
                  width: 48,
                ),
                SizedBox(width: 4),
                Text('KBY-AI Technology',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color.fromARGB(255, 60, 60, 60),
                    ))
              ],
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
*/

/// Doctor Screen
/*
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.secondary,
      appBar: AppBar(
        backgroundColor: AppColor.primary,
        title: Text('Doctor',style: TextStyle(color: AppColor.stringColor,fontSize: 24),),
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
              SizedBox(height: 20,),
              InkWell(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) =>
                      HomeScreen()));
                },
                child: Container(
                  height: 62,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColor.primary,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(child: Text('Dr.Ahmed - G.1',style: TextStyle(color: AppColor.stringColor,fontSize: 24))),
                ),
              ),
              SizedBox(height: 20,),
              InkWell(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) =>
                      HomeScreen()));
                },
                child: Container(
                  height: 62,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColor.primary,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(child: Text('Dr.Nada - G.2',style: TextStyle(color: AppColor.stringColor,fontSize: 24))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
*/
/// home screen
  /*
  final formKey = GlobalKey<FormState>();

  bool _isTextVisible = false;
  TextEditingController _emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return  SafeArea(
      child: Scaffold(
        backgroundColor: AppColor.primary,
        body: Center(
          child: Column(
            children: [
              SizedBox(
                height: 32,
              ),
              SizedBox(
                  height: 200,
                  width: 200,
                  child: Image.asset(AppAssets.appLogo)),
              SizedBox(
                height: 45,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 557,
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
                        Text('Help',style: TextStyle(color: AppColor.stringColor,fontSize: 20),),
                        IconButton(
                          icon: Icon(Icons.help,color: AppColor.stringColor,),
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
                      child: Text(AppStrings.text1,style: TextStyle(color: AppColor.stringColor,fontSize: 26),textAlign: TextAlign.center),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Visibility(
                      visible: _isTextVisible,
                      child: Text(AppStrings.text2,style: TextStyle(color: AppColor.stringColor,fontSize: 26),textAlign: TextAlign.center),
                    ),
                    Visibility(
                      visible: _isTextVisible,
                      child: Text('- When the Lecture is over click Finish',style: TextStyle(color: AppColor.stringColor,fontSize: 26),textAlign: TextAlign.center),
                    ),

                    Spacer(),
                    // finish button
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
                                decoration: BoxDecoration(
                                    color: AppColor.secondary,
                                    borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20))
                                ),

                                padding: EdgeInsets.all(10),
                                child: Form(
                                  key: formKey,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,

                                    children: [
                                      Text('*Note: Please enter valid Email to send you the attendance',style: TextStyle(color: AppColor.stringColor),textAlign: TextAlign.center),
                                      SizedBox(height: 50,),

                                      TextFormField(

                                        style: const TextStyle(color: AppColor.stringColor),
                                        textInputAction: TextInputAction.done,
                                        keyboardType: TextInputType.name,
                                        controller: _emailController,
                                        decoration: InputDecoration(
                                            prefixIcon: Icon(Icons.mail,color: AppColor.primary,),
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

                                      SizedBox(height: 100),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          // close button
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
                                          SizedBox(width: 40,),
                                          // send button
                                          ElevatedButton(onPressed: (){
                                            // hnb3t 3ala el email hna

                                            if(formKey.currentState!.validate()) {
                                              Navigator.pushReplacement(
                                                  context, MaterialPageRoute(builder: (context) =>
                                                  SubjectScreen()));
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
                    SizedBox(height: 30),
                    Row(
                      children: [

                        /// Login button

                        ElevatedButton(
                          onPressed: (){

                            //Navigator.push(context, MaterialPageRoute(builder: (context) =>
                               // LoginScreen(faceRecognitionView: this,)));
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
                        SizedBox(
                          width: 40,
                        ),

                        /// SignUp button

                        ElevatedButton(
                          onPressed: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                SignUpScreen(homePageState: this,)));

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
                    SizedBox(
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
*/

  /// login Screen

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

                      /// Open Camera Button

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
      final apiUrl = 'https://a706-197-43-8-98.ngrok-free.app/auth/login'; // Replace with your API endpoint

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          body: json.encode({"id": id}),
          headers: {'Content-Type': 'application/json'},
        );

        /// hna hn7oot el navigator bs el api lazeem yzboot el awll

        if (response.statusCode == 200) {
          // Successfully signed up
          print('Login Successfully');

          Navigator.push(
            this.context,
            MaterialPageRoute(
                builder: (context) => FaceRecognitionView(
                  personList: widget.personList,
                )),
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


  /// SignUp Screen
/*
  final formKey = GlobalKey<FormState>();

  TextEditingController _nameController = TextEditingController();

  TextEditingController _idController = TextEditingController();

  var _counterText ="";

  String _errorMessage = '';
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

                    // Name

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

                    // ID

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

                    // Open Camera button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: enrollPerson,
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
*/
}
