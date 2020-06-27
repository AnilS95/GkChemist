import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


import '../helpers/location_helper.dart';
import '../helpers/user_helper.dart';
import '../Utils.dart';

class RegisterScreen extends StatelessWidget {
  static const routeName = '/register';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('Chemist Registration'),
      ),
      body: Container(
        width: deviceSize.width,
        height: deviceSize.height,
        child: RegisterCard(),
      ),
    );
  }
}

class RegisterCard extends StatefulWidget {
  @override
  _RegisterCardState createState() => _RegisterCardState();
}

class _RegisterCardState extends State<RegisterCard> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  bool _isLoading = false;

  List<String> _zones = [];
  List<String> _states = [];
  String dropDownOfZoneValue;
  String dropDownOfStateValue;

  var _initValues = {
    UserUtils.FirstName: '',
    UserUtils.LastName: '',
    UserUtils.MobileNo: '',
    UserUtils.EmailID: '',
    UserUtils.ShopName: '',
    UserUtils.ShopAddress: '',
    UserUtils.ShopLandMark: '',
    UserUtils.ShopCityName: '',
    UserUtils.ShopPincode: '',
    UserUtils.ShopState: '',
    UserUtils.ShopZone: '',
  };



  

  final _firstNameFocusNode = FocusNode();
  final _lastNameFocusNode = FocusNode();
  final _mobileFocusMode = FocusNode();
  final _emailIDFocusNode = FocusNode();
  final _shopNameFocusNode = FocusNode();
  final _shopAddFocusNode = FocusNode();
  final _shopLandMarkFocusNode = FocusNode();
  final _shopCityNameFocusNode = FocusNode();
  final _shopPinCodeFocusNode = FocusNode();

  final mobileNumberController = TextEditingController();

  var _showSubmit = true;

  @override
  void initState() {
    _mobileFocusMode.addListener(_checkPhoneNo);


    

    getZone();

    super.initState();
  }

  @override
  void dispose() {
    _firstNameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _mobileFocusMode.dispose();
    _emailIDFocusNode.dispose();
    _shopNameFocusNode.dispose();
    _shopAddFocusNode.dispose();
    _shopLandMarkFocusNode.dispose();
    _shopCityNameFocusNode.dispose();
    _shopPinCodeFocusNode.dispose();

    _mobileFocusMode.removeListener(_checkPhoneNo);

    super.dispose();
  }

  Future<void> _checkPhoneNo() async {
    if (!_mobileFocusMode.hasFocus) {
      try{
        setState(() {
          _isLoading=true;
        });
        var res = await UserHelper.checkMobileNo(
            mobileNumberController.text
        );
        if (res == 'true') {
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext context) => AlertDialog(
              title: Text('Mobile Number already exist!'),
              content: Text('Try with another Mobile number'),
              actions: <Widget>[
                FlatButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/');
                    },
                    child: Text('Exit')
                ),
                FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Try with another')
                )
              ],
            ),
          );

          setState(() {
            _showSubmit=false;
          }); 
        }

        else if(res=="false"){
          _showSubmit=true;
        }
        else{
          _showSubmit=false;
        }
        setState(() {
          _isLoading=false;
        });

      }
      catch(error){
        setState(() {
          _showSubmit=false;
          _isLoading=false;
        });
        _showErrorDialog("Internet Connection Problem!","Please check your Internet Connectivity.");
      }
    
    }
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

  //get the zone information from server
  Future<void> getZone() async {
    
    try{
      setState(() {
        _isLoading = true;
      });
      _zones = await LocationHelper.getZones();

      setState(() {
        _isLoading = false;
      });

    }
    catch(error){
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('No Internet Connection!'),
            content: Text('Please check your Internet Connectivity'),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/');
                },
              child: Text('Okay'))
            ],
          );
        }   
      );
    }

  }

  //get the State infromation from server
  Future<void> getState(String zoneName) async {
    
    try{
      setState(() {
        _isLoading = true;
      });
      _states = await LocationHelper.getStates(zoneName);
      setState(() {
        _isLoading = false;
      });
    }
    catch(error){
      setState(() {
        _isLoading=false;
      });
      _showErrorDialog("Internet Connection Problem!","Please check your Internet Connectivity.");
    }
    
  }

  //save the from details
  Future<void> _saveForm() async {
    final isValid = _formKey.currentState.validate();
    if (!isValid) {
      return;
    }
    _formKey.currentState.save();
    
    try{
      setState(() {
        _isLoading = true;
      });
      //add the product to the database use internet connectivity
      var response=await UserHelper.registerNewUser(_initValues);

      if(response){
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(ResponseError.Success),
              content: Text(ResponseError.SucessSubMsg),
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/');
                  },
                child: Text('Okay'))
              ],
            );
          }
        );
      }
      setState(() {
        _isLoading = false;
      });


    }
    catch(error){
      setState(() {
        _isLoading=false;
      });
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => AlertDialog(
          title: Text("Internet Connection Problem!"),
          content: Text("Please check your Internet Connectivity."),
          actions: [
            FlatButton(
              onPressed:(){
                _saveForm();
                Navigator.of(context).pop();
              }, 
              child: Text('Try Again')
            ),
            FlatButton(
              onPressed: ()=>Navigator.of(context).pop(), 
              child: Text('Okay')
            )
          ],
        ),
      );
    }
    
    
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: _isLoading,
      child: Stack(
        children: <Widget>[
          if (_isLoading)
            Align(
              child: CircularProgressIndicator(),
              alignment: Alignment.center,
            ),
          SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      decoration: InputDecoration(labelText: 'First Name'),
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please provide the First Name.';
                        }
                        return null;
                        //return null means no error
                      },
                      onSaved: (value) {
                        _initValues[UserUtils.FirstName] = value;
                      },
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_lastNameFocusNode);
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Last Name'),
                      keyboardType: TextInputType.text,
                      focusNode: _lastNameFocusNode,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please provide the Last Name.';
                        }
                        return null;
                        //return null means no error
                      },
                      onSaved: (value) {
                        _initValues[UserUtils.LastName] = value;
                      },
                      onFieldSubmitted: (value) {
                        FocusScope.of(context).requestFocus(_mobileFocusMode);
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Mobile Number'),
                      keyboardType: TextInputType.phone,
                      focusNode: _mobileFocusMode,
                      maxLength: 10,
                      controller: mobileNumberController,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please provide the Mobile Number.';
                        }
                        if (value.length != 10) {
                          return 'Please check your Mobile Number.';
                        }
                        return null;
                        //return null means no error
                      },
                      onSaved: (value) async {
                        _initValues[UserUtils.MobileNo] = value;
                      },
                      onFieldSubmitted: (value) async {
                          FocusScope.of(context).requestFocus(_emailIDFocusNode);
                      }
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Email-ID'),
                      keyboardType: TextInputType.emailAddress,
                      focusNode: _emailIDFocusNode,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please provide the Email ID.';
                        }
                        if (!value.contains('@')) {
                          return 'Please check your Email ID';
                        }
                        return null;
                        //return null means no error
                      },
                      onSaved: (value) {
                        _initValues[UserUtils.EmailID] = value;
                      },
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_shopNameFocusNode);
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Shop Name'),
                      keyboardType: TextInputType.text,
                      focusNode: _shopNameFocusNode,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please provide the Shop Name.';
                        }
                        return null;
                        //return null means no error
                      },
                      onSaved: (value) {
                        _initValues[UserUtils.ShopName] = value;
                      },
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_shopAddFocusNode);
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Shop Address'),
                      keyboardType: TextInputType.text,
                      focusNode: _shopAddFocusNode,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please provide the Shop Address.';
                        }
                        return null;
                        //return null means no error
                      },
                      onSaved: (value) {
                        _initValues[UserUtils.ShopAddress] = value;
                      },
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_shopLandMarkFocusNode);
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Landmark'),
                      keyboardType: TextInputType.text,
                      focusNode: _shopLandMarkFocusNode,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please provide the Landmark.';
                        }
                        return null;
                        //return null means no error
                      },
                      onSaved: (value) {
                        _initValues[UserUtils.ShopLandMark] = value;
                      },
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_shopCityNameFocusNode);
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'City Name'),
                      keyboardType: TextInputType.text,
                      focusNode: _shopCityNameFocusNode,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please provide the City Name.';
                        }
                        return null;
                        //return null means no error
                      },
                      onSaved: (value) {
                        _initValues[UserUtils.ShopCityName] = value;
                      },
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_shopPinCodeFocusNode);
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Pin Code'),
                      keyboardType: TextInputType.number,
                      focusNode: _shopPinCodeFocusNode,
                      maxLength: 6,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please provide the Pincode.';
                        }
                        if (value.length != 6) {
                          return 'Please check the Pincode.';
                        }
                        return null;
                        //return null means no error
                      },
                      onSaved: (value) {
                        _initValues[UserUtils.ShopPincode] = value;
                      },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    FormField(
                      validator: (value) {
                        if (value == null) {
                          return "Select your Zone";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _initValues[UserUtils.ShopZone] = value;
                      },
                      builder: (
                        FormFieldState<String> state,
                      ) =>
                          Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          InputDecorator(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0)),
                              labelText: 'Zone',
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                hint: Text("Select Zone"),
                                value: dropDownOfZoneValue,
                                isDense: true,
                                onChanged: (newValue) {
                                  state.didChange(newValue);
                                  setState(() {
                                    dropDownOfZoneValue = newValue;
                                    if (dropDownOfStateValue != null) {
                                      dropDownOfStateValue = null;
                                    }
                                    getState(dropDownOfZoneValue);
                                  });
                                },
                                items: _zones.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          SizedBox(height: 5.0),
                          Text(
                            state.hasError ? state.errorText : '',
                            style: TextStyle(
                                color: Colors.redAccent.shade700, fontSize: 12.0),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    FormField<String>(
                      validator: (value) {
                        if (value == null) {
                          return "Select your state";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _initValues[UserUtils.ShopState] = value;
                      },
                      builder: (
                        FormFieldState<String> state,
                      ) =>
                          Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          InputDecorator(
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0)),
                                labelText: 'State'),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                hint: dropDownOfZoneValue == null
                                    ? Text('Select zone first')
                                    : Text("Select State"),
                                value: dropDownOfStateValue,
                                isDense: true,
                                onChanged: (newValue) {
                                  state.didChange(newValue);
                                  setState(() {
                                    dropDownOfStateValue = newValue;
                                  });
                                },
                                items: _states.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          SizedBox(height: 5.0),
                          Text(
                            state.hasError ? state.errorText : '',
                            style: TextStyle(
                                color: Colors.redAccent.shade700, fontSize: 12.0),
                          ),
                        ],
                      ),
                    ),
                    RaisedButton(
                      child: Text('Submit'),
                      onPressed: _showSubmit ? _saveForm : null,
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
            ),
          ),
        ],
      ),
    );
  }
}
