import 'package:app/Home/home.dart';
import 'package:app/KYC/kyc.dart';
import 'package:app/KYC/record_audio.dart';
import 'package:app/Manager/manager.dart';
import 'package:app/ManagerPoll/ManagerPoll.dart';
import 'package:app/Precipitation/precipitation.dart';
import 'package:app/firebase_options.dart';
import 'package:app/Introduction/introduction_animation_screen.dart';
import 'package:app/Authentication/register.dart';
import 'package:app/snapshot/snapshot.dart';
import 'package:flutter/material.dart';
import 'package:app/Authentication/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app/InsuranceOptions/insurance_options.dart';
import 'package:app/InsuranceClaim/insurance_claim.dart';
import 'package:app/ClaimVerification/page.dart';
import 'package:app/Wallet/address_key.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:app/Wallet/wallet.dart';
import 'Discourse/discourse_wview.dart';
import 'InsuranceBid/InsuranceBid.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  User? user = FirebaseAuth.instance.currentUser;

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(fontFamily: 'Avenir'),
    initialRoute: (user == null) ? 'intro' : 'home',
    routes: {
      'intro': (context) => const IntroductionAnimationScreen(),
      'register': (context) => const RegistrationScreen(),
      'login': (context) => const LoginScreen(),
      'home': (context) => const HomePage(),
      'kyc': (context) => const KYCPage(),
      'insurance_options': (context) => const InsuranceOptionsScreen(),
      'wallet': (context) => const WalletScreen(),
      'insurance_claim': (context) => const InsuranceClaimScreen(),
      'discourse': (context) => const DiscoursePage(),
      'add_key': (context) => const AddKeyScreen(),
      'precipitation': (context) => const Precipitation(),
      'snapshot': (context) => const SnapshotPage(),
      'audio': (context) => const RecorderPage(),
      'manager_page': (context) => const ManagerPage(),
      'claim_verify': (context) => const ClaimVerifyPage(),
      'ManagerPoll' : (context) => const ManagerPollPage(),
      'InsuranceBid' : (context) => const InsuranceBid(),
    },
  ));
}
