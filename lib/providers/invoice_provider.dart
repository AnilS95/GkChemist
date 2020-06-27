
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter/cupertino.dart';

class Invoice with ChangeNotifier{

  var  shopUserData;
  Invoice({this.shopUserData});

  Future<void> getProducts()async{
   
  }

  Future<void> saveImage({String invoiceNo,String imageInByte})async{

    String baseURL="http://www.giftkarting.com/gkchem/ChemService.asmx/UploadImageFile";

    String soapBody='''
    <?xml version="1.0" encoding="utf-8"?>
    <soap12:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap12="http://www.w3.org/2003/05/soap-envelope">
      <soap12:Body>
        <UploadImageFile xmlns="http://tempuri.org/">
          <f>$imageInByte</f>
          <fileName>check001</fileName>
        </UploadImageFile>
      </soap12:Body>
    </soap12:Envelope>
    ''';

    

   
    http.Response response=await http.post(
      baseURL,
      headers: {
        'Content-Type': 'application/soap+xml; charset=utf-8',
       
        'SOAPAction':'http://tempuri.org/UploadImageFile'
      },
      body: utf8.encode( soapBody),
     
    );
    print(response.body);

  }

  Future<void> saveTranDetail()async{

  }

}