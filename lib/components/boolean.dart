import 'package:flutter/material.dart';
import 'package:recase/recase.dart';
import 'package:flutter_json_forms/components/control.dart';

class JFCBoolean extends Control {
  JFCBoolean({
    super.key,
    required super.schema,
    required super.scope,
    required super.isRequired,
    required super.defaultValue,
    required super.onValueChanged,
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
    onValueChanged(widget.defaultValue);
  }

  void onValueChanged(bool? val) {
    setState(() {
      value = val;
    });
    widget.onValueChanged(val);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: CheckboxListTile(
        value: value ?? false,
        dense: true,
        enabled: widget.options?["readonly"] != true,
        controlAffinity: ListTileControlAffinity.leading,
        title: Text(
          widget.label.titleCase,
          style: const TextStyle(fontSize: 16),
        ),
        onChanged: onValueChanged,
      ),
    );
  }
}
