import 'dart:io';

import 'package:app/Authentication/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app/model/user_model.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
// ignore: depend_on_referenced_packages
import 'package:flutter_sound_platform_interface/flutter_sound_recorder_platform_interface.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

typedef VFunc = void Function();
const theSource = AudioSource.microphone;
late String audioFilePath;

class RecorderPage extends StatefulWidget {
  const RecorderPage({Key? key}) : super(key: key);

  @override
  RecorderPageState createState() => RecorderPageState();
}

class RecorderPageState extends State<RecorderPage> {
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();
  dynamic userMap;

  Codec _codec = Codec.aacMP4;
  late String _mPath;
  FlutterSoundPlayer? _mPlayer = FlutterSoundPlayer();
  FlutterSoundRecorder? _mRecorder = FlutterSoundRecorder();
  bool _mPlayerIsInited = false;
  bool _mRecorderIsInited = false;
  bool _mplaybackReady = false;

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

      _mPlayer!.openPlayer().then((value) {
        setState(() {
          _mPlayerIsInited = true;
        });
      });

      openTheRecorder().then((value) {
        setState(() {
          _mRecorderIsInited = true;
        });
      });

      setState(() {});
    });
  }

  void uploadFileToFirestore() async {
    final storageRef = FirebaseStorage.instance.ref();
    var ext = ".mp4";
    if (!await _mRecorder!.isEncoderSupported(_codec) && kIsWeb) {
      ext = ".webm";
    }
    final userAudioRef = storageRef.child("${loggedInUser.uid}_audio.$ext");
    File file = File(_mPath);
    try {
      Fluttertoast.showToast(msg: "Uploading audio to database.");
      await userAudioRef.putFile(file);
      String link = await userAudioRef.getDownloadURL();
      FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({'audio': link});
    } catch (e) {
      Fluttertoast.showToast(msg: "Some error occured. Check internet access.");
    }
  }

  @override
  void dispose() {
    audioFilePath = _mPath;
    _mPlayer!.closePlayer();
    _mPlayer = null;

    _mRecorder!.closeRecorder();
    _mRecorder = null;
    super.dispose();
  }

  Future<void> openTheRecorder() async {
    final directory = await getApplicationDocumentsDirectory();
    String str = directory.path;
    _mPath = '$str/file.mp4';
    if (!kIsWeb) {
      var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        throw RecordingPermissionException('Microphone permission not granted');
      }
    }
    await _mRecorder!.openRecorder();
    if (!await _mRecorder!.isEncoderSupported(_codec) && kIsWeb) {
      _codec = Codec.opusWebM;
      _mPath = '$str/file.webm';
      if (!await _mRecorder!.isEncoderSupported(_codec) && kIsWeb) {
        _mRecorderIsInited = true;
        return;
      }
    }
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
      avAudioSessionCategoryOptions:
          AVAudioSessionCategoryOptions.allowBluetooth |
              AVAudioSessionCategoryOptions.defaultToSpeaker,
      avAudioSessionMode: AVAudioSessionMode.spokenAudio,
      avAudioSessionRouteSharingPolicy:
          AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: const AndroidAudioAttributes(
        contentType: AndroidAudioContentType.speech,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.voiceCommunication,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));

    _mRecorderIsInited = true;
  }

  void record() {
    _mRecorder!
        .startRecorder(
      toFile: _mPath,
      codec: _codec,
      audioSource: theSource,
    )
        .then((value) {
      setState(() {});
    });
  }

  void stopRecorder() async {
    await _mRecorder!.stopRecorder().then((value) {
      setState(() {
        _mplaybackReady = true;
      });
      Fluttertoast.showToast(msg: 'Playing back audio.');
      play();
    });
  }

  void play() {
    assert(_mPlayerIsInited &&
        _mplaybackReady &&
        _mRecorder!.isStopped &&
        _mPlayer!.isStopped);
    _mPlayer!
        .startPlayer(
            fromURI: _mPath,
            //codec: kIsWeb ? Codec.opusWebM : Codec.aacADTS,
            whenFinished: () {
              setState(() {});
            })
        .then((value) {
      uploadFileToFirestore();
      setState(() {});
    });
  }

  void stopPlayer() {
    _mPlayer!.stopPlayer().then((value) {
      setState(() {});
    });
  }

  VFunc? getRecorderFn() {
    if (!_mRecorderIsInited || !_mPlayer!.isStopped) {
      return null;
    }
    return _mRecorder!.isStopped ? record : stopRecorder;
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
        body: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: Column(children: <Widget>[
            const SizedBox(height: 78),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text("Audio Verification",
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
                        applicationLegalese: (loggedInUser.name == null)
                            ? ""
                            : 'Please record yourself saying the phrase \'Hello, my name is ${loggedInUser.name} and I confirm that I am the real owner of this account.\' in a quiet environment. This audio can be used to test your authenticity and verify you in the future by Airdropped Insurance.');
                  })
            ]),
            const SizedBox(height: 24),
            IconButton(
              iconSize: 72,
              color: Colors.red,
              icon: (_mRecorder!.isRecording)
                  ? const Icon(Icons.radio_button_unchecked)
                  : const Icon(Icons.radio_button_checked),
              onPressed: getRecorderFn(),
            ),
          ]),
        ));
  }

  // the logout function
  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    // ignore: use_build_context_synchronously
    if(!context.mounted) return;
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()));
  }
}
