// ignore_for_file: unused_import

import 'package:app/model/user_model.dart';
import 'package:app/ManagerPoll/create_poll_page.dart';
import 'package:app/ManagerPoll/history_polls.dart';
import 'package:app/ManagerPoll/my_polls_page.dart';
import 'package:app/ManagerPoll/review_poll_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:polls/polls.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ManagerPollPage extends StatefulWidget {
  const ManagerPollPage({Key? key}) : super(key: key);

  @override
  State<ManagerPollPage> createState() => _ManagerPollPageState();
}

class _ManagerPollPageState extends State<ManagerPollPage> {
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();
  FirebaseFirestore db = FirebaseFirestore.instance;
  var dbdata = [];
  void fillDBData() async {
    try {
      QuerySnapshot querySnapshot = await db.collection("polls").where("ManagerPoll", isEqualTo: true).get();
      dbdata = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    }
    dbdata = dbdata.where((data) {
      DateTime st = DateTime.parse(data['start']);
      DateTime en = DateTime.parse(data['end']);
      DateTime today = DateTime.now();
      bool isManagerPoll = data['ManagerPoll'];
      return (st.isBefore(today) && en.isAfter(today) && isManagerPoll);
    }).toList();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get()
        .then((value) {
      loggedInUser = UserModel.fromMap(value.data());
      setState(() {});
    });

    fillDBData();

    db.collection("polls").snapshots().listen((event) {
      dbdata = [];
      for (var doc in event.docs) {
        dbdata.add(doc.data());
      }
      dbdata = dbdata.where((data) {
        DateTime st = DateTime.parse(data['start']);
        DateTime en = DateTime.parse(data['end']);
        DateTime today = DateTime.now();
        bool isManagerPoll = data['ManagerPoll'];
        return (st.isBefore(today) && en.isAfter(today) && isManagerPoll);
      }).toList();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CreatePollPage()),
                  );
                },
                child: const Icon(
                  Icons.add,
                  size: 26.0,
                ),
              )),
          (loggedInUser.role != null &&
                  (loggedInUser.role == 'manager' ||
                      loggedInUser.role == 'admin'))
              ? Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ReviewPollPage()),
                      );
                    },
                    child: const Icon(
                      Icons.reviews_outlined,
                      size: 26.0,
                    ),
                  ))
              : const SizedBox.shrink(),
          Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const HistoryPollsPage()),
                  );
                },
                child: const Icon(
                  Icons.history,
                  size: 26.0,
                ),
              )),
          Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MyPollsPage()),
                  );
                },
                child: const Icon(
                  Icons.person,
                  size: 26.0,
                ),
              )),
        ],
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
                  Text("Active polls",
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
                                  onVote: (choice) async {
                                    showProgressLoader();
                                    try {
                                      CollectionReference polls =
                                          db.collection("polls");
                                      final docref = polls.doc(doc['id']);
                                      if(aboveLimit(doc))
                                      {
                                        print("entered aboveLimit");
                                        print("creator_id");
                                        print(doc['creator_id']);
                                        final data = {"userid": doc['creator_id']};
                                        // Write code to create Join Requests
                                            try {
                                                  await db.collection("Requests").add(data);
                                                  Fluttertoast.showToast(msg: "Your Manager poll proposal was successfully sent!");
                                                  print("Manager Requests success");
                                                } catch (e) {
                                                  Fluttertoast.showToast(msg: e.toString());
                                                }
                                      }
                                      await docref.update(
                                          {"votes.${user!.uid}": choice - 1});
                                      Fluttertoast.showToast(
                                          msg: "Vote recorded successfully!");
                                    } catch (e) {
                                      Fluttertoast.showToast(
                                          msg: "Error: $e");
                                    }
                                    hideProgressLoader();
                                  },
                                  viewType: null,
                                  voteData: doc['votes'] ?? {},
                                  userChoice: (doc['votes'] == null)
                                      ? null
                                      : doc['votes'][user?.uid],
                                  currentUser: user?.uid,
                                  creatorID: doc['creator_id'],
                                  // ignore: prefer_interpolation_to_compose_strings
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

  bool aboveLimit(doc) {
    print("entered aboveLimit");
    Map<int, double> count = {};
    for (int i = 0; i < doc['options'].length; i++) {
      count[i] = 0;
    }
    if (doc['votes'] == null) return false;
    for (Object? vote in doc['votes'].values) {
      count[vote as int] = (count[vote] ?? 0) + 1;
    }
    
    if(count[0]==0)
    {
      print("count[0] is 0");
      return true;
    }
    return false;
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
