import 'package:flutter/material.dart';
import 'package:flutter_json_forms/components/number.dart';
import 'package:flutter_json_forms/components/string.dart';
import 'package:flutter_json_forms/const.dart';

abstract class Control extends StatefulWidget {
  final Map<String, dynamic> schema;
  final String scope;
  final bool isRequired;
  final dynamic defaultValue;

  const Control({
    super.key,
    required this.schema,
    required this.scope,
    required this.isRequired,
    required this.defaultValue,
  });

  @override
  State createState();

  String get label => "${scope.split("/").last} ${isRequired ? '*' : ''}";

  static Control? from(
    Map<String, dynamic>? schema,
    String scope,
    bool isRequired,
    dynamic defaultValue, {
    Key? key,
  }) {
    if (schema == null) {
      return null;
    }

    switch (schema["type"]) {
      case ControlTypes.string:
        return JFCString(
          schema: schema,
          scope: scope,
          isRequired: isRequired,
          defaultValue: defaultValue,
          key: key,
        );

      case ControlTypes.integer:
        return JFCNumber(
          schema: schema,
          scope: scope,
          isRequired: isRequired,
          defaultValue: defaultValue,
          key: key,
        );

      case ControlTypes.number:
        return JFCNumber(
          schema: schema,
          scope: scope,
          isRequired: isRequired,
          defaultValue: defaultValue,
          precision: 2,
          key: key,
        );

      default:
        return null;
    }
  }
}
