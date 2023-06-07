// ignore_for_file: use_build_context_synchronously, unused_import

import 'dart:collection';

import 'package:app/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fast_forms/flutter_fast_forms.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

class CreatePollPage extends StatefulWidget {
  const CreatePollPage({Key? key}) : super(key: key);

  @override
  CreatePollPageState createState() => CreatePollPageState();
}

class CreatePollPageState extends State<CreatePollPage> {
  final DateTime today = DateTime.now();

  List<Widget> _buildForm(BuildContext context) {
    return [
      FastFormSection(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        header: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            'Propose a poll',
            style: GoogleFonts.openSans(
              textStyle: const TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        children: [
          FastTextField(
            name: 'poll_title',
            labelText: 'Poll Title',
            placeholder: 'What would you like to ask?',
            maxLength: 60,
            prefix: const Icon(Icons.poll),
            buildCounter: inputCounterWidgetBuilder,
            inputFormatters: const [],
            validator: Validators.compose([
              Validators.required((value) => 'Field is required'),
              Validators.minLength(
                  3,
                  (value, minLength) =>
                      'Field must contain at least $minLength characters')
            ]),
          ),
          const FastTextField(
            name: 'poll_info',
            labelText: 'Additional information',
            placeholder:
                'Would you like to provide more context / information?',
            maxLength: 280,
            prefix: Icon(Icons.question_answer),
            buildCounter: inputCounterWidgetBuilder,
            inputFormatters: [],
          ),
          FastDateRangePicker(
            name: 'poll_date_range',
            labelText: 'Poll duration',
            firstDate: DateTime.now(),
            lastDate: DateTime(today.year + 10, today.month, today.day),
            validator: Validators.required((value) => 'Field is required'),
          ),
          const FastChipsInput(
            name: 'poll_options',
            labelText: 'Poll options',
            options: ['Yes', 'No'],
          ),

        ],
      ),
    ];
  }

  void submitForm(UnmodifiableMapView<String, dynamic> formData) async {
    final auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    // Input validation
    if (formData['poll_title'] == null) {
      Fluttertoast.showToast(msg: "Please give your poll a title.");
      return;
    }
    if (formData['poll_date_range'] == null) {
      Fluttertoast.showToast(
          msg: "Please provide a duration to keep the poll active for.");
      return;
    }
    if (formData['poll_options'] == null ||
        formData['poll_options'].length < 2) {
      Fluttertoast.showToast(
          msg: "Please provide at least 2 options to vote for.");
      return;
    }
    // Upload proposal to firebase

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

    DatabaseReference inreview = FirebaseDatabase.instance.ref("inreview/");
    try {
      await inreview.push().set({
        'title': formData['poll_title'],
        'info': formData['poll_info'],
        'options': formData['poll_options'],
        'start': formData['poll_date_range'].start.toString(),
        'end': formData['poll_date_range'].end.toString(),
        'creator_id': user?.uid,
        'ManagerPoll':false
      });
      Fluttertoast.showToast(msg: "Your poll proposal was successfully sent!");
        if (!context.mounted) return;

      Navigator.pop(context);
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
      if (!context.mounted) return;

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    UnmodifiableMapView<String, dynamic> formData = UnmodifiableMapView({});

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 253, 146),
      appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Colors.black)),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              FastForm(
                formKey: formKey,
                children: _buildForm(context),
                onChanged: (value) {
                  formData = value;
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 5),
                    ),
                    onPressed: () => formKey.currentState?.reset(),
                    child: const Text('Reset Form'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 5),
                    ),
                    onPressed: () {
                      submitForm(formData);
                    },
                    child: const Text('Submit Poll Proposal'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
