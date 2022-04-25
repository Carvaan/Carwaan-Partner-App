import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:async/async.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'main.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final email_Controller = TextEditingController();
  final name_Controller = TextEditingController();
  final phone_Controller = TextEditingController();
  final password_Controller = TextEditingController();
  final cnic_Controller = TextEditingController();
  final location_Controller = TextEditingController();
  final storage = const FlutterSecureStorage();
  var picker = ImagePicker();
  File? image;
  String msg = '';
  String url = 'https://carwaan.herokuapp.com/auth/';
  // ignore: non_constant_identifier_names
  select_image() async {

    final pickedFile = await picker.getImage(source:ImageSource.gallery);
     setState(() {
        image = File(pickedFile!.path);
      });
    }

  signUp()async {
    setState(() {
      msg = 'Signing up...';
    });

    String email = email_Controller.value.text;
    String name = name_Controller.value.text;
    String phone = phone_Controller.value.text;
    String password = password_Controller.value.text;
    String cnic = cnic_Controller.value.text;
    String location = location_Controller.value.text;

    if (email == '' || password == '' || name == '' || phone == '' || cnic == '' || location == '' || image == null) {
      setState(() {
        msg = '*Enter All Information...';
      });
      return;
    }


       var stream = http.ByteStream(DelegatingStream.typed(image!.openRead()));
        // get file length
        var length = await image!.length();

        // string to uri
        var uri = Uri.parse(url+'registershowroom');

       // create multipart request
       var request = http.MultipartRequest("POST", uri);

       // multipart that takes file
        var multipartFile  =http.MultipartFile('img', stream, length,
            filename :basename(image!.path));

       request.fields['token'] = await storage.read(key:'token').toString();
       request.fields['name'] = name;
       request.fields['email'] = email;
       request.fields['phone'] = phone;
       request.fields['cnic'] = cnic;
       request.fields['password'] = password;
       request.fields['location'] = location;
        // add file to multipart
        request.files.add(multipartFile);

        // send

    http.Response response = await http.Response.fromStream(await request.send());
    Map resMap = json.decode(response.body);


    if (resMap.keys.contains('success')) {
      showDialog(
          context: this.context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              title: const Text("Account verification!"),
              content: const Text(
                "Please wait for the verification, you will receive an email when your account is verified.",
                style: TextStyle(fontSize: 18),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const MyApp()),
                            (route) => false);
                  },
                  child: const Text(
                    "Okay",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            );
          });
    } else if (resMap.keys.contains('error')) {
      String err = resMap["error"];
      setState(() {
        msg = err;
      });
    }
    }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Stack(
          children: [
            Image.asset(
              'lib/assets/carwaan.jpeg',
              fit: BoxFit.cover,
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
            ),
            Container(
              color: Colors.white.withOpacity(0.8),
            ),
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.only(top: 90, left: 16),
                    child: const Text(
                      "Create Account",
                      style:
                      TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 16),
                    child: const Text(
                      "Sign Up to Register your Showroom!",
                      style: TextStyle(fontSize: 25),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.04,
                        right: 30,
                        left: 30),
                    child: Column(
                      children: [
                        Text(msg),
                        TextFormField(
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              hintText: " Showroom Name",
                              hintStyle: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          keyboardType: TextInputType.name,
                          controller: name_Controller,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          showCursor: true,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              hintText: "Email",
                              hintStyle: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          controller: email_Controller,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          showCursor: true,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              hintText: "Phone",
                              hintStyle: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          keyboardType: TextInputType.phone,
                          controller: phone_Controller,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          obscureText: true,
                          showCursor: true,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              hintText: "Password",
                              hintStyle: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          controller: password_Controller,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          showCursor: true,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              hintText: "CNIC Number",
                              hintStyle: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          keyboardType: TextInputType.number,
                          controller: cnic_Controller,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          showCursor: true,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              hintText: "Showroom Location",
                              hintStyle: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          keyboardType: TextInputType.url,
                          controller: location_Controller,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          showCursor: true,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              hintText: image!= null ? image!.uri.toString(): "Showroom Image",
                              hintStyle: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onTap: ()=>{select_image()},
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.only(
                                  top: 12, bottom: 12, left: 20, right: 20)),
                          onPressed: () {
                            signUp();
                          },
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              const Text(
                                "Already have an account?",
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  "Login",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    alignment: Alignment.bottomCenter,
                    margin: const EdgeInsets.only(top: 30),
                    child: const Text(
                      "CARWAAN",
                      style:
                      TextStyle(fontSize: 35, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
