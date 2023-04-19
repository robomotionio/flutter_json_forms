import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_json_forms/components/control.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:recase/recase.dart';
import 'dart:math' as math;

import 'package:url_launcher/url_launcher.dart';

class JFCNumber extends Control {
  final int precision;

  JFCNumber({
    super.key,
    required super.schema,
    required super.scope,
    required super.isRequired,
    required super.defaultValue,
    required super.onValueChanged,
    super.options,
    this.precision = 0,
  });

  @override
  JFCNumberState createState() => JFCNumberState();
}

class JFCNumberState extends State<JFCNumber> {
  final TextEditingController _controller = TextEditingController();
  final List<TextInputFormatter> _formatters = [];

  int? _minimum;
  int? _maximum;
  double? value;

  @override
  void initState() {
    super.initState();

    if (widget.schema["minimum"] is int) {
      _minimum = widget.schema["minimum"];
    }

    if (widget.schema["maximum"] is int) {
      _maximum = widget.schema["maximum"];
    }

    double? val = widget.defaultValue;
    onValueChanged(val);
    if (val != null) {
      _controller.text = val.toString();
    }

    initFormatters();
  }

  void initFormatters() {
    if (widget.precision == 0) {
      _formatters.add(
        FilteringTextInputFormatter.allow(
          RegExp(r'[0-9]'),
        ),
      );
    } else {
      _formatters.add(
        DecimalTextInputFormatter(decimalRange: widget.precision),
      );
    }
  }

  String? errorText({double? value}) {
    value ??= this.value;
    if (value == null) {
      return widget.isRequired ? "Value is required" : null;
    }

    if (_minimum != null && value < _minimum!) {
      return "Value must be greater than or equal to $_minimum";
    }
    if (_maximum != null && value > _maximum!) {
      return "Value must be less than or equal to $_maximum";
    }
    return null;
  }

  void onValueChanged(double? val) {
    widget.onValueChanged(val, error: errorText(value: val));

    setState(() {
      value = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    String? title = widget.schema["title"];
    dynamic description = widget.schema["description"];
    String? helperText = widget.schema["helperText"];
    String? placeholder = widget.schema["placeholder"];
    bool? hideLabel = widget.schema["hideLabel"];

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title != null ? Text(title) : Container(),
          title != null ? const SizedBox(height: 8) : Container(),
          TextField(
            controller: _controller,
            enabled: widget.options?["readonly"] != true,
            onChanged: (val) {
              onValueChanged(double.tryParse(val));
            },
            keyboardType: TextInputType.number,
            inputFormatters: _formatters,
            textAlign: TextAlign.start,
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              border: const UnderlineInputBorder(),
              errorText: errorText(),
              labelText: hideLabel == true ? null : widget.label.titleCase,
              helperText: helperText,
              hintText: placeholder,
              contentPadding: const EdgeInsets.fromLTRB(2, 2, 2, 8),
              suffixIcon: Container(
                margin: const EdgeInsets.only(top: 4, bottom: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 18,
                      width: 18,
                      padding: EdgeInsets.zero,
                      child: InkWell(
                        onTap: () {
                          double? val = value ?? 0;
                          val = val + math.pow(10, -widget.precision);
                          val = double.tryParse(val.toStringAsFixed(2));
                          onValueChanged(val);
                          _controller.text = val.toString();
                        },
                        child: const Icon(Icons.arrow_drop_up, size: 18),
                      ),
                    ),
                    Container(
                      height: 18,
                      width: 18,
                      padding: EdgeInsets.zero,
                      child: InkWell(
                        onTap: () {
                          double? val = value ?? 0;
                          val = val - math.pow(10, -widget.precision);
                          val = double.tryParse(val.toStringAsFixed(2));
                          onValueChanged(val);
                          _controller.text = val.toString();
                        },
                        child: const Icon(Icons.arrow_drop_down, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          description != null ? const SizedBox(height: 8) : Container(),
          description != null
              ? MarkdownBody(
                  data: description["text"],
                  onTapLink: (text, href, title) {
                    launchUrl(Uri.parse(href!));
                  },
                  styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                      .copyWith(
                          p: Theme.of(context).textTheme.headline1?.copyWith(
                              fontSize: description["size"] ?? 14.0)),
                )
              : Container(),
        ],
      ),
    );
  }
}

class DecimalTextInputFormatter extends TextInputFormatter {
  DecimalTextInputFormatter({this.decimalRange})
      : assert(decimalRange == null || decimalRange > 0);

  final int? decimalRange;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue, // unused.
    TextEditingValue newValue,
  ) {
    TextSelection newSelection = newValue.selection;
    String truncated = newValue.text;

    if (decimalRange != null) {
      String value = newValue.text;

      if (value.contains(".") &&
          value.substring(value.indexOf(".") + 1).length > decimalRange!) {
        truncated = oldValue.text;
        newSelection = oldValue.selection;
      } else if (value == ".") {
        truncated = "0.";

        newSelection = newValue.selection.copyWith(
          baseOffset: math.min(truncated.length, truncated.length + 1),
          extentOffset: math.min(truncated.length, truncated.length + 1),
        );
      }

      return TextEditingValue(
        text: truncated,
        selection: newSelection,
        composing: TextRange.empty,
      );
    }
    return newValue;
  }
}
