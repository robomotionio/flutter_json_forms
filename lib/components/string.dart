import 'package:flutter/material.dart';
import 'package:flutter_json_forms/components/control.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
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
    String? title = widget.schema["title"];
    dynamic description = widget.schema["description"];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        title != null ? Text(title) : Container(),
        title != null ? const SizedBox(height: 8) : Container(),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.start,
          direction: Axis.horizontal,
          spacing: 8,
          children: widget.enumeration!.map(
            (String element) {
              return IntrinsicWidth(
                child: RadioListTile<String>(
                  value: element,
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
                        p: Theme.of(context)
                            .textTheme
                            .headline1
                            ?.copyWith(fontSize: description["size"] ?? 14.0)),
              )
            : Container(),
      ],
    );
  }

  Widget buildDropDown(BuildContext context) {
    String? title = widget.schema["title"];
    dynamic description = widget.schema["description"];

    return Column(
      children: [
        DropdownButton<String>(
          value: value,
          hint: Text(title ?? "Select"),
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
          items: widget.enumeration!
              .map<DropdownMenuItem<String>>((String element) {
            return DropdownMenuItem<String>(
              value: element,
              child: Text(
                element,
                style: const TextStyle(fontSize: 16),
              ),
            );
          }).toList(),
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
                        p: Theme.of(context)
                            .textTheme
                            .headline1
                            ?.copyWith(fontSize: description["size"] ?? 14.0)),
              )
            : Container(),
      ],
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
    String? title = widget.schema["title"];
    dynamic description = widget.schema["description"];
    String? helperText = widget.schema["helperText"];
    String? placeholder = widget.schema["placeholder"];
    bool? hideLabel = widget.schema["hideLabel"];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        title != null ? Text(title) : Container(),
        title != null ? const SizedBox(height: 8) : Container(),
        TextField(
          controller: _controller,
          onTap: () async {},
          readOnly: true,
          enabled: widget.options?["readonly"] != true,
          decoration: InputDecoration(
            labelText: hideLabel == true ? null : widget.label.titleCase,
            hintText: placeholder ?? "dd.MM.yyyy",
            helperText: helperText,
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
                        p: Theme.of(context)
                            .textTheme
                            .headline1
                            ?.copyWith(fontSize: description["size"] ?? 14.0)),
              )
            : Container(),
      ],
    );
  }

  Widget buildTextField(BuildContext context) {
    String? title = widget.schema["title"];
    dynamic description = widget.schema["description"];
    String? helperText = widget.schema["helperText"];
    String? placeholder = widget.schema["placeholder"];
    int? minLines = widget.schema["minLines"];
    int? maxLines = widget.schema["maxLines"];
    bool? hideLabel = widget.schema["hideLabel"];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        title != null ? Text(title) : Container(),
        title != null ? const SizedBox(height: 8) : Container(),
        TextField(
          keyboardType: TextInputType.multiline,
          minLines: minLines,
          maxLines: maxLines,
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
            labelText: hideLabel == true ? null : widget.label.titleCase,
            counterText: "",
            helperText: helperText,
            hintText: placeholder,
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
                        p: Theme.of(context)
                            .textTheme
                            .headline1
                            ?.copyWith(fontSize: description["size"] ?? 14.0)),
              )
            : Container(),
      ],
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
