import 'package:http/http.dart' as http;
import 'package:xml2json/xml2json.dart';
import 'dart:convert';


class LocationHelper{

   
  static Future<List<String>> getZones()async{


    List<String> zones=[];


    try{
      final url = 'https://www.giftkarting.com/gkchem/ChemService.asmx/GetZones';
      final response = await http.get(url);
    
      final Xml2Json xml2Json = Xml2Json();
      xml2Json.parse(response.body.toString());
      var jsonString = xml2Json.toParker();
      var data = jsonDecode(jsonString);
      var data1=data['NewDataSet']['Table']['XML_F52E2B61-18A1-11d1-B105-00805F49916B'];

      //second time parsing data to json
      xml2Json.parse(data1);
      var jsonString2=xml2Json.toParker();
      var data2=jsonDecode(jsonString2);
      var zoneData=data2['ZoneListing']['Zones'];

      for(int i=0;i<zoneData.length;i++){
        zones.add(zoneData[i]['ZoneName']);
      }
      return zones;

    }
    catch(error){
      throw error;
    }
      
    
   
  }

  static Future<List<String>> getStates(String zone)async{
    
    try{
       List<String> states=[];
      final url = 'https://www.giftkarting.com/gkchem/ChemService.asmx/GetStates?Zone=$zone';
      final response = await http.get(url);
      final Xml2Json xml2Json = Xml2Json();
      xml2Json.parse(response.body.toString());
      var jsonString = xml2Json.toParker();
      var data = jsonDecode(jsonString);
      var data1=data['NewDataSet']['Table']['XML_F52E2B61-18A1-11d1-B105-00805F49916B'];
      
      //second time parsing data to json
      xml2Json.parse(data1);
      var jsonString2=xml2Json.toParker();
      var data2=jsonDecode(jsonString2);
      var stateData=data2['StateListing']['States'];
      if(stateData.length==1){
        //print(stateData['StateName']);
        states.add(stateData['StateName']);

      }
      else{
        for(int i=0;i<stateData.length;i++){
          states.add(stateData[i]['StateName']);
        }
      }
      return states;

    }
    catch(error){
      throw error;
    }
  }

}