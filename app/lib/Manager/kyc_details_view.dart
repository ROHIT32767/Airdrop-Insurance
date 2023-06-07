// ignore_for_file: unused_import

import 'package:app/Authentication/login.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app/model/user_model.dart';
// import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';

class KYCViewDetails extends StatefulWidget {
  final DocumentSnapshot doc;

  const KYCViewDetails({Key? key, required this.doc}) : super(key: key);

  @override
  KYCViewDetailsState createState() => KYCViewDetailsState();
}

void animateViewerDialog(BuildContext context, Widget dchild) {
  showGeneralDialog(
    context: context,
    barrierLabel: "Barrier",
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: const Duration(milliseconds: 350),
    pageBuilder: (_, __, ___) {
      return Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(40)),
          child: dchild,
        ),
      );
    },
    transitionBuilder: (_, anim, __, child) {
      Tween<Offset> tween;
      if (anim.status == AnimationStatus.reverse) {
        tween = Tween(begin: const Offset(-1, 0), end: Offset.zero);
      } else {
        tween = Tween(begin: const Offset(1, 0), end: Offset.zero);
      }

      return SlideTransition(
        position: tween.animate(anim),
        child: FadeTransition(
          opacity: anim,
          child: child,
        ),
      );
    },
  );
}

class KYCViewDetailsState extends State<KYCViewDetails> {
  final AudioPlayer player = AudioPlayer();
  bool isPlayingAudio = false;
  late TextEditingController feedbackController;

  @override
  void initState() {
    super.initState();
    feedbackController = TextEditingController();
  }

  @override
  void dispose() {
    feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        title: Text(widget.doc.get("name")),
        children: <Widget>[
          Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 10, right: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Audio",
                          style: GoogleFonts.openSans(
                              textStyle: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400))),
                      (!isPlayingAudio)
                          ? IconButton(
                              onPressed: (() async {
                                setState(() {
                                  isPlayingAudio = true;
                                });
                                try {
                                  await player.play(widget.doc.get('audio'));
                                  player.onPlayerComplete.listen((event) {
                                    setState(() {
                                      isPlayingAudio = false;
                                    });
                                  });
                                } catch (error) {
                                  setState(() {
                                    isPlayingAudio = false;
                                  });
                                  Fluttertoast.showToast(
                                      msg:
                                          "Check network connection and try again.");
                                }
                              }),
                              icon: const FaIcon(
                                FontAwesomeIcons.circlePlay,
                                color: Colors.blue,
                              ))
                          : IconButton(
                              onPressed: (() {
                                player.stop();
                                setState(() {
                                  isPlayingAudio = false;
                                });
                              }),
                              icon: const FaIcon(
                                FontAwesomeIcons.circleStop,
                                color: Colors.black,
                              ))
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Image",
                          style: GoogleFonts.openSans(
                              textStyle: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400))),
                      IconButton(
                          onPressed: (() {
                            animateViewerDialog(context,
                                Image.network(widget.doc.get("image")));
                          }),
                          icon: const FaIcon(
                            FontAwesomeIcons.eye,
                            color: Colors.blue,
                          ))
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Documents",
                          style: GoogleFonts.openSans(
                              textStyle: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400))),
                      IconButton(
                          onPressed: (() {
                            final Stack wview = Stack(
                              children: [
                                WebViewPlus(
                                  initialUrl: widget.doc.get('document'),
                                  javascriptMode: JavascriptMode.unrestricted,
                                ),
                              ],
                            );
                            animateViewerDialog(context, wview);
                          }),
                          icon: const FaIcon(
                            FontAwesomeIcons.bookOpen,
                            color: Colors.blue,
                          ))
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        child: Row(
                          children: [
                            IconButton(
                                onPressed: (() {}),
                                icon: const FaIcon(
                                  FontAwesomeIcons.personCircleCheck,
                                  color: Colors.green,
                                )),
                            const Text(
                              'Verify',
                              style:
                                  TextStyle(fontSize: 15, color: Colors.green),
                            ),
                          ],
                        ),
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(widget.doc.get('uid'))
                              .update({
                            'kycVerified': true,
                            'feedback': FieldValue.delete()
                          });
                        },
                      ),
                      TextButton(
                        child: Row(
                          children: [
                            IconButton(
                                onPressed: (() {}),
                                icon: const FaIcon(
                                  FontAwesomeIcons.ban,
                                  color: Colors.red,
                                )),
                            const Text(
                              'Refute',
                              style: TextStyle(fontSize: 15, color: Colors.red),
                            ),
                          ],
                        ),
                        onPressed: () async {
                          final feedback = await openFeedbackForm();
                          if (feedback != null) {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(widget.doc.get('uid'))
                                .update({
                              'audio': FieldValue.delete(),
                              'image': FieldValue.delete(),
                              'document': FieldValue.delete(),
                              'feedback': feedback
                            });
                            Fluttertoast.showToast(
                                msg: "User was refuted and provided feedback.");
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ))
        ],
      ),
    );
  }

  Future<String?> openFeedbackForm() => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Provide feedback"),
          content: TextField(
            keyboardType: TextInputType.multiline,
            maxLines: null,
            autofocus: true,
            decoration:
                const InputDecoration(hintText: "Reason for refuting KYC..."),
            controller: feedbackController,
          ),
          actions: [
            TextButton(
                onPressed: submitFeedback,
                child: Row(
                  children: [
                    IconButton(
                        onPressed: submitFeedback,
                        icon: const FaIcon(
                          FontAwesomeIcons.ban,
                          color: Colors.red,
                        )),
                    const Text(
                      'Refute',
                      style: TextStyle(fontSize: 15, color: Colors.red),
                    ),
                  ],
                ))
          ],
        ),
      );

  void submitFeedback() {
    if (feedbackController.text == "") {
      Fluttertoast.showToast(
          msg: "Please provide some feedback before refuting.");
    } else {
      Navigator.of(context).pop(feedbackController.text);
    }
  }
}
