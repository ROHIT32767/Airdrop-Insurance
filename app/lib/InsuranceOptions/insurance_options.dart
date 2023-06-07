import 'package:flutter/material.dart';
// ignore: unused_import
import 'constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as cloud_firebase;
import 'package:app/model/option_model.dart';
import 'body.dart';

class InsuranceOptionsScreen extends StatefulWidget {
  const InsuranceOptionsScreen({Key? key}) : super(key: key);

  @override
  State<InsuranceOptionsScreen> createState() => _InsuranceOptionsScreenState();
}

class _InsuranceOptionsScreenState extends State<InsuranceOptionsScreen> {
  ScrollController controller = ScrollController();
  bool closeTopContainer = false;
  double topContainer = 0;

  List<Widget> itemsData = [];
  List<OptionModel> options = [];

  void getPostsData() {
    // List<dynamic> responseList = insuranceOptions;

    List<Widget> listItems = [];
    for (var post in options) {
      listItems.add(InkWell(
          onTap: () => {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => InsuranceDetails(
                              option: post,
                            )))
              },
          child: Container(
              height: 150,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withAlpha(100), blurRadius: 10.0),
                  ]),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          post.name!,
                          style: const TextStyle(
                              fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          post.provider!,
                          style:
                              const TextStyle(fontSize: 17, color: Colors.grey),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "${post.cost!} tokens/week",
                          style: const TextStyle(
                              fontSize: 25,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ],
                ),
              ))));
    }
    setState(() {
      itemsData = listItems;
    });
  }

  @override
  void initState() {
    super.initState();
    cloud_firebase.FirebaseFirestore.instance
        .collection("insurance options")
        .orderBy("created_time", descending: true)
        .get()
        .then((options) {
      for (var option in options.docs) {
        setState(() {
          this.options.add(OptionModel.fromMap(option.data()));
        });
      }
      getPostsData();
    });
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
        backgroundColor: const Color(0xFF3D82AE),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xFF3D82AE),
        ),
        body: SizedBox(
          height: size.height,
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Text(
                    "Insurance Options",
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
