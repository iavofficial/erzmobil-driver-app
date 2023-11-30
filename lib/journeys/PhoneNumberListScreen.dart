import 'package:erzmobil_driver/debug/Logger.dart';
import 'package:erzmobil_driver/model/PhoneNumber.dart';
import 'package:erzmobil_driver/model/PhoneNumberList.dart';
import 'package:erzmobil_driver/model/User.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Constants.dart';

class PhoneNumberListScreen extends StatefulWidget {
  const PhoneNumberListScreen({Key? key, required this.routeID})
      : super(key: key);

  final int routeID;

  @override
  _PhoneNumberListState createState() => _PhoneNumberListState();
}

class _PhoneNumberListState extends State<PhoneNumberListScreen> {
  PhoneNumberList phoneNumberList = PhoneNumberList(null);

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      loadPhoneNumbers();
    });
  }

  void loadPhoneNumbers() async {
    PhoneNumberList phoneNumbers =
        await User().loadPhoneNumbers(widget.routeID);

    setState(() {
      this.phoneNumberList = phoneNumbers;
    });
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
        title: Text(AppLocalizations.of(context)!.detailedJourneys),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back,
            color: CustomColors.backButtonIconColor,
          ),
        ),
      ),
      body: WillPopScope(
        child: Consumer<User>(
            builder: (context, user, child) => _buildWidgets(context)),
        onWillPop: () async {
          return !User().isProgressGetPhoneNumbers;
        },
      ),
    );
  }

  Widget _buildWidgets(BuildContext context) {
    if (User().isProgressGetPhoneNumbers) {
      return _getEmptyOrErrorContainer(context, phoneNumberList);
    } else if (phoneNumberList == null || !phoneNumberList.isSuccessful()) {
      return _getEmptyOrErrorContainer(context, phoneNumberList);
    } else
      return Column(
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(15, 15, 10, 5),
            alignment: Alignment.centerLeft,
            child: Text(AppLocalizations.of(context)!.contactDetails,
                style: CustomTextStyles.bodyBlackBold,
                maxLines: 1,
                softWrap: true,
                overflow: TextOverflow.ellipsis),
          ),
          Divider(
            height: 1,
            thickness: 1,
          ),
          Expanded(
            child: ListView.builder(
                itemCount: phoneNumberList.data.length,
                itemBuilder: (BuildContext context, int index) {
                  PhoneNumber phoneNumber = phoneNumberList.data[index];
                  return _getPhoneNumberView(phoneNumber.number);
                }),
          ),
        ],
      );
  }

  Widget _getEmptyOrErrorContainer(BuildContext context, PhoneNumberList list) {
    if (User().isProgressGetPhoneNumbers) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(AppLocalizations.of(context)!.loadPhoneNumbers),
            Padding(padding: EdgeInsets.all(5)),
            CircularProgressIndicator(),
          ],
        ),
      );
    }
    if (list.isSuccessful() && list.data.isEmpty) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
        margin: EdgeInsets.all(10),
        child: Text(
          AppLocalizations.of(context)!.noData,
          textAlign: TextAlign.center,
        ),
      );
    } else if (!list.isSuccessful() &&
        list.getErrorMessage(context).isNotEmpty) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
        margin: EdgeInsets.all(10),
        child: Text(
          list.getErrorMessage(context),
          textAlign: TextAlign.center,
        ),
      );
    } else {
      return Container(
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
        margin: EdgeInsets.all(10),
        child: Text(
          AppLocalizations.of(context)!
              .generalErrorMessageNoData(list.getResponseCode().toString()),
          textAlign: TextAlign.center,
        ),
      );
    }
  }

  Widget _getPhoneNumberView(String phoneNumber) {
    return Column(children: [
      InkWell(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30, 10, 20, 10),
          child: SizedBox(
            height: 30,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  phoneNumber,
                  style: CustomTextStyles.bodyBlack,
                  maxLines: 1,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                ),
                /*Icon(
                  Icons.call,
                  size: 30,
                ),*/
              ],
            ),
          ),
        ),
        onTap: () => _callCustomer(phoneNumber),
      ),
      const Divider(
        height: 1,
        thickness: 1,
      ),
    ]);
  }

  void _callCustomer(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunch(launchUri.toString())) {
      await launch(launchUri.toString());
    } else {
      Logger.info('Could not launch $phoneNumber');
    }
  }
}
