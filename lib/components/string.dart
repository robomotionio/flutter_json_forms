import 'package:flutter/material.dart';
import 'package:flutter_json_forms/components/control.dart';
import 'package:recase/recase.dart';
import 'package:intl/intl.dart';

class JFCString extends Control {
  final List<String>? enumeration;

  JFCString({
    super.key,
    required super.schema,
    required super.scope,
    required super.isRequired,
    required super.defaultValue,
    required super.onValueChanged,
    super.options,
    this.enumeration,
  });

  @override
  JFCStringState createState() => JFCStringState();
}

class JFCStringState extends State<JFCString> {
  final TextEditingController _controller = TextEditingController();
  final DateFormat _dateFormat = DateFormat("dd.MM.yyyy");

  int _minLength = 0;
  int? _maxLength;
  bool showSecret = false;

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

    String val = widget.defaultValue ?? "";
    /*
    if (val.isEmpty && widget.enumeration != null) {
      val = widget.enumeration!.first.snakeCase;
    }
    */

    onValueChanged(val);
    _controller.text = val;
  }

  String? errorText({String? value}) {
    value ??= this.value;
    if (value.isNotEmpty && value.length < _minLength) {
      return "Value must have at least $_minLength characters";
    }
    return null;
  }

  void onValueChanged(String? val) {
    if (val == null) {
      return;
    }

    widget.onValueChanged(val, error: errorText(value: val));

    setState(() {
      value = val;
    });
  }

  Widget buildRadio(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.start,
      direction: Axis.horizontal,
      spacing: 8,
      children: widget.enumeration!.map(
        (String element) {
          return IntrinsicWidth(
            child: RadioListTile<String>(
              value: element.snakeCase,
              groupValue: value,
              dense: true,
              title: Text(
                element,
                style: const TextStyle(fontSize: 16),
              ),
              onChanged: widget.options?["readonly"] == true
                  ? null
                  : (val) {
                      onValueChanged(val ?? "");
                    },
            ),
          );
        },
      ).toList(),
    );
  }

  Widget buildDropDown(BuildContext context) {
    return DropdownButton<String>(
      value: value,
      icon: const Icon(Icons.arrow_drop_down),
      iconSize: 32,
      isExpanded: true,
      itemHeight: 56,
      underline: Container(
        height: 2,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFBDBDBD)),
        ),
      ),
      onChanged: widget.options?["readonly"] == true
          ? null
          : (String? val) {
              onValueChanged(val ?? "");
            },
      items:
          widget.enumeration!.map<DropdownMenuItem<String>>((String element) {
        return DropdownMenuItem<String>(
          value: element.snakeCase,
          child: Text(
            element,
            style: const TextStyle(fontSize: 16),
          ),
        );
      }).toList(),
    );
  }

  Widget buildEnum(BuildContext context) {
    if (widget.options == null) {
      return buildDropDown(context);
    }

    switch (widget.options!["format"]) {
      case "radio":
        return buildRadio(context);
      default:
        return buildDropDown(context);
    }
  }

  Widget buildDatePicker(BuildContext context) {
    return TextField(
      controller: _controller,
      onTap: () async {},
      readOnly: true,
      enabled: widget.options?["readonly"] != true,
      decoration: InputDecoration(
        labelText: widget.label.titleCase,
        hintText: "dd.MM.yyyy",
        contentPadding: const EdgeInsets.all(2),
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today),
          tooltip: "Select",
          splashRadius: 24,
          iconSize: 18,
          onPressed: widget.options?["readonly"] == true
              ? null
              : () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2099),
                  );

                  if (picked == null) {
                    return;
                  }

                  String val = _dateFormat.format(picked);
                  onValueChanged(val);
                  _controller.text = val;
                },
        ),
      ),
    );
  }

  Widget buildTextField(BuildContext context) {
    return TextField(
      controller: _controller,
      enabled: widget.options?["readonly"] != true,
      obscureText: widget.options?["secret"] == true && !showSecret,
      onChanged: ((val) {
        onValueChanged(val);
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
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            widget.options?["secret"] == true
                ? IconButton(
                    icon: Icon(
                      showSecret ? Icons.visibility : Icons.visibility_off,
                    ),
                    tooltip: showSecret ? "Hide" : "Show",
                    splashRadius: 12,
                    iconSize: 18,
                    onPressed: () {
                      setState(() {
                        showSecret = !showSecret;
                      });
                    },
                  )
                : Container(),
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: value.isEmpty ? null : "Clear",
              splashRadius: 12,
              iconSize: 18,
              onPressed: value.isEmpty
                  ? null
                  : () {
                      onValueChanged("");
                      _controller.text = "";
                    },
            ),
          ],
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
        if (widget.enumeration != null) {
          child = buildEnum(context);
        } else {
          child = buildTextField(context);
        }
    }

    return Padding(
      padding: const EdgeInsets.all(8),
      child: child,
    );
  }
}
