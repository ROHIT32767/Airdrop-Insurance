// ignore_for_file: file_names

import 'package:app/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ignore: must_be_immutable, use_key_in_widget_constructors
class GridDashboard extends StatelessWidget {
  User? user = FirebaseAuth.instance.currentUser;
  final UserModel loggedInUser;
  GridDashboard({Key? key, required this.loggedInUser}) : super(key: key);
  Items item1 = Items(
      title: "KYC",
      subtitle: "Verify yourself!",
      event: "",
      img: "assets/home/kyc.png",
      route: 'kyc');

  Items item2 = Items(
      title: "Wallet",
      subtitle: "Your MetaMask wallet",
      event: "",
      img: "assets/home/wallet.png",
      route: 'wallet');

  Items item3 = Items(
      title: "Insurance",
      subtitle: "Insurance Plans you can buy",
      event: "",
      img: "assets/home/eth.png",
      route: 'insurance_options');

  Items item4 = Items(
      title: "Precipitation",
      subtitle: "Local Precipitation levels",
      event: "",
      img: "assets/home/rain.png",
      route: 'precipitation');

  Items item5 = Items(
      title: "Discourse",
      subtitle: "Engage with the community!",
      event: "",
      img: "assets/home/chat.png",
      route: 'discourse');

  Items item6 = Items(
      title: "Polls",
      subtitle: "Make your voice heard!",
      event: "",
      img: "assets/home/snapshot.png",
      route: 'snapshot');

  Items item7 = Items(
      title: "Insurance Claim",
      subtitle: "Get what's owed to you!",
      event: "",
      img: "assets/home/briefcase.png",
      route: 'insurance_claim');

  Items item8 = Items(
      title: "Manager page",
      subtitle: "Manage your community",
      event: "",
      img: "assets/home/manager.png",
      route: 'manager_page');

  Items item9 = Items(
      title: "Verify Claims",
      subtitle: "Verify Insurance Claims",
      event: "",
      img: "assets/home/claim.png",
      route: 'claim_verify');

  Items item10 = Items(
      title: "ManagerPoll",
      subtitle: "Become a Manager!!",
      event: "",
      img: "assets/home/snapshot.png",
      route: 'ManagerPoll');

  Items item11 = Items(
      title: "Bid",
      subtitle: "Take risk for a higher reward!",
      event: "",
      img: "assets/home/snapshot.png",
      route: 'InsuranceBid');

  @override
  Widget build(BuildContext context) {
    List<Items> myList = [item1, item2, item4, item5, item6, item7, item10];
    if (loggedInUser.role != null &&
        (loggedInUser.role == "manager" || loggedInUser.role == "admin")) {
      myList.add(item9);
    }
    if (loggedInUser.role != null && loggedInUser.role == 'speculator') {
      myList = [item1, item2, item4, item5 , item11];
    }
    if (loggedInUser.role != null && loggedInUser.role == 'admin') {
      myList.add(item8);
    }
    var color = 0xff453658;
    return Flexible(
      child: GridView.count(
        childAspectRatio: 1.0,
        padding: const EdgeInsets.only(left: 16, right: 16),
        crossAxisCount: 2,
        crossAxisSpacing: 18,
        mainAxisSpacing: 18,
        children: myList.map((data) {
          return Container(
            foregroundDecoration: BoxDecoration(
              color: (data.title == "KYC" ||
                      (loggedInUser.coinbaseVerified != null &&
                          loggedInUser.coinbaseVerified!) ||
                      (loggedInUser.kycVerified != null &&
                          loggedInUser.kycVerified!) ||
                      user!.emailVerified)
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
                //removed true from here
                if (data.title == "KYC" ||
                    user!.emailVerified ||
                    loggedInUser.kycVerified! ||
                    loggedInUser.coinbaseVerified!) {
                  Navigator.pushNamed(context, data.route);
                }
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(data.img, width: 42),
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
