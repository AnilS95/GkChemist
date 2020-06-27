import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../screens/screens.dart';
import '../providers/providers.dart';
import '../models/models.dart';
import '../helpers/helpers.dart';


class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(215, 117, 255, 1).withOpacity(0.5),
                  Color.fromRGBO(255, 188, 117, 1).withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0, 1],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 200,
                    height: 200,
                    child: Image.asset('assets/logo/GK_logo.png', )
                  ),
                  AuthCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}




class AuthCard extends StatefulWidget {
  const AuthCard({
    Key key,
  }) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> with SingleTickerProviderStateMixin{
  
  final GlobalKey<FormState> _formKey = GlobalKey();
  
  var _showLogin=true;
  
  Map<String, String> _authData = {
    'phone': '',
    'password': '',
  };

  TextEditingController _mobileTextEditingController=TextEditingController();

  var _isLoading = false;
  var _obscureText = true;
  

  var containerHeight=260;

  final _mobileFocusNode=FocusNode();
  final _passwordFocusNode=FocusNode();


  @override
  void dispose() {
    _mobileFocusNode.dispose();
    _passwordFocusNode.dispose();
    _mobileTextEditingController.dispose();
    _mobileFocusNode.removeListener(_checkPhoneNo);
    super.dispose();
  }
 

  void _showErrorDialog(String mainMsg,String message){
    showDialog(
      context: context,
      builder: (ctx)=>AlertDialog(
        title: Text(mainMsg),
        content: Text(message),
        actions: <Widget>[
          FlatButton(
            onPressed: (){
              Navigator.of(ctx).pop();
            }, 
            child: Text('Okay')
          )
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });


    try{
      await Provider.of<Auth>(context, listen: false).loginUser(
          _authData['phone'],
          _authData['password'],
      );
    }
    on HttpException catch(error){
      print("here"+error.toString());
      _showErrorDialog("Authentication Problem !", "Check your password or "+error.msg);
     
    }
    catch(error){
      print("Common Error is $error");
      _showErrorDialog("Internet Connection Problem!","Please check your Internet Connectivity.");
    }

    setState(() {
      _isLoading = false;
      
    });
  }

  @override
  void initState() {
    _mobileFocusNode.addListener(_checkPhoneNo);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return IgnorePointer(
      ignoring: _isLoading,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 8.0,
      
        child: Container(
          padding: EdgeInsets.all(16.0),
          width: deviceSize.width * 0.75,
          child:Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Mobile Number'),
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    focusNode: _mobileFocusNode,
                    controller: _mobileTextEditingController,
                    validator: (value) {
                      if (value.isEmpty ) {
                        return 'Please provide Mobile Number.';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _authData['phone'] = value;
                    },
                    onFieldSubmitted: (value) {
                      FocusScope.of(context).requestFocus(_passwordFocusNode);
                    },
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(labelText: 'Password'),
                          obscureText: _obscureText,
                          focusNode: _passwordFocusNode,
                          validator: (value) {
                            if (value.isEmpty || value.length < 5) {
                              return 'Password is too short!';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _authData['password'] = value;
                          },
                         
                        ),
                      ),
                      IconButton(
                        icon: _obscureText?
                        Icon(Icons.visibility):Icon(Icons.visibility_off), 
                        onPressed: (){
                          setState(() {
                            _obscureText=!_obscureText;
                          });
                        }
                      )

                    ],
                    
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  if (_isLoading) CircularProgressIndicator()
                  else RaisedButton(
                    child:
                        Text('LOGIN'),
                    onPressed:_showLogin? _submit:null,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                    color: Theme.of(context).primaryColor,
                    textColor: Theme.of(context).primaryTextTheme.button.color,
                  ),
                  FlatButton(
                    child: Text('Register' ),
                    onPressed: (){
                      //navigate to registration page

                      Navigator.pushReplacementNamed(context, RegisterScreen.routeName);
                    },
                    padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    textColor: Theme.of(context).primaryColor,
                  ),
                ],
              ),
              
            ),
          ),
        ),
      ),
    );
  }



  Future<void> _checkPhoneNo() async {
    if (!_mobileFocusNode.hasFocus) {
      try{
        setState(() {
          _isLoading=true;
        });
        var res = await UserHelper.checkMobileNo(
            _mobileTextEditingController.text
        );
        if (res == "false") {
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext context) => AlertDialog(
              title: Text('There is no account registred with this mobile number.'),
              actions: <Widget>[
                FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Okay')
                )
              ],
            ),
          );

          setState(() {
            _showLogin=false;
          }); 
        }

        else if(res=="true"){
          _showLogin=true;
        }
        else{
          _showLogin=false;
        }
        setState(() {
          _isLoading=false;
        });

      }
      catch(error){
        setState(() {
          _showLogin=false;
          _isLoading=false;
        });
        _showErrorDialog("Internet Connection Problem!","Please check your Internet Connectivity.");
      }
    
    }
  }
}