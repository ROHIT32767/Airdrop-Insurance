import 'package:adminpage/ClaimApproval/claim_details_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:adminpage/model/user_model.dart';

class ClaimApprovePage extends StatefulWidget {
  const ClaimApprovePage({Key? key}) : super(key: key);

  @override
  ClaimApprovePageState createState() => ClaimApprovePageState();
}

class ClaimApprovePageState extends State<ClaimApprovePage> {
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();
  final db = FirebaseFirestore.instance;
  String? masterKey = '';
 
  void setRemoteConfig() async {
    FirebaseFirestore.instance
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
    FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get()
        .then((value) {
      loggedInUser = UserModel.fromMap(value.data());
      setState(() {});
    });
    setRemoteConfig();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xff924444),
      ),
      backgroundColor: const Color(0xff924444),
      body: Column(
        children: <Widget>[
          Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Column(children: <Widget>[
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Approve Claims",
                          style: GoogleFonts.openSans(
                              textStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600))),
                    ]),
                const SizedBox(
                  height: 30,
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: db.collection('claims').snapshots(),
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
                          // Show claim if it's pending and requires admin approval
                          if (doc.get("claim_status") == 0 &&
                              doc.get("verify_received") >=
                                  doc.get("verify_required") &&
                              doc.get("admin_required")) {
                            return ClaimViewDetails(
                                doc: doc, masterKey: masterKey!);
                          }
                          return const SizedBox.shrink();
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
