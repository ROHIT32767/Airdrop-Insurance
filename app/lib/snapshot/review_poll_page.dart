// ignore_for_file: unused_import

import 'package:app/snapshot/create_poll_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fast_forms/flutter_fast_forms.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ReviewPollPage extends StatefulWidget {
  const ReviewPollPage({Key? key}) : super(key: key);

  @override
  State<ReviewPollPage> createState() => _ReviewPollPageState();
}

class _ReviewPollPageState extends State<ReviewPollPage> {
  DatabaseReference db = FirebaseDatabase.instance.ref('/inreview');
  var dbdata = [];

  @override
  void initState() {
    super.initState();
    db.onValue.listen((DatabaseEvent event) {
      dbdata = [];

      if (event.snapshot.value == null) {
        setState(() {});
        return;
      }

      Map<Object?, Object?> data =
          event.snapshot.value as Map<Object?, Object?>;
      for (Object? req in data.entries) {
        MapEntry<Object?, Object?> m = req as MapEntry<Object?, Object?>;
        dbdata.add(m);
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('dd-MM-yyyy');

    return Scaffold(
      backgroundColor: Colors.lightBlue,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Container(
        margin: const EdgeInsets.all(15),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Approve poll proposals",
                      style: GoogleFonts.openSans(
                          textStyle: const TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w600))),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: ListView(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      children: dbdata.map((doc) {
                        return Card(
                            child: ExpansionTile(
                                title: Text(doc.value["title"]),
                                expandedAlignment: Alignment.centerLeft,
                                children: <Widget>[
                              Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20, bottom: 10, right: 20),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text("Additional information",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        Text(
                                          (doc.value['info'] == '')
                                              ? "None provided."
                                              : doc.value['info'],
                                        ),
                                        const SizedBox(height: 7),
                                        const Text("Voting options",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        Wrap(
                                          spacing: 10,
                                          runSpacing: -7,
                                          children: doc.value['options']
                                              .map<Widget>((option) {
                                            return Chip(
                                              backgroundColor:
                                                  Colors.amberAccent,
                                              label: Text(option),
                                            );
                                          }).toList(),
                                        ),
                                        const SizedBox(height: 7),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              children: [
                                                const Text("Start date",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                Text(formatter.format(
                                                    DateTime.parse(
                                                        doc.value['start'])))
                                              ],
                                            ),
                                            Column(
                                              children: [
                                                const Text("End date",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                Text(formatter.format(
                                                    DateTime.parse(
                                                        doc.value['end'])))
                                              ],
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            TextButton(
                                              child: Row(
                                                children: [
                                                  IconButton(
                                                      onPressed: () async {
                                                        approveDocument(
                                                            doc.key, doc.value);
                                                      },
                                                      icon: const FaIcon(
                                                        FontAwesomeIcons.check,
                                                        color: Colors.green,
                                                      )),
                                                  const Text(
                                                    'Approve',
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        color: Colors.green),
                                                  ),
                                                ],
                                              ),
                                              onPressed: () async {
                                                approveDocument(
                                                    doc.key, doc.value);
                                              },
                                            ),
                                            TextButton(
                                              onPressed: (() async {
                                                bool? t =
                                                    await confirmRemovalDialog();
                                                if (t == true) {
                                                  removeDocumentFromReview(
                                                      doc.key);
                                                }
                                              }),
                                              child: Row(
                                                children: [
                                                  IconButton(
                                                      onPressed: (() async {
                                                        bool? t =
                                                            await confirmRemovalDialog();
                                                        if (t == true) {
                                                          removeDocumentFromReview(
                                                              doc.key);
                                                        }
                                                      }),
                                                      icon: const FaIcon(
                                                        FontAwesomeIcons.xmark,
                                                        color: Colors.red,
                                                      )),
                                                  const Text(
                                                    'Decline',
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        color: Colors.red),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        )
                                      ])),
                            ]));
                      }).toList()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showProgressLoader() {
    AlertDialog alert = AlertDialog(
      content: Row(
        children: [
          const CircularProgressIndicator(),
          Container(
              margin: const EdgeInsets.only(left: 7),
              child: const Text("Processing...")),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void hideProgressLoader() {
    Navigator.pop(context);
  }

  void removeDocumentFromReview(String key) async {
    showProgressLoader();
    try {
      await FirebaseDatabase.instance.ref("inreview/$key").remove();
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    }
    hideProgressLoader();
  }

  void approveDocument(String key, Map<Object?, Object?> doc) async {
    showProgressLoader();
    try {
      await FirebaseDatabase.instance.ref("inreview/$key").remove();
      FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
      await firebaseFirestore
          .collection("polls")
          .add(doc.cast<String, Object>());
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    }
    hideProgressLoader();
  }

  Future<bool?> confirmRemovalDialog() async => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Are you sure you want to deny poll request?"),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: Row(
                  children: [
                    ElevatedButton(
                      child: const Text("Confirm"),
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                    )
                  ],
                ))
          ],
        ),
      );
}
