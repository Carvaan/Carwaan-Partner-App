import 'dart:convert';
import 'package:carwaan_partnerapp/editCar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'home_partner.dart';
import 'package:http/http.dart' as http;


class CarEdit extends StatefulWidget {
  const CarEdit({Key? key}) : super(key: key);

  @override
  _CarEditState createState() => _CarEditState();
}

class _CarEditState extends State<CarEdit> {
  var car;
  var test = 'abc';
  final storage = const FlutterSecureStorage();
  String url = 'https://carwaan.herokuapp.com/car/';

  @override
  initState() {
    super.initState();
    getcardetails();
  }

  getcardetails() async{
    var details = await storage.read(key: "selectedCar");
    Map carMap = json.decode(details!);
    setState((){
      car = carMap;
    });
  }

  deleteCar() async {
    var token = await storage.read(key: "token");
    var carId = car["_id"];

    var response = await http.post(Uri.parse(url + 'deletecar'),
        body: {'token': token,'carId':carId});


    Map resMap = json.decode(response.body);

    if(resMap.containsKey("success")){
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const HomePage()),
      );
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
          leading:
          Builder(
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.only(top: 55, left: 16),
                    child: Text(
                      car!= null?car["name"]: 'loading...',
                       style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    alignment: Alignment.topCenter,
                    margin: const EdgeInsets.only(top: 10,),
                    child: Image.network(
                      car!= null?car["img"]: 'https://jmperezperez.com/amp-dist/sample/sample-placeholder.png',
                      fit: BoxFit.cover,
                      height: 420,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 16, top: 15),
                    child:  const Text(
                      "Specifications",
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 6, left: 6, right: 6, bottom: 30),
                    child: Card(
                      shape: const BeveledRectangleBorder(
                          side: BorderSide(color: Colors.black)),
                      child: Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.all(10),
                            child: Text(car!= null?car["specs"]: 'loading...',
                                style: const TextStyle(fontSize: 18)),
                          ),
                          Container(
                            margin: const EdgeInsets.all(10),
                            alignment: Alignment.topRight,
                            child: Text(car!= null ? "PKR " + car["rent"].toString() + "/day": 'loading...',
                                style: const TextStyle(fontSize: 18)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,

                    child: ElevatedButton(

                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.only(
                              top: 12, bottom: 12, left: 20, right: 20)),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const EditCar()),
                        );
                      },
                      child: Container(
                        width: 150,

                        alignment: Alignment.center,
                        child: const Text(
                          "Edit Car",
                          style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold,),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Container(
                    alignment: Alignment.bottomCenter,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.only(
                              top: 12, bottom: 12, left: 20, right: 20)),
                      onPressed: () {
                        deleteCar();
                      },
                      child: Container(
                        width: 150,
                        alignment: Alignment.center,
                        child: const Text(
                          "Remove Car",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 50,
                  )
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back_rounded),
              padding: const EdgeInsets.only(left: 6),
            ),
          ],
        ),
      ),
    );
  }
}
