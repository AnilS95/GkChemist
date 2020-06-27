import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml2json/xml2json.dart';
import 'dart:convert';

import '../models/campaign.dart';
import '../Utils.dart';

class Campaigns with ChangeNotifier{
  
  
  
  List<Campaign> _userCampaigns=[];
  Campaign _selectedCampaign;
  String shopUserID;

  Campaigns({this.shopUserID});
  
  List<Campaign>  get userCampaigns{
    return [..._userCampaigns];
  }


  Campaign get selectedCampaign{
    if(_selectedCampaign!=null){
      return _selectedCampaign;
    }
    else{
      return Campaign(
        campaignName: "Null",
        campaignCode: "",
        campaignCorpName: "",
        campaignID: "",
      );
    }
  }

  String getCampaignCode(String campName){
    Campaign c=_userCampaigns.firstWhere((element) =>element.campaignName==campName);
    return c.campaignCode;
  }

  Future<void> setSelectedCampaign(Campaign c)async{

    //save to the shared prefs
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    var selectedCampData={
      CampData.CampName: c.campaignName,
      CampData.CampID: c.campaignID,
      CampData.CampCode: c.campaignCode,
      CampData.CampCrop:c.campaignCorpName,
      
    };
    _prefs.setString("shopUserSelectedCamp$shopUserID", json.encode( selectedCampData));
    _selectedCampaign=c;
    notifyListeners();
  }

  Future<void> fetchAndSetSelectedCampaign()async{
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    if(_prefs.containsKey('shopUserSelectedCamp$shopUserID')){
      print("loaded from shared prefs");
      var _loadedSelectedCamp=json.decode(_prefs.getString('shopUserSelectedCamp$shopUserID')) as Map<String,Object>;
      setSelectedCampaign(
        Campaign(
          campaignCode: _loadedSelectedCamp[CampData.CampCode],
          campaignCorpName: _loadedSelectedCamp[CampData.CampCrop],
          campaignID: _loadedSelectedCamp[CampData.CampID],
          campaignName: _loadedSelectedCamp[CampData.CampName],
        )
      );
    }
  }

  Future<void> fetchAndSetCampaigns()async{
    _userCampaigns=[];
    String baseURL="http://www.giftkarting.com";
    String url="/gkchem/ChemService.asmx/GetUserCampaign?ShopUserID=$shopUserID";
    

    try{
      final campaignRes=await http.get(baseURL+url);
      
      final Xml2Json xml2Json = Xml2Json();
      xml2Json.parse(campaignRes.body.toString());
      var jsonString = xml2Json.toParker();
      var data = jsonDecode(jsonString);
      var data1=data['NewDataSet']['Table']['XML_F52E2B61-18A1-11d1-B105-00805F49916B'];
      
      xml2Json.parse(data1);
      var jsonString1 = xml2Json.toParker();
      var data3 = jsonDecode(jsonString1);
      

      var loadedCampaigns=data3['CampListing']['Campaigns'] ;
     
    
      if(loadedCampaigns.toString().startsWith("{")){
        loadedCampaigns=[
          loadedCampaigns,
        ];
      }
        
      for(int i=0;i<loadedCampaigns.length;i++){
        if(loadedCampaigns[i]['UserCampExists']=="True"){         
          var campObj=Campaign(
            campaignID: loadedCampaigns[i]['CampaignID'], 
            campaignName: loadedCampaigns[i]['CampaignName'], 
            campaignCode: loadedCampaigns[i]['CampaignCode'] , 
            campaignCorpName: loadedCampaigns[i]['CorpName'],
          );
          _userCampaigns.add(campObj);
        }
      }  
      notifyListeners();

    }
    catch(error){
     
    }

  }


  Future<bool> addNewCamp(String campCode)async{
    var result=false;

    try{
      String baseURL="http://www.giftkarting.com";
      String url="/gkchem/ChemService.asmx/AddCampaign?ShopUserID=$shopUserID&CampaignCode=$campCode";
     
      var res=await http.get(baseURL+url);
      final Xml2Json xml2Json = Xml2Json();
      xml2Json.parse(res.body.toString());
      var jsonString = xml2Json.toParker();
      var data = jsonDecode(jsonString);
      var data1=data['NewDataSet']['Table']['XML_F52E2B61-18A1-11d1-B105-00805F49916B'];
       xml2Json.parse(data1);
      var jsonString1 = xml2Json.toParker();
      var data2 = jsonDecode(jsonString1);
      
      var data3=data2['CampListing']['Camp']['Result'];
      if(data3=="False"){
        print("Check your campaign code");
        result=false;
      }
      else{
        await fetchAndSetCampaigns();
        result=true;
      }

    }
    catch(error){

    }
    
    return result;

  }


  

}
