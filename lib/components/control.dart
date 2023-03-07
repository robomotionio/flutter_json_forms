import 'package:flutter/material.dart';
import 'package:flutter_json_forms/components/boolean.dart';
import 'package:flutter_json_forms/components/number.dart';
import 'package:flutter_json_forms/components/string.dart';
import 'package:flutter_json_forms/const.dart';

abstract class Control extends StatefulWidget {
  final Map<String, dynamic> schema;
  final Map<String, dynamic>? options;
  final String scope;
  final bool isRequired;
  final dynamic defaultValue;

  const Control({
    super.key,
    required this.schema,
    required this.scope,
    required this.isRequired,
    required this.defaultValue,
    this.options,
  });

  @override
  State createState();

  String get label => "${scope.split("/").last} ${isRequired ? '*' : ''}";

  static Control? from({
    required Map<String, dynamic> schema,
    Map<String, dynamic>? options,
    required String scope,
    bool isRequired = false,
    dynamic defaultValue,
    Key? key,
  }) {
    switch (schema["type"]) {
      case ControlTypes.string:
        return JFCString(
          schema: schema,
          scope: scope,
          isRequired: isRequired,
          defaultValue: defaultValue,
          enumeration:
              schema["enum"] != null ? List<String>.from(schema["enum"]) : null,
          options: options,
          key: key,
        );

      case ControlTypes.integer:
        return JFCNumber(
          schema: schema,
          scope: scope,
          isRequired: isRequired,
          defaultValue: defaultValue,
          options: options,
          key: key,
        );

      case ControlTypes.number:
        return JFCNumber(
          schema: schema,
          scope: scope,
          isRequired: isRequired,
          defaultValue: defaultValue,
          options: options,
          precision: 2,
          key: key,
        );

      case ControlTypes.boolean:
        return JFCBoolean(
          schema: schema,
          scope: scope,
          isRequired: isRequired,
          defaultValue: defaultValue,
          options: options,
          key: key,
        );

      default:
        return null;
    }
  }
}
