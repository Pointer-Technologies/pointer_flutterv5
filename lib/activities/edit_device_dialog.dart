import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../app_localizations.dart';
import '../classes/Device.dart';
import '../components/input_text_field.dart';

import '../constants.dart' as Constants;


/// enum of the icon color,
/// used for easier function of the radio list tiles.
/// Binds the color list with an integer.
enum iconColorList {
  transparent,    // 0
  blue,           // 1
  red,            // 2
  green,          // 3
  yellow          // 4
}

enum iconList {
  devices,      // 0
  car,          // 1
  motorcycle,
  bike,
  scooter,
  tv,
  key,
  iphone,
  android,
  tablet,
  pet,
  people,
  wallet,
  remote      // 13
}

/// Standard stuff, a dialog presented as a Scaffold,
/// to be presented fullscreen.
/// Works like "Add Device" and "Setup".
// ignore: must_be_immutable
class EditDeviceDialog extends StatefulWidget {
  EditDeviceDialog({Key key}) : super(key: key);

  /// The position of the item to be edited.
  int position;
  /// The device to be setup.
  Device device;
  /// The controller used for the new device name.
  final nameController = TextEditingController();
  /// The integer keeping the position of the selected new icon.
  int selected;

  EditDeviceDialog.n({Key key, int position, Device device}) : super(key: key){
    this.position = position;
    this.device = device;
    nameController.text = device.name;
  }


  @override
  State<StatefulWidget> createState() {
    return _EditDeviceDialogState();
  }
}

class _EditDeviceDialogState extends State<EditDeviceDialog> {

  /// The color and icon values and codes.
  /// Kept null to be changed by a setState() function later on.
  /// Default values are directly drawn by the device passed on to the activity.
  iconColorList _iconColor;
  int _iconColorCode;
  iconList _icon;
  int _iconCode;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate("EDIT_DEVICE")),
        elevation: 0,
      ),

      /// Wrapped in a SingleChildScrollView to remain scrollable.
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              SizedBox(height: Constants.PARENT_PADDING),

              Text(AppLocalizations.of(context).translate("NEW_DEVICE_NAME"),textAlign: TextAlign.left),

              // New name placeholder.
              InputTextField.n(AppLocalizations.of(context).translate("NEW_DEVICE_NAME"), widget.nameController),
              
              /// --- ICON COLOR SELECTION ---/// 
              // An expansion tile with the icon color radio list.
              // The RadioList works based on the iconColor enum.
              ExpansionTile(
                title: Text(AppLocalizations.of(context).translate("DEVICE_COLOR")),

                onExpansionChanged: (isExpanded) {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
                children: [
                  // Transparent option.
                  RadioListTile<iconColorList>(
                    title: Text(AppLocalizations.of(context).translate("TRANSPARENT")),
                    activeColor: Colors.transparent.withOpacity(1.0),
                    value: iconColorList.transparent,
                    groupValue: (_iconColor == null)
                      ? iconColorList.values.elementAt(widget.device.iconCode ~/ 100)
                      : _iconColor,

                    onChanged:(iconColorList value) {
                      setNewColor(value);
                    }
                  ),

                  // Blue option.
                  RadioListTile<iconColorList>(
                    title: Text(AppLocalizations.of(context).translate("BLUE")),
                    activeColor: Colors.blue,
                    value: iconColorList.blue,
                    groupValue: (_iconColor == null)
                      ? iconColorList.values.elementAt(widget.device.iconCode ~/ 100)
                      : _iconColor,

                    onChanged:(iconColorList value) {
                      setNewColor(value);
                    }
                  ),

                  // Red option.
                  RadioListTile<iconColorList>(
                    title: Text(AppLocalizations.of(context).translate("RED")),
                    activeColor: Colors.red,
                    value: iconColorList.red,
                    groupValue: (_iconColor == null)
                      ? iconColorList.values.elementAt(widget.device.iconCode ~/ 100)
                      : _iconColor,

                    onChanged:(iconColorList value) {
                      setNewColor(value);
                    }
                  ),

                  // Green option.
                  RadioListTile<iconColorList>(
                    title: Text(AppLocalizations.of(context).translate("GREEN")),
                    activeColor: Colors.green,
                    value: iconColorList.green,
                    groupValue: (_iconColor == null)
                      ? iconColorList.values.elementAt(widget.device.iconCode ~/ 100)
                      : _iconColor,

                      onChanged:(iconColorList value) {
                      setNewColor(value);
                    }
                  ),

                  // Yellow option.
                  RadioListTile<iconColorList>(
                    title: Text(AppLocalizations.of(context).translate("YELLOW")),
                    activeColor: Colors.yellow,
                    value: iconColorList.yellow,
                    groupValue: (_iconColor == null)
                      ? iconColorList.values.elementAt(widget.device.iconCode ~/ 100)
                      : _iconColor,

                    onChanged:(iconColorList value) {
                      setNewColor(value);
                    }
                  ),
                ],
              ),

              /// --- ICON SELECTION --- ///
              /// Consists of a grid in the form of rows,
              /// containing gesture detectors with each
              /// of the available device icons.

              // First row of the layout: devices, car, motorcycle, bike.
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                children: [
                  IconDetector(Icons.devices_outlined, size.width/4-5, 0),
                  IconDetector(Icons.directions_car_outlined, size.width/4-5, 1),
                  IconDetector(Icons.motorcycle_outlined, size.width/4-5, 2),
                  IconDetector(Icons.directions_bike_outlined, size.width/4-5, 3),
                ],
              ),

              // Second row: scooter, tv, key, iphone.
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                children: [
                  IconDetector(Icons.electric_scooter_outlined, size.width/4-5, 4),
                  IconDetector(Icons.tv_outlined, size.width/4-5, 5),
                  IconDetector(Icons.vpn_key_outlined, size.width/4-5, 6),
                  IconDetector(Icons.phone_iphone_outlined, size.width/4-5, 7),
                ],
              ),

              // Third row: android, tablet, pet, people.
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                children: [
                  IconDetector(Icons.android, size.width/4-5, 8),
                  IconDetector(Icons.tablet_outlined, size.width/4-5, 9),
                  IconDetector(Icons.pets_outlined, size.width/4-5, 10),
                  IconDetector(Icons.emoji_people_outlined, size.width/4-5, 11),
                ],
              ),

              // Fourth row: wallet, remote
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                children: [
                  IconDetector(Icons.account_balance_wallet_outlined, size.width/4-10, 12),
                  IconDetector(Icons.settings_remote_outlined, size.width/4-10,13),

                ],
              ),

              SizedBox(height: 30),

              RaisedButton(
                color: Constants.ACCENT_COLOR,
                child: Text(AppLocalizations.of(context).translate("EDIT")),
                onPressed: () async {
                    /// Use the encoding conversion described in the Device class,
                    /// if the user has made any changes to the name and icon,
                    /// and as long as these changes are valid.
                    await update(
                        position: widget.position,
                        name: checkName()
                            ? widget.nameController.text
                            : widget.device.name,
                        code: widget.device.id,
                        icon: correctImage()
                    );

                    Navigator.pop(context);
                  }

              )
            ], // (Column)
          ),
        ),
      ),
    );
  }


  /// The decoration used to signify which icon is currently selected.
  BoxDecoration boxDecoration(int selected,int position){
    if(selected == position) {
      return BoxDecoration(
        border: Border.all(
          color: Colors.cyan,
          width: 4),
      );
    }
    else
      return null;
  }


  /// A new gesture detector filled with each of the available device icons.
  /// @Param:
  /// position: The position of the icon in the grid. Used for the _iconCode.
  // ignore: non_constant_identifier_names
  GestureDetector IconDetector(IconData icon, double size, int position){
    return GestureDetector(
      child: Container(

        // Show which device is selected.
        decoration: boxDecoration(widget.selected, position),

        child: Icon(
          icon,
          size: size,
        )
      ),

      onTap: () {
        setNewIcon(iconList.values.elementAt(position));
        Fluttertoast.showToast(msg: (widget.selected).toString());
      },

      /// KEPT HERE IN CASE THE "NEW" METHOD TURNS OUT TO BE SHIT.
      
      // onTap: () {
      //   if(widget.selected == -1) {
      //     setState(() {
      //       widget.selected = position;
      //     });
      //
      //     setNewIcon(iconList.values.elementAt(widget.selected));
      //   }
      //
      //   else if(widget.selected == position) {
      //     setState(() {
      //       widget.selected = -1;
      //     });
      //
      //     setNewIcon(iconList.values.elementAt(position));
      //   }
      //
      //   else {
      //     setState(() {
      //       widget.selected = position;
      //     });
      //
      //     setNewIcon(iconList.values.elementAt(widget.selected));
      //   }
      // },

    );
  }

  /// Get an iconColorList item and use its index in the enum.
  /// This will be used to store the iconCode on Firebase,
  /// in the form of an easily stored integer.
  Future<void> setNewColor(iconColorList iconColor) {
    setState(() {
      _iconColor = iconColor;
      _iconColorCode = iconColorList.values.indexOf(iconColor);
    });

    return Future.value();
  }


  /// Do the same with the device icon.
  /// Also change value in "selected" to show the new device icon.
  Future<void> setNewIcon(iconList icon) {
    setState(() {
      _icon = icon;
      _iconCode = iconList.values.indexOf(icon);
      widget.selected = _iconCode;
    });

    return Future.value();
  }


  getData() async {
    FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser.uid).collection("devices").snapshots().listen((event) {
      Fluttertoast.showToast(msg: "Reached");
    });
  }


  /// Updates the device database after any change has been made.
  update({int position, String name, String code, int icon}) async{
    CollectionReference collectionReference = FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser.uid).collection("devices");

    QuerySnapshot querySnapshot = await collectionReference.get();
    await querySnapshot.docs[position].reference.update({"name": name, "8-digit code": code, "icon": icon});
    Fluttertoast.showToast(msg: "Device successfully updated.");
  }


  /// Checks the new name for length or availability.
  bool checkName() {
    if(widget.nameController.text == widget.device.name){
      return false;
    }
    if(widget.nameController.text.length >= 3 && widget.nameController.text.length <= 20/*&& !nameAlreadyExists()*/)
      return true;
    else if(widget.nameController.text.length <3 || widget.nameController.text.length > 20)
      Fluttertoast.showToast(msg: "Device's name must be between 3 and 20 characters long.");
    return false;
  }

  /// Checks if a new icon or color has been chosen.
  /// If one or both of the properties is missing,
  /// it is filled with the old one.
  int correctImage() {
    if(widget.selected == null)
      _iconCode = widget.device.iconCode % 100;

    if(_iconColorCode == null)
      _iconColorCode = widget.device.iconCode ~/ 100;

    return _iconColorCode * 100 + _iconCode;
  }
}