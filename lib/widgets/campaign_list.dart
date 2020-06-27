import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/providers.dart';
import './campaign_card.dart';


class CampaignList extends StatefulWidget {
  @override
  _CampaignListState createState() => _CampaignListState();
}

class _CampaignListState extends State<CampaignList> {
  var _campaigns=[];
  @override
  Widget build(BuildContext context) {

    _campaigns=Provider.of<Campaigns>(context).userCampaigns;
    return _campaigns.length==0?Padding(
      padding: const EdgeInsets.all(20.0),
      child: Text(
        "No one campaign is added yet. Press + button in AppBar in order to add new campaign",
        style: TextStyle(
          color: Colors.redAccent,
          fontSize: 15
        ),
      
      ),
    )
    :ListView.builder(
      itemBuilder: (context, index) => CampaignCard(_campaigns[index]),
      itemCount: _campaigns.length,
    );
  }
}