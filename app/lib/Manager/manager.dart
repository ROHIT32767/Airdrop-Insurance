// ignore_for_file: unused_import

import 'package:app/Authentication/login.dart';
import 'package:app/Manager/kyc_details_view.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app/model/user_model.dart';

class ManagerPage extends StatefulWidget {
  const ManagerPage({Key? key}) : super(key: key);

  @override
  ManagerPageState createState() => ManagerPageState();
}

class ManagerPageState extends State<ManagerPage> {
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();
  final db = FirebaseFirestore.instance;

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xff392850),
      ),
      backgroundColor: const Color(0xff392850),
      body: Column(
        children: <Widget>[
          Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Column(children: <Widget>[
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Verify community members",
                          style: GoogleFonts.openSans(
                              textStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600))),
                    ]),
                StreamBuilder<QuerySnapshot>(
                  stream: db.collection('users').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      return ListView(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        children: snapshot.data!.docs.map((doc) {
                          // If user hasn't uploaded all required data don't show him in list
                          if (!(doc.data().toString().contains('audio') &&
                                  doc.data().toString().contains('image') &&
                                  doc.data().toString().contains('document')) ||
                              doc.get('kycVerified') == true ||
                              doc.get('coinbaseVerified') == true) {
                            return const SizedBox.shrink();
                          }
                          // Show him for verification
                          return KYCViewDetails(doc: doc);
                        }).toList(),
                      );
                    }
                  },
                ),
              ]))
        ],
      ),
    );
  }
}
