import 'package:flutter/material.dart';
import 'package:provider/provider.dart';



import '../providers/providers.dart';

class ChangePasswordPage extends StatelessWidget {
  static const routeName = '/change-password';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Password'),
      ),
      body: Center(
        child: ChangePasswordCard(),
      )
    );
  }
}

class ChangePasswordCard extends StatefulWidget {
  @override
  _ChangePasswordCardState createState() => _ChangePasswordCardState();
}

class _ChangePasswordCardState extends State<ChangePasswordCard> {

  
  var _obscureTextCurrentPassword=true;
  var _obscureTextNewPassword=true;
  var _obscureTextConfirmPassword=true;
  var userName="";


  bool _isLoading=false;

  TextEditingController _oldPasswordController;
  TextEditingController _newPasswordController;
  TextEditingController _conPasswordController;

  @override
  void initState() {
    userName=Provider.of<Auth>(context,listen: false).name;
    _oldPasswordController=TextEditingController();
    _newPasswordController=TextEditingController();
    _conPasswordController=TextEditingController();

    super.initState();
  }

  

  

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _conPasswordController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.75,
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$userName',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 20,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(labelText: 'Current Password'),
                    obscureText: _obscureTextCurrentPassword,
                    controller: _oldPasswordController,
                  ),
                ),
                IconButton(
                  icon: _obscureTextCurrentPassword?
                  Icon(Icons.visibility):Icon(Icons.visibility_off), 
                  onPressed: (){
                    setState(() {
                      _obscureTextCurrentPassword=!_obscureTextCurrentPassword;
                    });
                  }
                )
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(labelText: 'New Password'),
                    obscureText: _obscureTextNewPassword,
                    controller: _newPasswordController,
                  ),
                ),
                IconButton(
                  icon: _obscureTextNewPassword?
                  Icon(Icons.visibility):Icon(Icons.visibility_off), 
                  onPressed: (){
                    setState(() {
                      _obscureTextNewPassword=!_obscureTextNewPassword;
                    });
                  }
                )
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(labelText: 'Confirm Password'),
                    obscureText: _obscureTextConfirmPassword,
                    controller: _conPasswordController,
                  ),
                  
                ),
                IconButton(
                  icon: _obscureTextConfirmPassword?
                  Icon(Icons.visibility):Icon(Icons.visibility_off), 
                  onPressed: (){
                    setState(() {
                     _obscureTextConfirmPassword=!_obscureTextConfirmPassword;
                    });
                  }
                )
              ],
            ),
            SizedBox(
              height: 20,
            ),
            _isLoading?CircularProgressIndicator():
            RaisedButton(
              child:Text('Change Password'),
              onPressed:(){
                changePW();
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding:
                  EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
              color: Theme.of(context).primaryColor,
              textColor: Theme.of(context).primaryTextTheme.button.color,
            ),
          ],
        ),
      ),
    );
  }


  Future<void> changePW()async{
    setState(() {
      _isLoading=true;
    });

    if(_oldPasswordController.text==""){
      Scaffold.of(context).showSnackBar(SnackBar(content: Text("Please enter the current password.")));
    }
    else if(_newPasswordController.text==""){
      Scaffold.of(context).showSnackBar(SnackBar(content: Text("Please enter the new password.")));
    }
    else if(_conPasswordController.text==""){
      Scaffold.of(context).showSnackBar(SnackBar(content: Text("Please enter the confirm password.")));
    }
    else if(_newPasswordController.text!=_conPasswordController.text){
      _showError("Please make sure your (new & confirm)passwords are same.");
    }
    else{
      var loadedOldPW=Provider.of<Auth>(context,listen: false).password;
      if(_oldPasswordController.text!=loadedOldPW){
         _showError("Please check your old password.");
      }
      else if(_oldPasswordController.text==_newPasswordController.text){
        _showError("Your current password and new password is same.");
      }
      else{
        try{
          bool res=await Provider.of<Auth>(context,listen: false).changePassword(_oldPasswordController.text, _newPasswordController.text);
          if(res){
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                content: Text("Password changed successfully"),
                actions: [
                  FlatButton(
                    onPressed: (){
                      Navigator.of(context).pushReplacementNamed('/');
                    }, 
                    child: Text("Okay")
                  )
                ],
              ),
            );

          }
          else{
            _showError("Something went wrong!");
          }

        }
        catch(error){
          print(error);
          showDialog(context: context,builder:(ctx)=>AlertDialog(content: Text("Something went wrong!"),));
        }
      }
    }

    
    setState(() {
        _isLoading=false;
    });
    
  }


  void _showError(String msg){
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        content: Text(msg),
        actions: [
          FlatButton(onPressed:()=>Navigator.of(context).pop(), child: Text("Okay")),
        ],
      ),
    );

  }
}
