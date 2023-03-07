import 'package:flutter/material.dart';
import 'package:flutter_json_forms/json_form.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SizedBox(
          width: 1080,
          child: const JsonForm(
            json: json,
          ),
        ),
      ),
    );
  }
}

const String json = '''{
  "schema": {
    "type": "object",
    "required": [
      "age"
    ],
    "properties": {
      "firstName": {
        "type": "string",
        "minLength": 2,
        "maxLength": 20
      },
      "lastName": {
        "type": "string",
        "minLength": 5,
        "maxLength": 15
      },
      "age": {
        "type": "integer",
        "minimum": 18,
        "maximum": 100
      },
      "gender": {
        "type": "string",
        "enum": [
          "Male",
          "Female",
          "Undisclosed"
        ]
      },
      "height": {
        "type": "number"
      },
      "dateOfBirth": {
        "type": "string",
        "format": "date"
      },
      "rating": {
        "type": "integer"
      },
      "committer": {
        "type": "boolean"
      },
      "address": {
        "type": "object",
        "properties": {
          "street": {
            "type": "string"
          },
          "streetnumber": {
            "type": "string"
          },
          "postalCode": {
            "type": "string"
          },
          "city": {
            "type": "string"
          }
        }
      }
    }
  },
  "ui_schema": {
    "type": "VerticalLayout",
    "elements": [
      {
        "type": "HorizontalLayout",
        "elements": [
          {
            "type": "Control",
            "scope": "#/properties/firstName"
          },
          {
            "type": "Control",
            "scope": "#/properties/lastName"
          }
        ]
      },
      {
        "type": "HorizontalLayout",
        "elements": [
          {
            "type": "Control",
            "scope": "#/properties/age"
          },
          {
            "type": "Control",
            "scope": "#/properties/dateOfBirth"
          }
        ]
      },
      {
        "type": "HorizontalLayout",
        "elements": [
          {
            "type": "Control",
            "scope": "#/properties/height"
          },
          {
            "type": "Control",
            "scope": "#/properties/gender",
            "options": {
              "format": "radio"
            }
          },
          {
            "type": "Control",
            "scope": "#/properties/committer"
          }
        ]
      },
      {
        "type": "Group",
        "label": "Address for Shipping T-Shirt",
        "elements": [
          {
            "type": "HorizontalLayout",
            "elements": [
              {
                "type": "Control",
                "scope": "#/properties/address/properties/street"
              },
              {
                "type": "Control",
                "scope": "#/properties/address/properties/streetnumber"
              }
            ]
          },
          {
            "type": "HorizontalLayout",
            "elements": [
              {
                "type": "Control",
                "scope": "#/properties/address/properties/postalCode"
              },
              {
                "type": "Control",
                "scope": "#/properties/address/properties/city"
              }
            ]
          }
        ],
        "rule": {
          "effect": "ENABLE",
          "condition": {
            "scope": "#/properties/committer",
            "schema": {
              "const": true
            }
          }
        }
      }
    ]
  },
  "form_data": {
    "firstName": "Max",
    "lastName": "Power"
  }
}''';
