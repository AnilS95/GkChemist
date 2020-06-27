import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../screens/screens.dart';

class MyAppDrawer extends StatelessWidget {
  
  final String userName;

  MyAppDrawer({this.userName});
  
  @override
  Widget build(BuildContext context) {
    var userName=Provider.of<Auth>(context,listen: false).name;
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: Text('Hello $userName!'),
            automaticallyImplyLeading: false,
            //means does not apply back button at here
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.receipt),
            title: Text('Approve Invoice'),
            onTap: (){
              Navigator.of(context).pushNamed(ApproveInvoicePage.routeName);   
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.card_membership),
            title: Text('Campaigns'),
            onTap: (){
              Navigator.of(context).pushNamed(AddCampaignPage.routeName);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.account_box),
            title: Text('Profile'),
            onTap: (){
              Navigator.of(context).pushNamed(ProfilePage.routeName);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: (){
              //Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/');
              Provider.of<Auth>(context,listen: false).logout();
              
            },
          ),

        ],
      ),

      
    );
  }
}