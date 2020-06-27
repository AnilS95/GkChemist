import 'package:flutter/material.dart';

import '../models/models.dart';
class CampaignCard extends StatelessWidget {

  final Campaign c1;

  CampaignCard(this.c1);
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(c1.campaignName),
      subtitle: Text(c1.campaignCorpName),
    );
  }
}