import 'package:flutter/cupertino.dart';
class Campaign with ChangeNotifier{


  final String campaignID;
  final String campaignName;
  final String campaignCode;
  final String campaignCorpName;


  Campaign({
    @required this.campaignID,
    @required this.campaignName,
    @required this.campaignCode,
    @required this.campaignCorpName
  });

  @override
  String toString() {
    String data="Campaign ID: $campaignID, Campaign Name: $campaignName, Campaign Code: $campaignCode, Campaign Crop: $campaignCorpName";
    return data;
  }


}