import 'package:cssayp_movil/shared/exceptions/generic_exception.dart';

class PasswordException extends GenericException {
  PasswordException(super.message, super.code);
}

class IncorrectPasswordException extends PasswordException {
  IncorrectPasswordException(String message) : super(message, 'ERR_INCORRECT_PASSWORD');
}
