// ignore_for_file: prefer_interpolation_to_compose_strings, unused_import

import 'package:app/snapshot/create_poll_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fast_forms/flutter_fast_forms.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:polls/polls.dart';

class HistoryPollsPage extends StatefulWidget {
  const HistoryPollsPage({Key? key}) : super(key: key);

  @override
  State<HistoryPollsPage> createState() => _HistoryPollsPageState();
}

class _HistoryPollsPageState extends State<HistoryPollsPage> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  var dbdata = [];

  void fillDBData() async {
    try {
      QuerySnapshot querySnapshot = await db.collection("polls").where("ManagerPoll", isEqualTo: false).get();
      dbdata = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    }
    dbdata = dbdata.where((data) {
      DateTime en = DateTime.parse(data['end']);
      DateTime today = DateTime.now();
      bool isManagerPoll = data['ManagerPoll'];
      return (today.isAfter(en) && !isManagerPoll);
    }).toList();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    fillDBData();

    db.collection("polls").snapshots().listen((event) {
      dbdata = [];
      for (var doc in event.docs) {
        dbdata.add(doc.data());
      }
      dbdata = dbdata.where((data) {
        DateTime en = DateTime.parse(data['end']);
        DateTime today = DateTime.now();
        bool isManagerPoll = data['ManagerPoll'];
        return (today.isAfter(en) && !isManagerPoll);
      }).toList();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    return Scaffold(
      backgroundColor: Colors.yellow,
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
                  Text("Finished polls",
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
                      children: dbdata.map<Widget>((doc) {
                        Map<int, double> voteData = getVoteData(doc);
                        return ExpansionTile(
                          title: Text(doc['title']),
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 20, right: 20, bottom: 10),
                              child: Polls(
                                  onVote: (choice) async {},
                                  viewType: PollsType.readOnly,
                                  voteData: doc['votes'] ?? {},
                                  userChoice: (doc['votes'] == null)
                                      ? null
                                      : doc['votes'][user?.uid],
                                  currentUser: user?.uid,
                                  creatorID: doc['creator_id'],
                                  question: Text("Additional information: " +
                                      ((doc['info'] == '')
                                          ? "None provided."
                                          : doc['info'])),
                                  children: [
                                    for (int i = 0;
                                        i < doc['options'].length;
                                        i++)
                                      Polls.options(
                                        title: doc['options'][i],
                                        value: (voteData[i] ?? 0),
                                      )
                                  ]),
                            )
                          ],
                        );
                      }).toList()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<int, double> getVoteData(doc) {
    Map<int, double> count = {};
    for (int i = 0; i < doc['options'].length; i++) {
      count[i] = 0;
    }

    if (doc['votes'] == null) return count;

    for (Object? vote in doc['votes'].values) {
      count[vote as int] = (count[vote] ?? 0) + 1;
    }

    return count;
  }
}
