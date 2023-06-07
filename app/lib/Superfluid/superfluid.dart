import 'package:superfluid/superfluid.dart';
import 'package:web3dart/web3dart.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
Web3Provider ethProvider = Web3Provider(
  new HttpProvider("https://ropsten.infura.io/v3/your_project_id_here"),
);
Superfluid superfluid = Superfluid(ethProvider);
Credentials creds = await ethProvider.getCredentials(privateKey);
String daiAddress = "0x6B175474E89094C44Da98b954EedeAC495271d0F";
SuperToken daiToken = await superfluid.getSuperToken(
  Address.fromString(daiAddress),
);