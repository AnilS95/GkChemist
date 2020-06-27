
import 'package:http/http.dart' as http;
import 'package:xml2json/xml2json.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';


import '../Utils.dart';



class UserHelper{


  static Future<bool> registerNewUser(Map x)async{
    
    String url='http://www.giftkarting.com/gkchem/ChemService.asmx/ShopAndUserInsertUpdate?';
    String data='FirstName=${x[UserUtils.FirstName]}&LastName=${x[UserUtils.LastName]}&ShopName=${x[UserUtils.ShopName]}&ShopAddress=${x[UserUtils.ShopAddress]}&Landmark=${x[UserUtils.ShopLandMark]}&Pincode=${x[UserUtils.ShopPincode]}&Mobile=${x[UserUtils.MobileNo]}&Email=${x[UserUtils.EmailID]}&Zone=${x[UserUtils.ShopZone]}&State=${x[UserUtils.ShopState]}&City=${x[UserUtils.ShopCityName]}';

    var result =false;

    try{
      final response = await http.get(
        url+data,
      );
     
      print(response.statusCode);
      print(response.body);
      if(response.statusCode==200){
        result=true;
      }

      return result;
      
    }
    catch(error){  
      throw error;
    }
   
  }


  static Future<String> checkMobileNo(String mobileNo)async{
    try{
      var result;
      String url='http://www.giftkarting.com/gkchem/ChemService.asmx/ValidateUserMobile?Mobile=$mobileNo';
      final response=await http.get(url);
      final Xml2Json xml2Json = Xml2Json();
      xml2Json.parse(response.body.toString());
      var jsonString = xml2Json.toParker();
      var data = jsonDecode(jsonString);
      result=data['boolean'];
      return result;

    }
    catch(error){
      print(error);
      throw error;
    }
  }


  static Future<Map<String,Object>> getUserProfileInfo(String shopUserID)async{

    Map<String,Object> shopUserData={

    };


    final _prefs=await SharedPreferences.getInstance();
    if(_prefs.containsKey('shopUserData')){
      shopUserData=json.decode(_prefs.getString('shopUserData')) as Map<String,Object>;
      return shopUserData;
    }

    else{
      try{  
        String url='http://www.giftkarting.com/gkchem/ChemService.asmx/GetUserProfile?ShopUserID=$shopUserID';
        final response=await http.get(url);
        final Xml2Json xml2Json = Xml2Json();
        xml2Json.parse(response.body.toString());
        var jsonString = xml2Json.toParker();
        var data = jsonDecode(jsonString);
        var data1=data['NewDataSet']['Table']['XML_F52E2B61-18A1-11d1-B105-00805F49916B'];
        xml2Json.parse(data1);
        var jsonString1 = xml2Json.toParker();
        var data2 = jsonDecode(jsonString1);
      
        var shopUser=data2['ShopUserListing']['ShopUser'];

        shopUserData[ShopUserData.FirstName]=shopUser['FirstName'];
        shopUserData[ShopUserData.Lastname]=shopUser['LastName'];
        shopUserData[ShopUserData.EmailID]=shopUser['Email'];
        shopUserData[ShopUserData.MobileNo]=shopUser['Mobile'];
        shopUserData[ShopUserData.ShopName]=shopUser['ShopName'];
        shopUserData[ShopUserData.ShopAddress]=shopUser['ShopAddress'];
        shopUserData[ShopUserData.ShopLandmark]=shopUser['Landmark'];
        shopUserData[ShopUserData.ShopPincode]=shopUser['Pincode'];
        shopUserData[ShopUserData.ShopCity]=shopUser['City'];
        shopUserData[ShopUserData.ShopState]=shopUser['StateName'];
        shopUserData[ShopUserData.ShopZone]=shopUser['ZoneName'];
        final prefs=await SharedPreferences.getInstance();
        prefs.setString('shopUserData', json.encode(shopUserData));
        return shopUserData;
        
      }
      catch(error){
        print(error);
        throw error;
      }
    }
   
    



  }

  

}