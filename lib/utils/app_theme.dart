import 'package:flutter/material.dart';

ThemeData get appTheme => ThemeData(
  primaryColor: Color(0xff424750),
  primaryColorDark: Color(0xff1f2228),
  primaryColorLight: Color(0xff83878f),
  accentColor: Color(0xeeE66943),
  visualDensity: VisualDensity.adaptivePlatformDensity,
  sliderTheme: SliderThemeData(
      activeTrackColor: Color(0xeeE66943),
      inactiveTrackColor: Color(0xff83878f),
      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.0),
      thumbColor: Color(0xff1f2228),
      overlayShape: RoundSliderOverlayShape(overlayRadius: 8.0),
      trackHeight: 2.0),
);