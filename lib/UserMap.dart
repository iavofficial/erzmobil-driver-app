import 'package:erzmobil_driver/Constants.dart';
import 'package:erzmobil_driver/debug/Logger.dart';
import 'package:erzmobil_driver/model/Tours.dart';
import 'package:erzmobil_driver/views/TourInfoDetailsView.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:erzmobil_driver/model/User.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class UserMap extends StatefulWidget {
  final Tour currentRoute;
  const UserMap({Key? key, required this.currentRoute}) : super(key: key);

  @override
  _UserMapState createState() => _UserMapState();
}

class _UserMapState extends State<UserMap> {
  static const String osmUrl = 'https://www.openstreetmap.org/copyright/de';

  Timer? _stateTimer;
  List<Marker>? markers;
  TourNode? selectedNode;
  List<LatLng> points = <LatLng>[];

  @override
  void initState() {
    if (widget.currentRoute.nodes != null) {
      selectedNode = widget.currentRoute.nodes![0];
    }
    _convertTourStopsToMarkers();

    super.initState();
  }

  void _convertTourStopsToMarkers() {
    markers = [];
    if (widget.currentRoute.nodes != null) {
      widget.currentRoute.nodes!.forEach((TourNode node) {
        LatLng point = LatLng(node.latitude, node.longitude);
        bool isCurrentNode = selectedNode == node;
        Marker stopMarker = Marker(
          width: isCurrentNode ? 100.0 : 70.0,
          height: isCurrentNode ? 100.0 : 70.0,
          point: point,
          anchorPos: AnchorPos.align(AnchorAlign.center),
          builder: (ctx) => Container(
              child: IconButton(
                  alignment: Alignment.bottomCenter,
                  icon: Image.asset(
                    Strings.assetPathLocationMarker,
                    scale: 1,
                  ),
                  onPressed: () {
                    onMarkerClicked(node);
                  })),
        );

        markers!.add(stopMarker);
      });
    }
  }

  void onMarkerClicked(TourNode node) {
    Logger.info('Marker was clicked: ' + node.toString());
    if (selectedNode != node) {
      setState(() {
        selectedNode = node;
        _convertTourStopsToMarkers();
      });
    }
  }

  @override
  void deactivate() {
    _cancelStateTimer();
    super.deactivate();
  }

  void _cancelStateTimer() {
    if (_stateTimer != null) {
      _stateTimer!.cancel();
      _stateTimer = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[CustomColors.mint, CustomColors.marine])),
        ),
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: Text(AppLocalizations.of(context)!.tourOverview),
      ),
      body: WillPopScope(
          child: Consumer<User>(
              builder: (context, user, child) => _buildWidgets()),
          onWillPop: () async {
            return !User().isProcessing;
          }),
    );
  }

  Widget _buildWidgets() {
    return Column(
      children: [
        _buildMap(),
        TourDetailInfoView(
            currentNode: selectedNode!,
            isStart: widget.currentRoute.nodes![0] == selectedNode,
            isDestination: widget.currentRoute
                    .nodes![widget.currentRoute.nodes!.length - 1] ==
                selectedNode,
            showBottomIcon: false)
      ],
    );
  }

  Widget _buildMap() {
    return Expanded(
      child: Stack(
        children: [
          FlutterMap(
              options: MapOptions(
                  center: LatLng(50.631811, 12.810148),
                  interactiveFlags:
                      InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                  zoom: 13.0,
                  maxZoom: 18.0),
              layers: [
                TileLayerOptions(
                  urlTemplate: 'http://188.34.157.100/tile/{z}/{x}/{y}.png',
                  // For example purposes. It is recommended to use
                  // TileProvider with a caching and retry strategy, like
                  // NetworkTileProvider or CachedNetworkTileProvider
                  tileProvider: NonCachingNetworkTileProvider(),
                ),
                MarkerLayerOptions(markers: markers!),
              ]),
          Align(
            alignment: Alignment.bottomRight,
            child: FlatButton(
              padding: EdgeInsets.fromLTRB(0.0, 15.0, 5.0, 0.0),
              child: Text(
                osmUrl,
                style: CustomTextStyles.bodyBlackBoldSmall,
              ),
              onPressed: () {
                _launchLicenceInfo();
              },
            ),
          ),
        ],
      ),
    );
  }

  _launchLicenceInfo() async {
    if (await canLaunch(osmUrl)) {
      await launch(osmUrl);
    } else {
      throw 'Could not launch $osmUrl';
    }
  }
}
