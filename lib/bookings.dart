import 'package:flutter/material.dart';
import 'home_partner.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Bookings extends StatefulWidget {
  const Bookings({Key? key}) : super(key: key);

  @override
  _BookingsState createState() => _BookingsState();
}

class _BookingsState extends State<Bookings> {
  String url = 'https://carwaan.herokuapp.com/car/';
  final storage = const FlutterSecureStorage();
  var bookings = [];
  var msg = "test";

  getBookings() async {

    var token = await storage.read(key: "token");
    var response = await http.post(Uri.parse(url + 'getmybookingshowroom'), body:{"token": token});

    Map resMap = json.decode(response.body);

    if (resMap.keys.contains('success')) {

      setState(() {
        msg = resMap["success"].toString();
      });

      setState(() {
        bookings = resMap["success"];
      });

    } else if (resMap.keys.contains('error')) {
      String err = resMap["error"];

    }
  }

  getTile(booking) {
    var car = booking["carDetails"];
    var currentUnix =DateTime.now().toUtc().millisecondsSinceEpoch;

    if(car!= null && booking?["_doc"]?["status"]==true && booking?["_doc"]["ends"]>=currentUnix){
      return Padding(
        padding: const EdgeInsets.all(6.0),
        child: Card(
          shape:  RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: const BorderSide(color: Colors.black)
          ),
          child: Row(
            children: [
              Container(
                child: ClipRRect(
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(15),
                    right: Radius.circular(0),
                  ),
                  child: Image(
                      height: 135,
                      width: 135,
                      fit: BoxFit.cover,
                      image: NetworkImage(car["img"])
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(car["name"],
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold)
                    ),
                    Container(
                      child:  Text(
                          car["specs"] +"\nRent: "+ car["rent"].toString() + "/day\nTotal Rent: "+booking?["_doc"]["totalRent"].toString()+" PKR\nNo of Days: "+booking?["_doc"]["dates"].length.toString()+"\nStarts: "+booking?["_doc"]["dates"][0],
                          style: const TextStyle(fontSize: 15)
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
    else {
      return Container(
        // child: Text("---"),
      );
    }
  }

  @override
  initState(){
    super.initState();
    getBookings();
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
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back_rounded),
              padding: const EdgeInsets.only(left: 6),
            ),
            Container(
              padding: const EdgeInsets.only(top: 50),
              alignment: Alignment.topCenter,
              child: const Text(
                "Bookings",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.only(top: 115, left: 16),
              child: const Text(
                "In-Progress",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(top: 160),
              child: ListView.builder(
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {

                    return getTile(bookings[index]);

                  }),
            ),
          ],
        ),
      ),
    );
  }
}
