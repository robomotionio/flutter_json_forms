import 'package:flutter/material.dart';
import 'package:flutter_json_forms/components/control.dart';
import 'package:recase/recase.dart';
import 'package:intl/intl.dart';

class JFCString extends Control {
  const JFCString({
    super.key,
    required super.schema,
    required super.scope,
    required super.isRequired,
    required super.defaultValue,
  });

  @override
  JFCStringState createState() => JFCStringState();
}

class JFCStringState extends State<JFCString> {
  final TextEditingController _controller = TextEditingController();
  final DateFormat _dateFormat = DateFormat("dd.MM.yyyy");

  int _minLength = 0;
  int? _maxLength;

  late String value;

  @override
  void initState() {
    super.initState();

    if (widget.schema["minLength"] is int) {
      _minLength = widget.schema["minLength"];
    }

    if (widget.schema["maxLength"] is int) {
      _maxLength = widget.schema["maxLength"];
    }

    value = widget.defaultValue ?? "";
    _controller.text = value;
  }

  String? errorText() {
    if (value.isNotEmpty && value.length < _minLength) {
      return "Value must have at least $_minLength characters";
    }
    return null;
  }

  Widget buildDatePicker(BuildContext context) {
    return TextField(
      controller: _controller,
      onTap: () async {},
      readOnly: true,
      decoration: InputDecoration(
        labelText: widget.label.titleCase,
        hintText: "dd.MM.yyyy",
        contentPadding: const EdgeInsets.all(2),
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today),
          tooltip: "Select",
          splashRadius: 24,
          iconSize: 18,
          onPressed: () async {
            DateTime? picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime(2099),
            );

            if (picked == null) {
              return;
            }

            setState(() {
              value = _dateFormat.format(picked);
              _controller.text = value;
            });
          },
        ),
      ),
    );
  }

  Widget buildTextField(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: ((val) {
        setState(() {
          value = val;
        });
      }),
      textAlign: TextAlign.start,
      textAlignVertical: TextAlignVertical.center,
      maxLength: _maxLength,
      decoration: InputDecoration(
        errorText: errorText(),
        border: const UnderlineInputBorder(),
        labelText: widget.label.titleCase,
        counterText: "",
        contentPadding: const EdgeInsets.all(2),
        suffixIcon: IconButton(
          icon: const Icon(Icons.close),
          tooltip: value.isEmpty ? null : "Clear",
          splashRadius: 12,
          iconSize: 18,
          onPressed: value.isEmpty
              ? null
              : () {
                  _controller.text = "";
                  setState(() {
                    value = "";
                  });
                },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget? child;

    switch (widget.schema["format"]) {
      case "date":
        child = buildDatePicker(context);
        break;
      default:
        child = buildTextField(context);
    }

    return Padding(
      padding: const EdgeInsets.all(8),
      child: child,
    );
  }
}
