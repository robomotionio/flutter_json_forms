import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:recase/recase.dart';
import 'package:flutter_json_forms/components/control.dart';
import 'package:url_launcher/url_launcher.dart';

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
    String? title = widget.schema["title"];
    dynamic description = widget.schema["description"];

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title != null ? Text(title) : Container(),
          title != null ? const SizedBox(height: 8) : Container(),
          CheckboxListTile(
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
