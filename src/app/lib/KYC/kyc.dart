// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:app/Authentication/login.dart';
import 'package:app/KYC/coinbase_verify.dart';
import 'package:app/KYC/record_audio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app/model/user_model.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class KYCPage extends StatefulWidget {
  const KYCPage({Key? key}) : super(key: key);

  @override
  KYCPageState createState() => KYCPageState();
}

class KYCPageState extends State<KYCPage> {
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();
  dynamic userMap;

  Future<bool> _requestPermission() async {
    bool isGranted = false;
    // Request permission to access media files
    if (await Permission.storage.request().isGranted) {
      // Permission granted, load media files
      isGranted = true;
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
    FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get()
        .then((value) {
      loggedInUser = UserModel.fromMap(value.data());
      userMap = value.data();
      setState(() {});
    });
  }

  void uploadImage() async {
    final imagePicker = ImagePicker();
    PickedFile? image;
    //Check Permissions
    await Permission.photos.request();

    var permissionStatus = await _requestPermission();
    if (permissionStatus) {
      //Select Image
      image = (await imagePicker.pickImage(source: ImageSource.gallery)) as PickedFile?;

      if (image != null) {
        var file = File(image.path);
        //Upload to Firebase
        final snapshot = FirebaseStorage.instance.ref();
        final userImageRef = snapshot.child("${loggedInUser.uid}_image");
        try {
          Fluttertoast.showToast(msg: "Uploading image to database.");
          await userImageRef.putFile(file);
        } catch (e) {
          Fluttertoast.showToast(
              msg: "Some error occured. Check internet access.");
        }
        String link = await userImageRef.getDownloadURL();
        FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .update({'image': link});
      } else {
        Fluttertoast.showToast(msg: 'No Image Path Received');
      }
    } else {
      Fluttertoast.showToast(
          msg: 'Permission not granted. Try Again with permission access');
    }
  }

  void uploadDocument() async {
    //Check Permissions


    var permissionStatus = await _requestPermission();
    if (permissionStatus) {
      //Select Image
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      // var result;

      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path ?? "");
        //Upload to Firebase
        final docu = FirebaseStorage.instance.ref();
        final userDocRef = docu.child("${loggedInUser.uid}_document");
        try {
          Fluttertoast.showToast(msg: "Uploading document to database.");
          await userDocRef.putFile(file);
        } catch (e) {
          Fluttertoast.showToast(
              msg: "Some error occured. Check internet access.");
        }
        String link = await userDocRef.getDownloadURL();
        FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .update({'document': link});
      } else {
        Fluttertoast.showToast(msg: 'No file Path Received');
      }
    } else {
      Fluttertoast.showToast(
          msg: 'Permission not granted. Try Again with permission access');
    }
  }

  @override
  // ignore: prefer_const_constructors
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xff392850),
        ),
        backgroundColor: const Color(0xff392850),
        // ignore: prefer_const_literals_to_create_immutables
        body: SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: Column(children: <Widget>[
            const SizedBox(height: 78),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text("KYC Verification",
                  style: GoogleFonts.openSans(
                      textStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w600))),
              IconButton(
                  padding: const EdgeInsets.only(right: 10.0),
                  icon: const FaIcon(
                    FontAwesomeIcons.circleInfo,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    showAboutDialog(
                        context: context,
                        applicationVersion: '3.0.2',
                        applicationName: 'AirDropped Insurance',
                        applicationLegalese:
                            'To become a trusted user and gain access to the rest of the app you must first verify your email address. Next, at least one among the two remaining KYC options must be checked. Either login via your coinbase account or upload your official documents and an audio recording and wait for it to be verified by the team working at AirDrop Insurance. This might take upto 24 hours.');
                  })
            ]),
            const SizedBox(height: 24),
            Text("#1",
                style: GoogleFonts.openSans(
                    textStyle: const TextStyle(
                        color: Color.fromARGB(255, 206, 248, 239),
                        fontSize: 16,
                        fontWeight: FontWeight.w600))),
            const SizedBox(height: 12),
            Card(
              shape: Border(
                  left: BorderSide(
                      color: (user!.emailVerified) ? Colors.green : Colors.red,
                      width: 5)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    leading: const Icon(Icons.mark_email_read_outlined),
                    title: const Text('Email verification'),
                    subtitle: Text(
                        (!user!.emailVerified) ? 'Not verified' : 'Verified'),
                  ),
                  (!user!.emailVerified)
                      ? Container(
                          alignment: Alignment.center,
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const SizedBox(width: 60),
                              TextButton(
                                child: const Text('Re-send confirmation email'),
                                onPressed: () async {
                                  if (!user!.emailVerified) {
                                    await user!.sendEmailVerification();
                                    Fluttertoast.showToast(
                                        msg:
                                            'Verification email has been sent to inbox');
                                  }
                                },
                              ),
                              IconButton(
                                  padding: const EdgeInsets.only(right: 10.0),
                                  icon: const FaIcon(
                                    FontAwesomeIcons.arrowRightToBracket,
                                  ),
                                  onPressed: () {
                                    logout(context);
                                  })
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text("#2",
                style: GoogleFonts.openSans(
                    textStyle: const TextStyle(
                        color: Color.fromARGB(255, 206, 248, 239),
                        fontSize: 16,
                        fontWeight: FontWeight.w600))),
            const SizedBox(height: 12),
            Card(
              shape: Border(
                  left: BorderSide(
                      color: (userMap != null && userMap['coinbaseVerified'])
                          ? Colors.green
                          : Colors.red,
                      width: 5)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    leading: const FaIcon(
                      FontAwesomeIcons.coins,
                    ),
                    title: const Text('Coinbase verification'),
                    subtitle: Text(
                        (!(userMap != null && userMap['coinbaseVerified']))
                            ? 'Not verified'
                            : 'Verified'),
                  ),
                  (!(userMap != null && userMap['coinbaseVerified']))
                      ? Container(
                          alignment: Alignment.center,
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const SizedBox(width: 60),
                              TextButton(
                                child: const Text('Login to Coinbase'),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const CoinbaseVerifyPage()),
                                  );
                                },
                              ),
                              IconButton(
                                  padding: const EdgeInsets.only(right: 10.0),
                                  icon: const FaIcon(
                                    FontAwesomeIcons.arrowsRotate,
                                  ),
                                  onPressed: () {
                                    setState(() {});
                                  }),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text("#3",
                style: GoogleFonts.openSans(
                    textStyle: const TextStyle(
                        color: Color.fromARGB(255, 206, 248, 239),
                        fontSize: 16,
                        fontWeight: FontWeight.w600))),
            const SizedBox(height: 12),
            Card(
              shape: Border(
                  left: BorderSide(
                      color: (userMap != null && userMap['kycVerified'])
                          ? Colors.green
                          : Colors.red,
                      width: 5)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    leading: const FaIcon(
                      FontAwesomeIcons.signature,
                    ),
                    title: const Text('Standard KYC'),
                    subtitle: Text(
                        (!(userMap != null && userMap['kycVerified']))
                            ? 'Not verified'
                            : 'Verified'),
                  ),
                  (userMap != null && userMap['feedback'] != null)
                      ? Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: Text(
                            // ignore: prefer_interpolation_to_compose_strings
                            "Your KYC was refuted by a community manager. All previously uploaded data was removed. Read the feedback given and apply again with appropriate details. \n\nFeedback: " +
                                userMap['feedback'],
                            style: const TextStyle(
                                color: Colors.red,
                                fontSize: 15,
                                fontWeight: FontWeight.w300),
                          ),
                        )
                      : const SizedBox.shrink(),
                  (!(userMap != null && userMap['kycVerified']))
                      ? Container(
                          alignment: Alignment.center,
                          width: double.infinity,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                child: const Text('Audio Verification'),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const RecorderPage()),
                                  );
                                },
                              ),
                              TextButton(
                                child: const Text('Image Upload'),
                                onPressed: () {
                                  uploadImage();
                                },
                              ),
                              TextButton(
                                child: const Text('Document Upload'),
                                onPressed: () {
                                  uploadDocument();
                                },
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ],
              ),
            ),
          ]),
        )));
  }

  // the logout function
  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    if(!context.mounted ) return ;
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()));
  }
}
