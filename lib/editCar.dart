import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'home_partner.dart';
import 'main.dart';
import 'package:path/path.dart';
import 'package:async/async.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EditCar extends StatefulWidget {
  const EditCar({Key? key}) : super(key: key);

  @override
  State<EditCar> createState() => _EditCarState();
}

class _EditCarState extends State<EditCar> {
  final name_Controller = TextEditingController();
  final carcc_Controller = TextEditingController();
  final model_Controller = TextEditingController();
  final condition_Controller = TextEditingController();
  final rent_Controller = TextEditingController();
  final storage = const FlutterSecureStorage();
  String msg = '';
  String url = 'https://carwaan.herokuapp.com/car/';
  var picker = ImagePicker();
  File? image;
  var car;


  @override
  initState(){
    super.initState();
    getcardetails();
  }

  getcardetails() async{
    var details = await storage.read(key: "selectedCar");
    Map carMap = json.decode(details!);
    setState((){
      car = carMap;
    });
    name_Controller.text = carMap["name"];
    model_Controller.text = carMap["specs"].toString().split("\n")[0].replaceAll("Model: ","");
    carcc_Controller.text = carMap["specs"].toString().split("\n")[1].replaceAll("CC: ","");
    condition_Controller.text = carMap["specs"].toString().split("\n")[2].replaceAll("Condition: ","");
    rent_Controller.text = carMap["rent"].toString();




  }


  select_image() async {

    final pickedFile = await picker.getImage(source:ImageSource.gallery);
    setState(() {
      image = File(pickedFile!.path);
    });
  }

  addCar() async {
    String? token = await storage.read(key:'token');
    setState(() {
      msg = 'Editing Car...';
    });

    String name = name_Controller.value.text;
    String model = model_Controller.value.text;
    String carcc = carcc_Controller.value.text;
    String condition = condition_Controller.value.text;
    String rent = rent_Controller.value.text;

    if (name == '' || model == '' || carcc == '' || condition == '' || rent == '' || image==null) {
      setState(() {
        msg = '*Enter All Information...';
      });
      return;
    }
    var stream = http.ByteStream(DelegatingStream.typed(image!.openRead()));
    // get file length
    var length = await image!.length();

    // string to uri
    var uri = Uri.parse(url+'editcar');

    // create multipart request
    var request = http.MultipartRequest("POST", uri);

    // multipart that takes file
    var multipartFile = http.MultipartFile('img', stream, length,
        filename :basename(image!.path));

    request.fields['token'] = token!;
    request.fields['name'] = name;
    request.fields['specs'] = "Model: " + model +"\nCC: "+ carcc +"\nCondition: "+ condition;
    request.fields['rent'] = rent;
    request.fields['carId'] = car["_id"];

    print("aaa"+car["_id"]);

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
              title: const Text("Car Edited!"),
              content: const Text(
                "The car has been edited.",
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
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
                icon: const Icon(
                  Icons.menu,
                  color: Colors.black,
                ),
              );
            },
          ),
          title: const Text(
            "CARWAAN",
            style: TextStyle(
                fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
        drawer: const DrawerWidget(),
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
                children: [
                  Container(
                    alignment: Alignment.topLeft,
                    padding:  const EdgeInsets.only(top: 75, left: 16),
                    child: const Text(
                      "Edit Car Details",
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.03,
                        right: 30,
                        left: 30),
                    child: Column(
                      children: [
                        Text(msg),
                        TextFormField(
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              hintStyle: const TextStyle(fontWeight: FontWeight.bold),
                              hintText: "Model Name"),
                          keyboardType: TextInputType.name,
                          controller: name_Controller,
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              hintStyle: const TextStyle(fontWeight: FontWeight.bold),
                              hintText: "Car CC"),
                          keyboardType: TextInputType.text,
                          controller: carcc_Controller,
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              hintStyle: const TextStyle(fontWeight: FontWeight.bold),
                              hintText: "Car Model"),
                          keyboardType: TextInputType.text,
                          controller: model_Controller,
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              hintStyle: const TextStyle(fontWeight: FontWeight.bold),
                              hintText: "Condition"),
                          keyboardType: TextInputType.text,
                          controller: condition_Controller,
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              hintStyle: const TextStyle(fontWeight: FontWeight.bold),
                              hintText: "Rent/Day"),
                          keyboardType: TextInputType.number,
                          controller: rent_Controller,
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              hintStyle: const TextStyle(fontWeight: FontWeight.bold),
                              hintText: image!= null ? image!.uri.toString(): "Car Image"),
                          onTap: ()=>{select_image()},

                        ),
                        const SizedBox(
                          height: 25,
                        ),

                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.only(
                                  top: 12, bottom: 12, left: 20, right: 20)),
                          onPressed: () {
                            addCar();
                          },
                          child: const Text(
                            "Edit Car",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back_rounded),
              padding: const EdgeInsets.only(left: 6),
            )
          ],
        ),
      ),
    );
  }
}
