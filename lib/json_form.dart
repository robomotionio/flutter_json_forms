import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_json_forms/components/control.dart';
import 'package:flutter_json_forms/const.dart';
import 'package:flutter_json_forms/const.dart' as jfc;

class JsonFormController {
  JsonFormController();
  JsonForm? _jsonForm;

  JsonForm get jsonForm {
    assert(_jsonForm != null);
    return _jsonForm!;
  }
}

class JsonForm extends StatefulWidget {
  final dynamic json;
  final List<Control> _controls = [];
  final Map<String, dynamic> _formData = {};
  final Map<String, String> _errors = {};
  final JsonFormController? controller;

  JsonForm({super.key, required this.json, this.controller}) {
    this.controller?._jsonForm = this;
  }

  Map<String, dynamic> get formData {
    assert(_errors.isEmpty);
    return _formData;
  }

  Map<String, dynamic> get errors => _errors;

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

  Map<String, dynamic> schemaGet(String scope) {
    Map<String, dynamic> schema = Map<String, dynamic>.from(
      json[FormTypes.schema],
    );

    scope.split("/").forEach((p) {
      if (p == "#") return;
      schema = schema[p] ?? {};
    });

    return schema;
  }

  bool isRequired(String scope) {
    Map<String, dynamic>? schema = Map<String, dynamic>.from(
      json[FormTypes.schema],
    );

    return List<String>.from(schema["required"] ?? [])
        .contains(scope.split("/").last);
  }

  dynamic getDefaultValue(String scope) {
    Map<String, dynamic>? formData = Map<String, dynamic>.from(
      json[FormTypes.formData],
    );

    return formData[scope.split("/").last];
  }

  Map<String, dynamic>? getOptions(Map<String, dynamic> element) {
    return element["options"] == null
        ? null
        : Map<String, dynamic>.from(element["options"]);
  }

  jfc.ValueChanged getValueChanged(String scope) {
    return (value, {error}) {
      String key = scope.split("/").last;
      widget._formData[key] = value;

      if (error == null) {
        widget._errors.remove(key);
      } else {
        widget._errors[key] = error;
      }
    };
  }

  Widget buildElement(BuildContext context, Map<String, dynamic> element) {
    switch (element["type"]) {
      case ElementTypes.horizontalLayout:
        return buildLayout(context, element);

      case ElementTypes.verticalLayout:
        return buildLayout(context, element);

      case ElementTypes.control:
        String scope = element["scope"] ?? "";
        Control? control = Control.from(
          schema: schemaGet(scope),
          options: getOptions(element),
          scope: scope,
          isRequired: isRequired(scope),
          defaultValue: getDefaultValue(scope),
          onValueChanged: getValueChanged(scope),
        );

        if (control == null) {
          return Container();
        }

        widget._controls.add(control);
        return control;

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
          children: children.map((c) => Expanded(child: c)).toList(),
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
    return buildLayout(context, json[FormTypes.uiSchema]);
  }
}
