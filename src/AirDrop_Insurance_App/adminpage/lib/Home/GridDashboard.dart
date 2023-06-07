// ignore_for_file: unused_import, file_names

import 'dart:developer';
import 'package:adminpage/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ignore: must_be_immutable, use_key_in_widget_constructors
class GridDashboard extends StatelessWidget {
  User? user = FirebaseAuth.instance.currentUser;
  final UserModel loggedInUser;
  GridDashboard({Key? key, required this.loggedInUser}) : super(key: key);

  Items item1 = Items(
      title: "Approve Claims",
      subtitle: "Approve Insurance Claims",
      event: "",
      img: "assets/home/approve.png",
      route: 'claim_approve');

  Items item2 = Items(
      title: "Add Options",
      subtitle: "Add Insurance Options",
      event: "",
      img: "assets/home/add_option.png",
      route: 'insurance_add');

  Items item3 = Items(
      title: "Airdrop",
      subtitle: "Airdrop insurance",
      event: "",
      img: "assets/home/airdrop.png",
      route: 'airdrop');

  Items item4 = Items(
      title: "Approve Manager Requests",
      subtitle: "Hire New Managers",
      event: "",
      img: "assets/home/airdrop.png",
      route: 'ManagerPoll');

  @override
  Widget build(BuildContext context) {
    List<Items> myList = [
      item1,
      item2,
      item3,
      item4
    ];
    var color = 0xff453658;
    return Flexible(
      child: GridView.count(
        childAspectRatio: 1.0,
        padding: const EdgeInsets.only(left: 16, right: 16),
        crossAxisCount: 3,
        crossAxisSpacing: 18,
        mainAxisSpacing: 18,
        children: myList.map((data) {
          return Container(
            foregroundDecoration: BoxDecoration(
              color:
                  (loggedInUser.role != null && loggedInUser.role == "admin") &&
                          (data.title == "KYC" ||
                              (loggedInUser.coinbaseVerified != null &&
                                  loggedInUser.coinbaseVerified!) ||
                              (loggedInUser.kycVerified != null &&
                                  loggedInUser.kycVerified!))
                      ? Colors.transparent
                      : Colors.grey,
              backgroundBlendMode: BlendMode.saturation,
            ),
            decoration: BoxDecoration(
              color: Color(color),
              borderRadius: BorderRadius.circular(10),
            ),
            child: InkWell(
              onTap: () {
                if ((loggedInUser.role != null &&
                        loggedInUser.role == "admin") &&
                    (data.title == "KYC" ||
                        (loggedInUser.coinbaseVerified != null &&
                            loggedInUser.coinbaseVerified!) ||
                        (loggedInUser.kycVerified != null &&
                            loggedInUser.kycVerified!))) {
                  Navigator.pushNamed(context, data.route);
                }
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(data.img, width: 128),
                  const SizedBox(height: 14),
                  Text(
                    data.title,
                    style: GoogleFonts.openSans(
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    data.subtitle,
                    style: GoogleFonts.openSans(
                      textStyle: const TextStyle(
                        color: Colors.white38,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    data.event,
                    style: GoogleFonts.openSans(
                      textStyle: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class Items {
  String title;
  String subtitle;
  String event;
  String img;
  String route;
  Items(
      {required this.title,
      required this.subtitle,
      required this.event,
      required this.img,
      required this.route});
}
