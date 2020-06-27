import 'package:flutter/material.dart';
import 'package:gk_chemist/screens/change_password_page.dart';
import 'package:provider/provider.dart';

import '../widgets/widgets.dart';
import '../providers/providers.dart';

 final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

class HomePage extends StatelessWidget {
  static const routeName = '/home-page';

  @override
  Widget build(BuildContext context) {
    //var args = ModalRoute.of(context).settings.arguments as Map<String,dynamic>;
   
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('GK Chemist'),
      ),
      drawer: MyAppDrawer(
        userName:"Bhavik Vashi",
      ),
      
      body: HomePageBody(),
      
    );
  }
}



class HomePageBody extends StatefulWidget {
  @override
  _HomePageBodyState createState() => _HomePageBodyState();
}

class _HomePageBodyState extends State<HomePageBody> {

  @override
  void initState() {
    super.initState();
  }


  @override
  void didChangeDependencies() {

    WidgetsBinding.instance.addPostFrameCallback((_){

      var _firstTime=Provider.of<Auth>(context,listen: false).firstTime;
      if(_firstTime){
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            content: Row(children: [
              Icon(Icons.warning),
              SizedBox(width: 10,),
              Text("You are the first-time user, so you must change the password."),
            ],),
            actions: [
              FlatButton(
                onPressed: ()=>Navigator.of(context).pushNamed(ChangePasswordPage.routeName), 
                child: Text("Change Password")
              )
            ],
          ),
        );
      }
    });
    super.didChangeDependencies();
  }
  


  
  
  @override
  Widget build(BuildContext context) {
    
    return Center(
      child: Text('This is home page'),
    );
  }
}

