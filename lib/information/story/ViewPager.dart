import 'package:flutter/material.dart';
import 'package:erzmobil_driver/Constants.dart';

import 'Indicator.dart';

class StoryData {
  final String title;
  final String description;

  StoryData(this.title, this.description);
}

class ViewPager extends StatefulWidget {
  final List<StoryData>? data;

  ViewPager({Key? key, @required this.data}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ViewPagerState();
  }
}

class ViewPagerState extends State<ViewPager> {
  final PageController controller = PageController();

  void _pageChanged(int index) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Flexible(
            flex: 1,
            child: Container(
              margin: EdgeInsets.fromLTRB(0, 0, 0, 5.0),
              child: PageView.builder(
                onPageChanged: _pageChanged,
                controller: controller,
                itemCount: widget.data!.length,
                itemBuilder: (context, index) {
                  StoryData storyData = widget.data!.elementAt(index);
                  return _buildStaticContentFor(
                      storyData.title, storyData.description);
                },
              ),
            )),
        Indicator(
          controller: controller,
          itemCount: widget.data!.length,
        ),
      ],
    );
  }

  Widget _buildStaticContentFor(String title, String text) => Container(
        margin: EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
        decoration: BoxDecoration(
          border: Border.all(width: 10, color: CustomColors.orange),
          borderRadius: const BorderRadius.all(const Radius.circular(8)),
          color: CustomColors.orange,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(10.0),
                child: Text(title, style: CustomTextStyles.headlineWhite),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(10.0, 0, 10.0, 10.0),
                child: Text(text, style: CustomTextStyles.bodyBlack),
              )
            ],
          ),
        ),
      );
}
