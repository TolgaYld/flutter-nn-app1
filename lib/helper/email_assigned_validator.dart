import 'package:form_field_validator/form_field_validator.dart';

class EmailAssignedValidator extends FieldValidator<dynamic> {
  EmailAssignedValidator(String errorText) : super(errorText);

  @override
  bool isValid(dynamic value) {
    value == false;
    return true;
  }
}
