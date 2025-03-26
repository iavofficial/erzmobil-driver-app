import 'package:flutter/material.dart';
import 'package:erzmobil_driver/Constants.dart';

import 'ViewPager.dart';

class HeatStory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<StoryData> _data = <StoryData>[
      StoryData('StoryHeadline1', 'StoryText1'),
      StoryData('StoryHeadline2', 'StoryText2'),
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: Text('StoryTitle'),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back,
            color: CustomColors.backButtonIconColor,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.copyright_outlined,
            ),
            onPressed: () {
              /*Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) =>
                      new ConsentOverviewScreen()));*/
            },
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
            alignment: Alignment.topCenter,
            child: Icon(
              Icons.directions_bus_outlined,
            ),
          ),
          Flexible(
            flex: 1,
            child: Container(
              margin: EdgeInsets.fromLTRB(0, 0, 0, 20.0),
              alignment: Alignment.bottomCenter,
              child: ViewPager(
                data: _data,
              ),
            ),
          )
        ],
      ),
    );
  }
}
