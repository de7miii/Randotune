import 'package:flutter/material.dart';

var primaryColor = Color(0xff424750);
var primaryDarkColor = Color(0xff1f2228);
var primaryLightColor = Color(0xff83878f);
var accentColor = Color(0xeeE66943);

ThemeData get appTheme => ThemeData(
  primaryColor: primaryColor,
  primaryColorDark: primaryDarkColor,
  primaryColorLight: primaryLightColor,
  accentColor: accentColor,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  sliderTheme: SliderThemeData(
      activeTrackColor: accentColor,
      inactiveTrackColor: primaryLightColor,
      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.0),
      thumbColor: primaryDarkColor,
      overlayShape: RoundSliderOverlayShape(overlayRadius: 8.0),
      trackHeight: 2.0),
  iconTheme: IconThemeData(color: Colors.white),
  accentIconTheme: IconThemeData(color: primaryColor),
  primaryIconTheme: IconThemeData(color: accentColor),
);