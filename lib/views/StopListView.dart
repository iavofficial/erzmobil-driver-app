import 'package:flutter/material.dart';
import 'package:erzmobil_driver/model/BusStop.dart';

class StopList extends StatelessWidget {
  const StopList(
      {Key? key, required this.stops, required this.onDestinationSelected})
      : super(key: key);

  final List<BusStop>? stops;

  final ValueChanged<BusStop> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: stops!.length,
      addAutomaticKeepAlives: false,
      itemBuilder: (context, index) {
        return ListTile(
          title: InkWell(
            onTap: () {
              onDestinationSelected(stops![index]);
            },
            child: Text(
              stops![index].name!,
            ),
          ),
        );
      },
    );
  }
}
