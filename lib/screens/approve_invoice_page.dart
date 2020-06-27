import 'package:flutter/material.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

import '../widgets/widgets.dart';
import '../providers/providers.dart';
import '../models/models.dart';

class ApproveInvoicePage extends StatelessWidget {
  static const routeName = '/approve-invoice';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Approve Invoice'),
      ),
      body: InvoiceApprovePage(),
    );
  }
}

class InvoiceApprovePage extends StatefulWidget {
  @override
  _InvoiceApprovePageState createState() => _InvoiceApprovePageState();
}

class _InvoiceApprovePageState extends State<InvoiceApprovePage> {
  DateTime _selectedDate;
  File _pickedImage;
  String dropDownOfCampaignValue;
  var _isLoading=false;
  var _isInit=true;
  List<Campaign> _userCampaigns;
  Campaign _defaultCampaign;
  String _selectedCampCode;
  

  TextEditingController _invoiceNo;
  TextEditingController _remarks;

  Future<void> _datePicker() async {
    DateTime _date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015),
      lastDate: DateTime.now(),
    );

    if (_date == null) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('Please Select Date'),
        duration: Duration(seconds: 3),
      ));
    }

    var _time = await showTimePicker(
        context: context, initialTime: TimeOfDay(hour: 00, minute: 00));

    if (_time == null) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('Please Select Time'),
        duration: Duration(seconds: 3),
      ));
    } else {
      setState(() {
        _selectedDate =
            _date.add(Duration(hours: _time.hour, minutes: _time.minute));
      });
    }
  }

  void _selectImage(File pickedImage) {
    _pickedImage = pickedImage;
  }
   
  Future<void> _saveForm() async {
   
    if(_invoiceNo.text==""){
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('Please provide Invoice No.'),
        duration: Duration(seconds: 3),
      ));
    }
    else if(_selectedDate==null){
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('Please Select the transaction Date.'),
        duration: Duration(seconds: 3),
      ));
    }
    else if(_defaultCampaign.campaignName=="Null" && dropDownOfCampaignValue==null){
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('Please Select the Campaign'),
        duration: Duration(seconds: 3),
      ));
    }
    else if(_pickedImage==null){
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('Please capture the image'),
        duration: Duration(seconds: 3),
      ));
    }

    setState(() {
      _isLoading=true;
    });

    final bytes = _pickedImage.readAsBytesSync();
    String img64 = base64Encode(bytes);
   

    await Provider.of<Invoice>(context,listen: false).saveImage(
      invoiceNo: _invoiceNo.text,
      imageInByte: img64,
    );


    setState(() {
      _isLoading=false;
    });
    
    
  }


  @override
  void initState() {
    _invoiceNo=TextEditingController();
    _remarks=TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _invoiceNo.dispose();
    _remarks.dispose();
    super.dispose();
  }
  

  @override
  void didChangeDependencies() async{
    //in init state this will not work
    if(_isInit){
      setState(() {
        _isLoading=true;
      });
      await Provider.of<Campaigns>(context,listen: false).fetchAndSetCampaigns();
      _userCampaigns= Provider.of<Campaigns>(context,listen: false).userCampaigns;
      _defaultCampaign=Provider.of<Campaigns>(context,listen: false).selectedCampaign;
     
      setState(() {
        _isLoading=false;
      });

      
    }
    _isInit=false;
    super.didChangeDependencies();
  }


  @override
  Widget build(BuildContext context) {
    return _isLoading?Center(child:CircularProgressIndicator()): 
    Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Form(
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Invoice No.',
                      ),
                      controller: _invoiceNo,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Remarks',
                      ),
                      controller: _remarks,
                    ),
                    SizedBox(
                      height: 15,
                    ),
                  
                    Container(
                      width: double.infinity,
                      child: Text(
                        _defaultCampaign
                        .campaignName=="Null"?
                        "Please Select Campaign":
                        "Default Campaign: ${_defaultCampaign.campaignName}",
                        style: TextStyle(color: Colors.blue,),
                      ),
                    ),
                     
                    SizedBox(
                      height: 15,
                    ),
                    _userCampaigns.length==0?Text("You have not added any campaign yet"):
                    FormField<String>(
                      builder: (FormFieldState<String> state,) =>
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            InputDecorator(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0)),
                                labelText: 'Campaign'),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                hint: Text("Select Campaign"),
                                value: dropDownOfCampaignValue,
                                isDense: true,
                                onChanged: (newValue) {
                                  state.didChange(newValue);
                                  setState(() {
                                    dropDownOfCampaignValue = newValue;
                                  });
                                },
                                items:_userCampaigns.
                                  map((Campaign  value) {
                                  return DropdownMenuItem<String>(
                                    value: value.campaignName,
                                    child: Text(value.campaignName),
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
                    
                    OutlineButton(
                      onPressed: () async {
                        await _datePicker();
                      },
                      borderSide:
                          new BorderSide(color: Colors.black, width: 3.0),
                      color: Colors.white,
                      child: _selectedDate == null
                          ? Text('Select Transaction Date & Time')
                          : Text('Selected DateTime: ' +
                              DateFormat.yMMMMd("en_US")
                                  .add_jm()
                                  .format(_selectedDate)),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    ImageInput(_selectImage),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        RaisedButton.icon(
          icon: Icon(Icons.add),
          label: Text('Add Invoice'),
          onPressed: () {
            print("Save this tran to database");
            _saveForm();
          },
          elevation: 0,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          color: Theme.of(context).accentColor,
        ),
      ],
    );
  }
}
