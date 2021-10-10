import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:app_settings/app_settings.dart';

import '../activities/setup_activity.dart';
import '../activities/add_device_dialog.dart';
import '../app_localizations.dart';
import '../classes/Device.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../activities/edit_device_dialog.dart';
import '../main.dart';

import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

import 'package:pointer_flutter/constants.dart' as Constants;


/// The main activity of the app.
class AppCenterActivity extends StatefulWidget {

  bool nightMode = false;
  List<Device> devices = new List<Device>();
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  @override
  State<StatefulWidget> createState() {
    return _AppCenterActivityState();
  }

}

class _AppCenterActivityState extends State<AppCenterActivity> {

  /// The initial data stream of the device table.
  Stream<QuerySnapshot> _initStream;

  /// Sets the brightness mode, taken from SharedPreferences.
  void setMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    widget.nightMode = prefs.getBool("light");
    if(widget.nightMode == null)
      widget.nightMode = false;
  }


  /// Makes the initialisations when the activity is first created.
  @override
  void initState() {
    super.initState();

    // Set the brightness mode.
    setMode();

    // Initialize the device list.
    _initStream = FirebaseFirestore
      .instance
      .collection("users")
      .doc(FirebaseAuth.instance.currentUser.uid)
      .collection("devices")
      .snapshots();
  }


  @override
  Widget build(BuildContext context) {
    // Screen size.
    Size size = MediaQuery.of(context).size;

    /// Wrapped in a WillPopScope to manage the event of pressing the back button.
    /// The _onBackPressed method informs the user that a second tap
    /// of the back button invokes the Sign out dialog.
    return WillPopScope(
      onWillPop: _onBackPressed,

      child: Scaffold(
        // Set the task bar invisible.
        // Add the night mode, sign out and help icons.
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: null,

          // Disable the taskbar back button.
          automaticallyImplyLeading: false,

          actions: [
            // Night mode-light mode switch.
            Padding(
              padding: EdgeInsets.only(right: 20),

              /// Initialize the model to make the theme change global,
              /// and notify the MyApp class.
              child: ScopedModelDescendant<AppModel>(
                builder: (context, child, model) {
                  return GestureDetector(
                    child: (widget.nightMode)
                      ? Icon(Icons.nights_stay_outlined)
                      : Icon(Icons.wb_sunny_outlined),

                    onTap: () async {
                      // Notify the shared preferences class.
                      final SharedPreferences prefs = await SharedPreferences.getInstance();
                      // Fluttertoast.showToast(msg: "Mode night? " + widget.nightMode.toString());

                      setState(() {
                        model.toggleMode();
                        widget.nightMode = !widget.nightMode;
                        prefs.setBool("light", widget.nightMode);
                      });
                    },
                  );
                },
              ),
            ),

            // The help dialog.
            // Padding(
            //   padding: EdgeInsets.only(right: 20),
            //   child: GestureDetector(
            //     child:Icon(Icons.help_outline_outlined),

            //     onTap:(){
            //       // The help dialog.
            //     }
            //   )
            // ),

            // Sign out button.
            Padding(
              padding: EdgeInsets.only(right: 20),
              child: GestureDetector(
                child: Icon(Icons.login_outlined),

                // Build the sign out dialog.
                onTap: _askedToSignOut,
              )
            ),
          ], 
        ),

        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 20),
              height: size.height * 0.25,

              child: Stack(
                children: [
                  // Shade effect.
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(30),
                        bottomLeft: Radius.circular(30)
                      ),

                      boxShadow: [
                        BoxShadow(
                          color: Constants.SHADOW_COLOR.withOpacity(0.2),
                          offset: Offset(0, 50),
                          blurRadius: 40,
                        ),
                      ]
                    ),
                  ),

                  // Profile picture, rounded and attached to the side of the screen.
                  // Left out to simplify the design.
                  /*
                  Positioned(
                    height: size.width * 0.5,
                    width: size.width * 0.5,
                    // Keep the picture on the bottom left,
                    // cutting out a piece of that corner.
                    top: size.height * 0.03,
                    right: size.width * 0.5 + 20,

                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: size.width * 0.5,
                        maxWidth: size.width * 0.5
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(65),

                        child: Image.asset(
                          'assets/images/tester_pic.jpg',
                          fit: BoxFit.fill,

                        ),
                      ),
                    ),
                  ),
                   */

                  Positioned(
                    // Offset from the top by 10% of the total height.
                    top: size.height * 0.10,
                    right: 0,
                    left: 0,

                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: Constants.PARENT_PADDING),

                      child: RichText(
                        text: TextSpan(
                          text: AppLocalizations.of(context).translate("WELCOME") + FirebaseAuth.instance.currentUser.displayName + AppLocalizations.of(context).translate("GREETINGS"),
                          style: TextStyle(
                            fontSize: 30,
                          )
                        ),
                        softWrap: true,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// The devices ListView.
            /// Put in a flexible widget to render properly
            /// and remain scrollable.
            Flexible(
              child: StreamBuilder(
                stream: _initStream,
                builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot){

                  // Display a spinning indicator if the data hasn't loaded yet.
                  if(!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  // Get the database device collection.
                  // Get it again if it hasn't loaded.
                  List documents = snapshot.data.docs;

                  int docsLength = documents.length;
                  bool needsUpdate = false;
                  int sameElements = 0;

                  // Initialize the list if it's null,
                  // or if the list length has changed.
                  if(widget.devices == null || widget.devices.length != docsLength) {

                    // Set the length expilicitly to avoid a null exception.
                    widget.devices = List<Device>(docsLength);

                    for(int i = 0 ; i < docsLength ; i++)
                      widget.devices[i] = new Device(
                        name: documents[i]["name"],
                        id: documents[i]["8-digit code"],
                        iconCode: documents[i]["icon"]
                      );
                  }

                  // Check if the list needs updating,
                  // by counting how many objects are identical.
                  for(int check = 0 ; check < widget.devices.length ; check++) {
                    if (widget.devices[check].name == documents[check]["name"]
                    && widget.devices[check].id == documents[check]["8-digit code"]
                    && widget.devices[check].iconCode == documents[check]["icon"])
                    {
                      sameElements++;
                    }
                  }

                  /// If the lists match, do nothing.
                  /// Otherwise, clear everything and re-initialize it.
                  if(sameElements == docsLength){
                  } else{
                    widget.devices = List<Device>(docsLength);
                    for (int i = 0 ; i < docsLength ; i++) {
                      widget.devices[i] = new Device(
                        name: documents[i]["name"],
                        id: documents[i]["8-digit code"],
                        iconCode: documents[i]["icon"]
                      );
                    }
                  }

                  /// A list of expansion panels put inside
                  /// a SingleChildScrollView to remain scrollable
                  /// and maintain infinite size.
                  return new SingleChildScrollView(
                    child: ExpansionPanelList(
                      animationDuration: Duration(milliseconds: 450),

                      // The function used to expand each item when it's pressed.
                      expansionCallback: (int index, bool isExpanded) {
                        setState(() {
                          widget.devices[index].isExpanded = !widget.devices[index].isExpanded;
                        });
                      },

                      // Add a padding to the header when the panel is expanded.
                      expandedHeaderPadding: EdgeInsets.symmetric(horizontal: Constants.PARENT_PADDING),
                      dividerColor: Constants.ACCENT_COLOR,

                      children:
                      // Map the devices list to a listView.
                      widget.devices.map((Device device) {
                        return ExpansionPanel(
                          canTapOnHeader: true,
                          headerBuilder: (BuildContext context, bool isExpanded) {
                            /*
                            return Dismissible(
                            key: Key(device.id),
                            background: Container(color: Colors.blue,
                              child: Icon(Icons.wifi_protected_setup_outlined),),
                            secondaryBackground: Container(
                              color: Colors.red,
                              child: Icon(Icons.delete_outline_outlined),
                            ),
                               onDismissed: (_direction){
                                if(_direction==DismissDirection.endToStart){
                                  _askedToDelete(widget.devices.indexOf(device));
                                }
                                else if(_direction==DismissDirection.startToEnd){
                                  Fluttertoast.showToast(msg: widget.devices.where((currentDevice) => currentDevice == device ).toString());
                                  _askedToSetup(widget.devices.indexOf(device));
                                }
                               },
                             */

                              return GestureDetector(
                              // Opens the setup full-screen dialog.
                                onDoubleTap:() {
                                  Fluttertoast.showToast(msg: widget.devices.where((currentDevice) => currentDevice == device ).toString());
                                  _askedToSetup(widget.devices.indexOf(device));
                                },

                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: Constants.PARENT_PADDING),

                                  // What appears before the panel is expanded.
                                  child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    // The device icon.
                                    device.icon,

                                    // Device name.
                                    Text(
                                      device.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20
                                      ),
                                    ),

                                    // Device ID.
                                    Text(
                                      device.iconCode.toString(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w300
                                      ),
                                    )
                                  ],  // Children (Row before the expansion)
                                ),
                              ),
                            );
                          },

                          isExpanded: device.isExpanded,

                          // What appears on the expanded view.
                          body: Container(
                            height: 150,
                            padding: EdgeInsets.all(Constants.PARENT_PADDING / 2),

                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                              children: [
                                // First row of the expanded ListView layout.
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Edit button.
                                    Padding(
                                      padding: EdgeInsets.all(5.0),
                                      child: GestureDetector(

                                        child: Row(
                                          children:[
                                            Icon(
                                              Icons.edit_outlined,
                                              color: Colors.blue
                                            ),
                                            Text(AppLocalizations.of(context).translate("EDIT"))
                                            ]
                                          ),

                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute<void>(
                                              builder: (BuildContext context) =>
                                                EditDeviceDialog.n(
                                                  position: widget.devices.indexOf(device),
                                                  device: device
                                                ),

                                            fullscreenDialog: true,
                                            )
                                          );
                                      },
                                      )
                                    ),

                                    // Location button.
                                    Padding(
                                      padding: EdgeInsets.all(5.0),
                                      child: GestureDetector(
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.location_on_outlined,
                                              color: Colors.green
                                            ),
                                            Text(AppLocalizations.of(context).translate("LOCATION"))
                                          ],
                                        ),
                                        onTap: _askedToSignOut,
                                      )
                                    ),

                                    // Delete button.
                                    Padding(
                                      padding: EdgeInsets.all(5.0),
                                      child: GestureDetector(
                                        child: Row(
                                          children:[
                                            Icon(
                                              Icons.delete_outline_rounded,
                                              color: Colors.red
                                            ),

                                            Text(AppLocalizations.of(context).translate("DELETE"))
                                          ],
                                        ),

                                      /// Prompt the delete dialog, providing it with the position
                                      /// of the item to be deleted.
                                      onTap: () {
                                        _askedToDelete(widget.devices.indexOf(device));
                                      }
                                      ),
                                    )
                                  ], // Children (first row)
                                ),

                                // Second row of the layout.
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                                  children: [
                                    // Sound switch.
                                    Padding(
                                      padding: EdgeInsets.all(5.0),
                                      child: Row(
                                        children: [
                                          Switch(
                                            onChanged:(bool isActive) {
                                              if(isActive) {
                                                /// Fetch the data from the "Sound on" option.
                                                String soundOnUrl = device.local_IP + '/4/on';
                                                http.get(Uri.parse(soundOnUrl));
                                              }

                                              else {
                                                /// Fetch the data from the "Sound off" option.
                                                String soundOffUrl = device.local_IP + '/4/off';
                                                http.get(Uri.parse(soundOffUrl));
                                              }
                                            },

                                            value: false,
                                            materialTapTargetSize: MaterialTapTargetSize.padded,
                                            dragStartBehavior: DragStartBehavior.start,
                                            activeTrackColor: Constants.ACCENT_COLOR,
                                            activeColor: Constants.ACCENT_COLOR,
                                          ),

                                          Text(AppLocalizations.of(context).translate("SOUND")),
                                        ],
                                      )
                                    ),

                                    // Vibration switch.
                                    Padding(
                                      padding: EdgeInsets.all(5.0),
                                      child: Row(
                                        children: [
                                          Switch(
                                            onChanged:(bool isActive) {
                                              if(isActive) {
                                                /// Fetch the data from the "Vibration on" option.
                                                String vibrationOnUrl = device.local_IP + '/5/on';
                                                http.get(Uri.parse(vibrationOnUrl));
                                              }

                                              else {
                                                /// Fetch the data from the "Vibration off" option.
                                                String vibrationOffUrl = device.local_IP + '/5/off';
                                                http.get(Uri.parse(vibrationOffUrl));
                                              }
                                            },

                                            value: false,
                                            materialTapTargetSize: MaterialTapTargetSize.padded,
                                            dragStartBehavior: DragStartBehavior.start,
                                            activeTrackColor: Constants.ACCENT_COLOR,
                                            activeColor: Constants.ACCENT_COLOR,
                                          ),

                                          Text(AppLocalizations.of(context).translate("VIBRATION")),
                                        ],
                                      )
                                    )
                                  ], // Children (Second row)
                                )
                              ], // Children (Column)
                            )
                          )
                        );
                      }).toList(),
                    ),
                  );
                } // Builder
              ),
            )
          ]
        ),

        // Floating action button used to add a device.
        floatingActionButton: FloatingActionButton(
          backgroundColor: Constants.ACCENT_COLOR,
          splashColor: Colors.grey.withOpacity(0.4),
          elevation: Constants.BUTTON_ELEVATION,
          materialTapTargetSize: MaterialTapTargetSize.padded,
          child: Icon(Icons.add),

          /// Call the "add device" full screen dialog.
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (BuildContext context) => AddDeviceDialog.n(devices:widget.devices),
                fullscreenDialog: true,
              )
            );
          },
        ),
      ),
    );
  }


  /// Deletes a device off the device database.
  delete(int position) async {
    CollectionReference collectionReference = FirebaseFirestore.instance.collection("users")
      .doc(FirebaseAuth.instance.currentUser.uid)
      .collection("devices");

    QuerySnapshot querySnapshot = await collectionReference.get();
    await querySnapshot.docs[position].reference.delete();
    Fluttertoast.showToast(msg: "Device successfully deleted.");
  }


  /// Updates the device database after any change has been made.
  update(int position,String name,String code,int icon) async {
    CollectionReference collectionReference = FirebaseFirestore.instance.collection(FirebaseAuth.instance.currentUser.uid);

    QuerySnapshot querySnapshot = await collectionReference.get();
    await querySnapshot.docs[position].reference.update({"name": name, "8-digit code": code, "icon": icon});
    Fluttertoast.showToast(msg: "Device successfully updated.");

    setState(() {
      widget.devices[position].name = name;
      widget.devices[position].id = code;
      widget.devices[position].iconCode = icon;
    });
  }


  /// Signs the user out.
  Future<void> signOut() async{
    try {
      if (await GoogleSignIn().isSignedIn()) {
        await GoogleSignIn().disconnect();
      }
      await FirebaseAuth.instance.signOut();
    }
    catch(e){
      Fluttertoast.showToast(msg: e.code);
    }
  }


  /// Builds the dialog prompting the user to connect
  /// to the soft Access Point. If they're already connected,
  /// the option to navigate to the Setup Activity is presented.
  /// Creates a switch based on the activity selected.
  /// @Param:
  /// position: The item's position on the device collection.
  /// (Given by the ListView).
  Future<void> _askedToSetup(int position) async {
    switch (await showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(AppLocalizations.of(context).translate("SETUP_DIALOG")),

          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // First option: Navigate to the setup activity.
                SimpleDialogOption(
                  onPressed: () { Navigator.pop(context, "SetupActivity"); },
                  child: Text(
                    AppLocalizations.of(context).translate("CONTINUE"),
                    style: TextStyle(
                      color: Colors.blue
                    ),
                  ),
                ),

                // Second option: WiFi settings.
                SimpleDialogOption(
                  onPressed: () { Navigator.pop(context, "Settings"); },
                  child: Text(
                    AppLocalizations.of(context).translate("WIFI_SETTINGS"),
                    style: TextStyle(
                        color: Colors.blue
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      }
    ))

    // Navigate to the corresponding screen.
    {
      case "SetupActivity":
        Navigator.push(
            context,
            MaterialPageRoute<void>(
                builder: (BuildContext context) => SetupActivity(position: position),
                fullscreenDialog: true
            ));
        break;
      case "Settings":
        AppSettings.openWIFISettings();
        break;
    }
  }
  

  /// Builds the delete dialog.
  /// @Param:
  /// position: The item's position on the device collection.
  /// (Given by the ListView).
  Future<void> _askedToDelete(int position) async {
    switch (await showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          contentPadding: EdgeInsets.all(Constants.PARENT_PADDING),

          title: Text(AppLocalizations.of(context).translate("DELETE_DEVICE")),

          children: <Widget> [
            Text(AppLocalizations.of(context).translate("DELETE_DEVICE_CONFIRM")),

            // Add a bit of padding.
            SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Delete option.
                SimpleDialogOption(
                  child: Text(
                    AppLocalizations.of(context).translate("DELETE"),
                    style: TextStyle(
                      color: Constants.ACCENT_COLOR,
                    ),
                  ),

                  onPressed: () { Navigator.pop(context, "delete"); }
                ),

                // Cancel option.
                SimpleDialogOption(
                  child: Text(
                    AppLocalizations.of(context).translate("CANCEL"),
                    style: TextStyle(
                        color: Colors.blue
                    ),
                  ),

                  onPressed: (){ Navigator.pop(context, "cancel"); },
                )
              ],
            ),
          ]
        );
      }
    ))

    {
      case "delete":
        delete(position);
        Fluttertoast.showToast(msg: "Deleted");
        break;

      case "cancel":
        break; // No need to do anything, dialog is dismissed automatically upon pressing.
    }
  }


  /// Builds the dialog that's called when the user wants to sign out.
  Future<void> _askedToSignOut() async{
    switch(await showCupertinoModalPopup(
      context: context,

      builder: (BuildContext context){
        return SimpleDialog(
          title: Text(AppLocalizations.of(context).translate("CONFIRM_SIGN_OUT")),
          contentPadding: EdgeInsets.all(Constants.ELEMENT_MARGIN),

          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Option to sign out.
                SimpleDialogOption(
                  onPressed: (){ Navigator.pop(context, "SignOut"); },
                  child: Text(
                      AppLocalizations.of(context).translate("SIGN_OUT"),
                    style: TextStyle(color: Constants.ACCENT_COLOR)
                  ),
                ),

                // Option to stay.
                SimpleDialogOption(
                  onPressed: (){ Navigator.pop(context, "Stay"); },
                  child: Text(
                    AppLocalizations.of(context).translate("NO"),
                    style: TextStyle(color: Constants.ACCENT_COLOR),
                  )
                )
              ],
            ),
          ],
        );
      }
    ))

    {
      case "SignOut":
        signOut().whenComplete(() =>
            Navigator.pop(context)
        );
        break;

      case "Stay":
        break; // We don't need to do anything. Dialog is dismissed automatically.
    }
  }


  /// Syncs the database with the app.
  getData() async {
    widget.devices.clear();
     FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser.uid).collection("devices").snapshots().listen((event) {
      Fluttertoast.showToast(msg: "Reached");
    });
  }


  /// Provides the option to sign out, if the back button is pressed.
  Future<bool> _onBackPressed() async {
    _askedToSignOut();
    return Future.value(true);
  }

}

