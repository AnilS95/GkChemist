import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/providers.dart';
import '../widgets/widgets.dart';




class AddCampaignPage extends StatefulWidget {

  static const routeName = '/add-campaign';

  @override
  _AddCampaignPageState createState() => _AddCampaignPageState();
}

class _AddCampaignPageState extends State<AddCampaignPage> {


  var _isInit=true;
  var _isLoading=false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
 

  @override
  void didChangeDependencies() async{
    //in init state this will not work
    if(_isInit){
      setState(() {
        _isLoading=true;
      });

      await Provider.of<Campaigns>(context,listen: false).fetchAndSetCampaigns();
      //_campaigns=Provider.of<Campaigns>(context,listen: false).userCampaigns;
      await Provider.of<Campaigns>(context,listen: false).fetchAndSetCampaigns();
      setState(() {
        _isLoading=false;
      });

      
    }
    _isInit=false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Campaigns'),
        actions: [
          IconButton(
            icon: Icon(Icons.add), 
            onPressed: ()async{
              print("Add new campaign here");

              final String campCode=await _campCodeInputDialog(context);
              print(campCode);
              setState(() {
                _isLoading=true;
              });
              var result=await Provider.of<Campaigns>(context,listen: false).addNewCamp(campCode);
              setState(() {
                _isLoading=false;
              });
              if(result==false){
                _scaffoldKey.currentState.showSnackBar(
                  SnackBar(content: Text("Please check the campaign code and try again."))
                );
              }
              else if(result==true){
                 _scaffoldKey.currentState.showSnackBar(
                  SnackBar(content: Text("Campaign Added Successfully ✔"))
                );

              }
              
            
            }
          ) 
        ],
      ),
      body: _isLoading?Center(child: CircularProgressIndicator()): 
      Container(
        child:Column(
          crossAxisAlignment: CrossAxisAlignment.center,

          children: [
            Align(
              alignment: Alignment.center,
              child: Card(
                margin: EdgeInsets.all(20),
                color: Colors.amber,
                child:Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Consumer<Campaigns>(
                    builder: (context, value, child) => Text(
                      'Default Campaign: ${value.selectedCampaign.campaignName}',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.bold
                      ),
                    ),   
                  ),
                ),  
              ),
            ),
            RaisedButton(
              child: Consumer<Campaigns>(
                builder: (context, value, child) =>value.selectedCampaign.campaignName=="Null"?
                Text("Select Default Campaign"):Text("Change Default Campaign"),
              ),
              onPressed: (){
                var _camps=Provider.of<Campaigns>(context,listen: false).userCampaigns;


                _scaffoldKey.currentState
                .showBottomSheet((context) =>Container(
                  
                  height: MediaQuery.of(context).size.height*0.6,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.blue[200],
                    border: Border.all(
                      color: Colors.blue,
                      width: 0.0
                    ),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20.0),
                      topLeft: Radius.circular(20.0),
                      bottomRight: Radius.circular(0.0),
                      bottomLeft: Radius.circular(0.0),
                    ),
                  ),
                  child:Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.all(10),
                          width: 50,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            border: Border.all(
                              width:3
                            ),
                            borderRadius: BorderRadius.all(
                                Radius.circular(10.0) 
                            ),
                          ),
                        ),

                        Expanded(
                          child: _camps.length==0?Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              "No one campaign is added yet. Press + button in AppBar in order to add new campaign",
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontSize: 15
                              ),
                            
                            ),
                          ):
                          ListView.builder(
                            itemBuilder: (context, index) => Card(
                              margin: const EdgeInsets.all(10),
                              child: ListTile(
                                title: Text(_camps[index].campaignName),
                                onTap: () async { 
                                  await Provider.of<Campaigns>(context,listen: false).setSelectedCampaign(_camps[index]);
                                  Navigator.of(context).pop();
                                },
                              ),
                            ),
                            itemCount: _camps.length,
                          ),
                        ),
                      
                      ],
                    )
                  
                ));

              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding:
                  EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
              color: Theme.of(context).primaryColor,
              textColor: Theme.of(context).primaryTextTheme.button.color,
            ),

            Container(
              padding: const EdgeInsets.all(15.0),
              margin: const EdgeInsets.all(15.0),
              child: Text(
                'List of Added Campaigns',
                style: TextStyle(
                  fontSize: 20,
                 
                  color: Colors.blue,
                ),
              ),
            ),
            Expanded(child: CampaignList()),

          ],
        ),
      ),      
    );
  }


  Future<String> _campCodeInputDialog(BuildContext context) async {
    String campCode = '';
    return showDialog<String>(
      context: context,
      barrierDismissible: false, // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Campaign Code: '),
          content: new Row(
            children: <Widget>[
              new Expanded(
                  child: new TextField(
                autofocus: true,
                decoration: new InputDecoration(hintText: 'eg. PDHYXXXX'),
                onChanged: (value) {
                  campCode = value;
                },
              ))
            ],
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Add'),
              onPressed: () {
                Navigator.of(context).pop(campCode);
              },
            ),
          ],
        );
      },
    );
  }

}



