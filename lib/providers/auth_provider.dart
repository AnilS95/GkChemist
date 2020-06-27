import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:xml2json/xml2json.dart';


import '../models/models.dart';
import '../Utils.dart';


class Auth with ChangeNotifier{

  Timer _authTimer;
  Map<String,dynamic> userData={};
  String get name => userData[ChemistLogin.FirstName]+" "+userData[ChemistLogin.LastName];
  String get shopUserID => userData[ChemistLogin.ShopUserID];
  String get password=>userData[ChemistLogin.Password];
  var _firstTime=false;


  Future<void> loginUser(String username,String password) async {
    String baseUrl="http://www.giftkarting.com";
    String url='/gkchem/ChemService.asmx/ValidateShopUser?Username=$username&Password=$password';
  
    try{
      final response=await http.get(baseUrl+url);
      final Xml2Json xml2Json = Xml2Json();
      xml2Json.parse(response.body.toString());
      var jsonString = xml2Json.toParker();
      var data = jsonDecode(jsonString);
      if(data['NewDataSet']['Table']['UserExists']=="False"){
        throw HttpException("You are not active user.");
      }
      else if(data['NewDataSet']['Table']['UserExists']=="True"){

        userData[ChemistLogin.FirstName]=data['NewDataSet']['Table']['FirstName'];
        userData[ChemistLogin.LastName]=data['NewDataSet']['Table']['LastName'];
        userData[ChemistLogin.MobileNo]=data['NewDataSet']['Table']['Mobile'];
        userData[ChemistLogin.RoleID]=data['NewDataSet']['Table']['RoleID'];
        userData[ChemistLogin.ShopID]=data['NewDataSet']['Table']['ShopID'];
        userData[ChemistLogin.ShopUserID]=data['NewDataSet']['Table']['ShopUserID'];
        userData[ChemistLogin.Password]=data['NewDataSet']['Table']['Password'];
        var _firstTimeLoaded=data['NewDataSet']['Table']['FirstLogin'];
       
        if(_firstTimeLoaded=="true"){
          //throw HttpException(HttpExceptionStrings.FirstTime);
          _firstTime=true;
         
        }
        //set the expity date
        DateTime _expiryDate=DateTime.now().add(
          Duration(minutes: 30)
        );
        userData[ChemistLogin.Exp]=_expiryDate.toIso8601String();
        notifyListeners();
        _autoLogout();

        //set the user value into shared prefs
        final prefs=await SharedPreferences.getInstance();
        prefs.setString('userData', json.encode(userData));
      }

      
    }
    catch(error){
      print(error); 
      throw error;
    }
  }


  bool get isAuth{
    //if userName= null then returns the false
    return userData[ChemistLogin.MobileNo]!=null;
  }


  bool get firstTime=> _firstTime;


  Future<void> logout()async{
    userData.clear();

    if(_authTimer!=null){
      _authTimer.cancel();
      _authTimer=null;
    }
    notifyListeners();
    final prefs=await SharedPreferences.getInstance();
    //prefs.remove('userData');
    prefs.clear();
  }


  Future<bool> tryAutoLogin()async{

    final prefs=await SharedPreferences.getInstance();
    if(!prefs.containsKey('userData')){
      return false;
    }
    final extractedData=json.decode(prefs.getString('userData')) as Map<String,Object>;
   
    var expDate=DateTime.parse(extractedData[ChemistLogin.Exp]);

    if(expDate.isBefore(DateTime.now())){
      prefs.remove('userData');
      return false;
    }

    userData=extractedData;
    notifyListeners();
    _autoLogout();
    return true;
  }

  void _autoLogout(){
    
    if(_authTimer!=null){
      _authTimer.cancel();
    }

    DateTime expDate=DateTime.parse(userData[ChemistLogin.Exp]);
    final timeToExpiry=expDate.difference(DateTime.now()).inSeconds;
    _authTimer=Timer(
      Duration( 
        //seconds: 10 for testing
        seconds: timeToExpiry,
      ),
      logout
    );
  }


  Future<void> toggleFirstTimeUser()async{
    _firstTime=false;
    notifyListeners();
  }

  Future<bool> changePassword(String oldPassword,String newPassword)async{


    bool result=false;

    try{
      
      String url="http://www.giftkarting.com//gkchem/ChemService.asmx/ChangePassword?ShopUserID=$shopUserID&Password=$newPassword";
      final response=await http.get(url);
      print(url);
      final Xml2Json xml2Json = Xml2Json();
      xml2Json.parse(response.body.toString());
      var jsonString = xml2Json.toParker();
      var data = jsonDecode(jsonString);
      
     
      if(data['boolean']=="true"){
        userData[ChemistLogin.Password]=newPassword;
        _firstTime=false;
        notifyListeners();
        print("yes password is chaned");
        result=true;
        
      }


      



      return result;

    }
    catch(error){
      throw error;
    }
  }
}