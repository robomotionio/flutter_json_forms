class FormTypes {
  static const String schema = "schema";
  static const String uiSchema = "ui_schema";
  static const String formData = "form_data";
}

class ElementTypes {
  static const String control = "Control";
  static const String group = "Group";
  static const String horizontalLayout = "HorizontalLayout";
  static const String verticalLayout = "VerticalLayout";
}

class ControlTypes {
  static const String string = "string";
  static const String integer = "integer";
  static const String number = "number";
  static const String boolean = "boolean";
}

typedef ValueChanged = void Function(dynamic value, {String? error});
