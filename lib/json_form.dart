import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_json_forms/components/control.dart';
import 'package:flutter_json_forms/const.dart';

class JsonForm extends StatefulWidget {
  final dynamic json;

  const JsonForm({super.key, required this.json});

  @override
  JsonFormState createState() => JsonFormState();
}

class JsonFormState extends State<JsonForm> {
  late final Map<String, dynamic> json;

  @override
  void initState() {
    super.initState();

    if (widget.json is String) {
      json = jsonDecode(widget.json);
    } else if (widget.json is Map<String, dynamic>) {
      json = widget.json;
    }
  }

  Map<String, dynamic>? schemaGet(String scope) {
    Map<String, dynamic>? schema = Map<String, dynamic>.from(
      json[FormTypes.schema],
    );

    scope.split("/").forEach((p) {
      if (p == "#") return;
      schema = schema?[p];
    });

    return schema;
  }

  bool isRequired(String scope) {
    Map<String, dynamic>? schema = Map<String, dynamic>.from(
      json[FormTypes.schema],
    );

    return List<String>.from(schema["required"])
        .contains(scope.split("/").last);
  }

  dynamic getDefaultValue(String scope) {
    Map<String, dynamic>? formData = Map<String, dynamic>.from(
      json[FormTypes.formData],
    );

    return formData[scope.split("/").last];
  }

  Widget buildElement(BuildContext context, Map<String, dynamic> element) {
    switch (element["type"]) {
      case ElementTypes.horizontalLayout:
        return buildLayout(context, element);

      case ElementTypes.verticalLayout:
        return Expanded(child: buildLayout(context, element));

      case ElementTypes.control:
        String scope = element["scope"] ?? "";
        return Expanded(
          child: Control.from(
                schemaGet(scope),
                scope,
                isRequired(scope),
                getDefaultValue(scope),
              ) ??
              Container(),
        );

      default:
        return Container();
    }
  }

  List<Widget> buildElements(
    BuildContext context,
    List<Map<String, dynamic>> elements,
  ) {
    return elements.map((e) => buildElement(context, e)).toList();
  }

  Widget buildLayout(BuildContext context, Map<String, dynamic> schema) {
    List<Widget> children = buildElements(
      context,
      List<Map<String, dynamic>>.from(schema["elements"]),
    );

    switch (schema["type"]) {
      case ElementTypes.horizontalLayout:
        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        );
      case ElementTypes.verticalLayout:
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        );
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: buildLayout(context, json[FormTypes.uiSchema]),
    );
  }
}
