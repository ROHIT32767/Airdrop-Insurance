import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as cloud_firebase;
import 'package:app/model/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class InsuranceClaimScreen extends StatefulWidget {
  const InsuranceClaimScreen({Key? key}) : super(key: key);

  @override
  State<InsuranceClaimScreen> createState() => _InsuranceClaimScreenState();
}

class _InsuranceClaimScreenState extends State<InsuranceClaimScreen> {
  // form key
  final _formKey = GlobalKey<FormState>();
  final claimController = TextEditingController();
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();
  String? selectedValue;
  FilePickerResult? file;

  List<DropdownMenuItem<String>> menuItems = [];

  Future<bool> _requestPermission() async {
    bool isGranted = false;
    // Request permission to access media files
    if (await Permission.storage.request().isGranted) {
      // Permission granted, load media files
      isGranted = true;
      docUpload();
    } else {
      // Permission denied, show error message
      Fluttertoast.showToast(
          msg: 'Permission to access media files denied',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
    return isGranted;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      cloud_firebase.FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .get()
          .then((value) {
        loggedInUser = UserModel.fromMap(value.data());
        final now = DateTime.now();
        for (var option in loggedInUser.options!) {
          // Add options to the dropdown menu which haven't expired
          if (now.difference(option["timestamp"].toDate()).inDays < 7 &&
              !option["automated"]) {
            menuItems.add(DropdownMenuItem(
              value: option["uuid"],
              child: Text(option["name"]),
            ));
          }
        }

        setState(() {
          selectedValue = menuItems[0].value;
        });
      });
    });
  }

  List<DropdownMenuItem<String>> get dropdownItems {
    return menuItems;
  }

  void docUpload() async {
    //Select Image
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    setState(() {
      file = result;
    });
  }

  void submitClaim() async {
    var uuid = const Uuid();
    if (claimController.text.isNotEmpty) {
      var x = uuid.v1();
      var optionName = "";
      var verifyRequired = 1;
      var adminRequired = true;
      //print(selectedValue);
      await cloud_firebase.FirebaseFirestore.instance
          .collection("insurance options")
          .doc(selectedValue)
          .get()
          .then((value) {
        print(value.data()?["name"]);
        optionName = value.data()?["name"];
        verifyRequired = value.data()?["verifyRequired"];
        adminRequired = value.data()?["adminRequired"];
      });
      String link = "";
      if (file != null && file!.files.single.path != null) {
        File f = File(file!.files.single.path ?? "");
        final docu = FirebaseStorage.instance.ref();
        var uuid = const Uuid();
        final userDocRef = docu.child(uuid.v1());
        try {
          Fluttertoast.showToast(msg: "Uploading document to database.");
          await userDocRef.putFile(f);
        } catch (e) {
          Fluttertoast.showToast(
              msg: "Some error occured. Check internet access.");
        }
        link = await userDocRef.getDownloadURL();
        //print(link);
      }
      cloud_firebase.FirebaseFirestore.instance
          .collection("claims")
          .doc(x)
          .set({
            "adminRequired": adminRequired,
            "claim_status": 0,
            "uuid": x,
            "user_name": loggedInUser.name,
            "uid": loggedInUser.uid,
            "optionName": optionName,
            "option": selectedValue,
            "document": link,
            "description": claimController.text,
            "verifyRequired": verifyRequired,
            "verify_received": 0,
            "verifiers": [],
            "deniers": [],
            "timestamp": DateTime.now(),
          })
          .onError((error, stackTrace) => error)
          .then((value) {
            Fluttertoast.showToast(msg: "Claim submitted");
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    //claim description field
    final claimInfo = TextFormField(
        style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
        keyboardType: TextInputType.multiline,
        controller: claimController,
        minLines: 15,
        maxLines: null,
        autofocus: false,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          fillColor: Colors.grey.shade100,
          filled: true,
          contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Reason for insurance claim",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ));
    var color = 0xFF3D82AE;
    return Container(
      decoration: BoxDecoration(
        color: Color(color),
      ),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Color(color),
        ),
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Container(),
            Container(
              padding: const EdgeInsets.only(left: 35, top: 50),
              child: const Text(
                'Make an\nInsurance Claim',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 33,
                    fontWeight: FontWeight.w700),
              ),
            ),
            SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.19),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(left: 35, right: 35),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(children: [
                              Text(
                                "Insurance Plan",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 23,
                                ),
                              )
                            ]),
                            Row(children: [
                              Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12.0),
                                  height: 40.0,
                                  width: 250.0,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    color: Colors.white,
                                  ),
                                  child: DropdownButtonHideUnderline(
                                      child: DropdownButton(
                                    dropdownColor: Colors.white,
                                    items: dropdownItems,
                                    value: selectedValue,
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        selectedValue = newValue;
                                      });
                                    },
                                  )))
                            ]),
                            const SizedBox(
                              height: 30,
                            ),
                            Row(children: [
                              Text(
                                'Document Upload',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 23,
                                ),
                              )
                            ]),
                            Row(children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.all(12.0),
                                  backgroundColor: Colors.black,
                                  textStyle: const TextStyle(fontSize: 16),
                                ),
                                onPressed: () {
                                  docUpload();
                                },
                                child: file == null
                                    ? const Text('Open File Picker')
                                    : const Text("File Selected"),
                              ),
                            ]),
                            const SizedBox(
                              height: 30,
                            ),
                            Row(children: [
                              Text(
                                "Description",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 23,
                                ),
                              )
                            ]),
                            claimInfo,
                            const SizedBox(
                              height: 40,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.all(12.0),
                                    backgroundColor: Colors.black,
                                    textStyle: const TextStyle(fontSize: 16),
                                  ),
                                  onPressed: () {
                                    submitClaim();
                                  },
                                  child: const Text('Submit Claim'),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 40,
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
