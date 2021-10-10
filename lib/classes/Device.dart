import 'package:flutter/material.dart';

/// Here we merge the device and the list view item instance together.
/// The item "peeks" directly at the device that it's representing.
class Device {

  /// Contains three digits.
  /// The first digit carries the icon color.
  /// The second and third digits carry the icon.
  int iconCode;

  /// A map of SSID's with the corresponding local IP of the device.
  String local_IP;

  String id;
  String name;
  Icon icon;
  bool isExpanded;

  /// The constructor uses the name and ID that the user gives it
  /// on the "Add Device" activity. isExpanded is set to false by default,
  /// so the list view item appears minimized on the App Center.
  /// Default iconCode is 200 ("Devices" in red).
  Device({this.name, this.id, this.isExpanded: false, this.iconCode}) {
    // Get the icon from the iconCode.
    Icon iconWithoutColor = getDeviceIcon(iconCode);

    // Extract the icon data and set the new color.
    icon = Icon(
      iconWithoutColor.icon,
      color: getIconColor(iconCode),
    );
  }

  /// Decode the first digit to a color.
  Color getIconColor(int iconCode) {
    // Get the integer value of the division.
    // Produces the first digit.
    int color = iconCode ~/ 100;

    switch(color) {
      case 0:
        return Colors.transparent.withOpacity(1.0);
      case 1:
        return Colors.blue;
      case 2:
        return Colors.red;
      case 3:
        return Colors.green;
      case 4:
        return Colors.yellow;

      default:
        return Colors.black;
    }
  }

  /// Decode the last digits to a device icon.
  Icon getDeviceIcon(int iconCode) {
    int icon = iconCode % 100;

    switch(icon) {
      case 0:
        return Icon(Icons.devices_outlined);
      case 1:
        return Icon(Icons.directions_car_outlined);
      case 2:
        return Icon(Icons.motorcycle_outlined);
      case 3:
        return Icon(Icons.directions_bike_outlined);
      case 4:
        return Icon(Icons.electric_scooter_outlined);
      case 5:
        return Icon(Icons.tv_outlined);
      case 6:
        return Icon(Icons.vpn_key_outlined);
      case 7:
        return Icon(Icons.phone_iphone_outlined);
      case 8:
        return Icon(Icons.android);
      case 9:
        return Icon(Icons.tablet_outlined);
      case 10:
        return Icon(Icons.pets_outlined);
      case 11:
        return Icon(Icons.emoji_people_outlined);
      case 12:
        return Icon(Icons.account_balance_wallet_outlined);
      case 13:
        return Icon(Icons.settings_remote_outlined);

      default:
        return Icon(Icons.devices_outlined);
    }
  }

}
