import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:async';
import 'package:crypto/component/style.dart';

class DemoTheme {
  final String name;
  final ThemeData data;

  const DemoTheme(this.name, this.data);
}

class ThemeBloc {
  final Stream<ThemeData> themeDataStream;
  final Sink<DemoTheme> selectedTheme;

  factory ThemeBloc() {
    final selectedTheme = PublishSubject<DemoTheme>();
    final themeDataStream = selectedTheme.distinct().map((theme) => theme.data);
    return ThemeBloc._(themeDataStream, selectedTheme);
  }

  const ThemeBloc._(this.themeDataStream, this.selectedTheme);

  DemoTheme initialTheme() {
    return DemoTheme(
        'initial',
        ThemeData(
          scaffoldBackgroundColor: colorStyle.background,
          backgroundColor: colorStyle.blackBackground,
          dividerColor: colorStyle.iconColorDark,
          primaryColor: colorStyle.primaryColor,
          hintColor: colorStyle.fontSecondaryColorDark,
          canvasColor: colorStyle.grayBackground,
          cardColor: colorStyle.grayBackground,
          primaryColorLight: colorStyle.fontColorDark,

          secondaryHeaderColor: colorStyle.fontColorDark,
          // textSelectionColor: colorStyle.fontColorDark,
          // textSelectionHandleColor: colorStyle.fontColorDarkTitle
        ));
  }
}
