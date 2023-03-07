import 'package:flutter/material.dart';
import 'package:recase/recase.dart';
import 'package:flutter_json_forms/components/control.dart';

class JFCBoolean extends Control {
  const JFCBoolean({
    super.key,
    required super.schema,
    required super.scope,
    required super.isRequired,
    required super.defaultValue,
    super.options,
  });

  @override
  JFCBooleanState createState() => JFCBooleanState();
}

class JFCBooleanState extends State<JFCBoolean> {
  bool? value;

  @override
  void initState() {
    super.initState();
    value = widget.defaultValue;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: CheckboxListTile(
        value: value ?? false,
        dense: true,
        controlAffinity: ListTileControlAffinity.leading,
        title: Text(
          widget.label.titleCase,
          style: const TextStyle(fontSize: 16),
        ),
        onChanged: (val) {
          setState(() {
            value = val;
          });
        },
      ),
    );
  }
}
