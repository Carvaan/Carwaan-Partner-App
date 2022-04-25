import 'dart:convert';
import 'package:carwaan_partnerapp/car_edit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';


class SearchCar extends StatefulWidget {
  const SearchCar({Key? key}) : super(key: key);

  @override
  State<SearchCar> createState() => _SearchCarState();
}

class _SearchCarState extends State<SearchCar> {

  final search_controller = TextEditingController();

  final storage = const FlutterSecureStorage();
  var cars = [];
  var searchCars = [];

  var name = "Loading...";
  var loading = false;
  String url = 'https://carwaan.herokuapp.com/car/';

  Widget getTiles(index){
    var car = searchCars[index];
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: GestureDetector(
        onTap: () async{
          await storage.write(key: "selectedCar", value: json.encode(car));
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const CarEdit()),
          );
        },
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
                      height: 125,
                      width: 125,
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
                            fontWeight: FontWeight.bold)),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      child:  Text(
                          car["specs"] + "\n" + car["rent"].toString() + "/day",
                          style: const TextStyle(fontSize: 15)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  getShowroomCars() async {


    var showroomEmail = await storage.read(key: "email");

    var response = await http.post(Uri.parse(url + 'getshowroomcars'), body:{"showRoomEmail":showroomEmail});

    Map resMap = json.decode(response.body);

    if(resMap.containsKey("success")){
      setState(() {
        cars = resMap["success"];
      });

    }

  }

  @override
  initState(){
    super.initState();
    getShowroomCars();
  }


  searchCar(text) async {
    searchCars = [];

    if(text==""){
      setState(() {
        searchCars = searchCars;
      });
      return;
    }

    cars.forEach((element) {
      if(element["name"].toString().trim().toLowerCase().contains(text.toString().trim().toLowerCase())){
        searchCars.add(element);
      }
    });

    setState(() {
      searchCars = searchCars;
    });
  }

  @override
  Widget build(BuildContext context) {


    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(

        body:  Container(
          child: Column(
            children: [
              Container(
                  height: 50,
                  margin: EdgeInsets.only(top:50,left: 10,right: 10),
                  child: TextFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      hintText: "Search",
                      hintStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    keyboardType: TextInputType.name,
                    controller: search_controller,
                    onChanged: (Text){
                      searchCar(Text);
                    },
                  )
              ),
              Padding(
                padding: searchCars.length==0 ? const EdgeInsets.only(top: 8) : const EdgeInsets.all(0),
                child: Text(searchCars.length==0 ? "Search Car..." : "",style: TextStyle(fontSize: 15),),
              ),
              Container(
                height: MediaQuery.of(context).size.height -125,
                child: ListView.builder(
                    padding: EdgeInsets.only(top: 10),

                    itemCount: searchCars.length,
                    itemBuilder: (context, index) {
                      return getTiles(index);
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
