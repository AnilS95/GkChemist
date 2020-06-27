import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/helpers.dart';
import '../providers/providers.dart';
import '../Utils.dart';
import '../screens/screens.dart';

class ProfilePage extends StatelessWidget {

  static const routeName = '/profile-view';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: ProfileBody(),
    );
  }
}

class ProfileBody extends StatefulWidget {
  @override
  _ProfileBodyState createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<ProfileBody> {
  var _isLoading=false;
  var userProfileData={};

  @override
  void initState() {

   
  
    var shopUserID=Provider.of<Auth>(context,listen: false).shopUserID;
    fetchData(shopUserID);
    
    
    
    
    super.initState();
  }


  Future<void> fetchData(String shopUserID)async{

    setState(() {
      _isLoading=true;
    });
    try{
      var result=await UserHelper.getUserProfileInfo(shopUserID);
      userProfileData=result;
    }
    catch(error){
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => AlertDialog(
          title: Text("Internet Connection Problem!"),
          content: Text("Please check your Internet Connectivity"),
          actions: [
            FlatButton(
              onPressed: (){
                Navigator.of(context).pop();
              }, 
              child: Text('Okay')
            )
          ],
        ),
      );
    }
    setState(() {
      _isLoading=false;
    });
   

  }

  @override
  Widget build(BuildContext context) {
    return _isLoading?Center(child: CircularProgressIndicator(),):
    Container(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '👩‍🔬 Chemist Information',
            style: TextStyle(
              color: Colors.blue,
              fontSize: 20
            ),
          ),
          SizedBox(height: 10,),
          Text('First Name: ${userProfileData[ShopUserData.FirstName]}'),
          Text('Last Name: ${userProfileData[ShopUserData.Lastname]}'),
          Text('Mobile Number: ${userProfileData[ShopUserData.MobileNo]}'),
          Text('Email ID: ${userProfileData[ShopUserData.EmailID]}'),

          SizedBox(height: 20,),         
          Text(
            '🏪 Shop Information',
            style: TextStyle(
              color: Colors.blue,
              fontSize: 20
            ),
          ),
          SizedBox(height: 10,),
          Text('Shop Name: ${userProfileData[ShopUserData.ShopName]}'),
          Text('Shop Address: ${userProfileData[ShopUserData.ShopAddress]}'),
          Text('Shop Landmark: ${userProfileData[ShopUserData.ShopLandmark]}'),
          Text('Shop City: ${userProfileData[ShopUserData.ShopCity]}'),
          Text('Shop Pincode: ${userProfileData[ShopUserData.ShopPincode]}'),
          Text('Shop State: ${userProfileData[ShopUserData.ShopState]}'),
          Text('Shop Zone: ${userProfileData[ShopUserData.ShopZone]}'),


          SizedBox(
            height: 30,
          ),
          Center(
            child: RaisedButton(
              onPressed: (){
                Navigator.of(context).pushNamed(EditProfilePage.routeName);
              },
              child: Text("Edit Profile"),
              color: Colors.blue,
              textColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Center(
            child: RaisedButton(
              onPressed: (){
                Navigator.of(context).pushNamed(ChangePasswordPage.routeName);
              },
              child: Text("Change Password"),
              color: Colors.blue,
              textColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          )



        ],
      ),

    );
   
    
  }
}