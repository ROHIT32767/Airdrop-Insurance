import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as cloud_firebase;
import 'package:adminpage/model/option_model.dart';
import 'body.dart';

class AirDropScreen extends StatefulWidget {
  const AirDropScreen({Key? key}) : super(key: key);

  @override
  State<AirDropScreen> createState() => _AirDropScreenState();
}

class _AirDropScreenState extends State<AirDropScreen> {
  ScrollController controller = ScrollController();
  bool closeTopContainer = false;
  double topContainer = 0;
  String? masterKey = '';

  List<Widget> itemsData = [];
  List<OptionModel> options = [];

  void getPostsData() {
    List<Widget> listItems = [];
    for (var post in options) {
      listItems.add(InkWell(
          onTap: () => {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => InsuranceDetails(
                              option: post,
                              masterKey: masterKey!,
                            )))
              },
          child: Container(
              height: 75,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withAlpha(100), blurRadius: 10.0),
                  ]),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                post.name!,
                                style: const TextStyle(
                                    fontSize: 28, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ]))));
    }
    setState(() {
      itemsData = listItems;
    });
  }

  void setRemoteConfig() async {
    cloud_firebase.FirebaseFirestore.instance
        .collection("constants")
        .doc("masterKey")
        .get()
        .then((value) {
      setState(() {
        masterKey = value.data()?["key"];
      });
    });
  }

  @override
  void initState() {
    super.initState();
    cloud_firebase.FirebaseFirestore.instance
        .collection("insurance options")
        .where("automated", isEqualTo: true)
        .get()
        .then((options) {
      for (var option in options.docs) {
        setState(() {
          this.options.add(OptionModel.fromMap(option.data()));
        });
      }
      getPostsData();
    });
    setRemoteConfig();
    controller.addListener(() {
      double value = controller.offset / 119;

      setState(() {
        topContainer = value;
        closeTopContainer = controller.offset > 50;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xff924444),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xff924444),
        ),
        body: SizedBox(
          height: size.height,
          child: Column(
            children: <Widget>[
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Text(
                    "Automated Insurance Options",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                  child: ListView.builder(
                      controller: controller,
                      itemCount: itemsData.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        double scale = 1.0;
                        if (topContainer > 0.5) {
                          scale = index + 0.5 - topContainer;
                          if (scale < 0) {
                            scale = 0;
                          } else if (scale > 1) {
                            scale = 1;
                          }
                        }
                        return Opacity(
                          opacity: scale,
                          child: Transform(
                            transform: Matrix4.identity()..scale(scale, scale),
                            alignment: Alignment.bottomCenter,
                            child: Align(
                                heightFactor: 0.7,
                                alignment: Alignment.topCenter,
                                child: itemsData[index]),
                          ),
                        );
                      })),
            ],
          ),
        ),
      ),
    );
  }
}
