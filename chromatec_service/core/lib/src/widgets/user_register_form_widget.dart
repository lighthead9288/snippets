import 'package:core/core.dart';
import 'package:core/i18n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:string_validator/string_validator.dart' as validator;

class UserRegisterFormWidget extends StatefulWidget {
  final CreateUserProvider provider;
  final Future<void> Function() onRegisterSuccess;
  final Future<void> Function() onRegisterError;
  final bool isLoading;

  UserRegisterFormWidget({@required this.provider, @required this.onRegisterSuccess, @required this.onRegisterError, @required this.isLoading});

  @override
  State<UserRegisterFormWidget> createState() => _UserRegisterFormWidgetState();
}

class _UserRegisterFormWidgetState extends State<UserRegisterFormWidget> {

  GlobalKey<FormState> _formKey;
  RegExp _nameRegExp = RegExp(r'^[a-zA-Zа-яА-Я -]+$');
  double _deviceHeight;
  double _deviceWidth;

  _UserRegisterFormWidgetState() {
    _formKey = GlobalKey<FormState>();
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return _registerForm();
  }

  Widget _registerForm() {
    var provider = this.widget.provider;
    return Container(
        padding: EdgeInsets.only(top: 20),
        child: Form(
          key: _formKey,
          onChanged: () {
            _formKey.currentState.save();
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _emailTextField(provider),
              SizedBox(height: _deviceHeight * 0.02),
              _passwordTextField(provider),
              SizedBox(height: _deviceHeight * 0.02),
              _nameTextField(provider),
              SizedBox(height: _deviceHeight * 0.02),
              _surnameTextField(provider),
              SizedBox(height: _deviceHeight * 0.02),
              _registerButton(provider),
            ],
          ),
        ));
  }

  Widget _emailTextField(CreateUserProvider provider) {
    return TextFormField(
        autocorrect: false,
        validator: (inputString) {
          return (validator.isEmail(inputString))
              ? null
              : S.of(context).enterValidEmail;
        },
        onSaved: (inputString) {
          provider.email = inputString;
        },
        decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
            prefixIcon: Icon(Icons.email),
            hintText: S.of(context).enterYourEmail,
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.blue[200]))));
  }

  Widget _passwordTextField(CreateUserProvider provider) {
    return TextFormField(
      autocorrect: false,
      obscureText: true,
      validator: (inputString) {
        return (inputString.length > 0)
            ? null
            : S.of(context).enterValidPassword;
      },
      onSaved: (inputString) {
        provider.password = inputString;
      },
      decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
          prefixIcon: Icon(Icons.lock_sharp),
          hintText: S.of(context).enterYourPassword,
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blue[200]))),
    );
  }

  Widget _nameTextField(CreateUserProvider provider) {
    return TextFormField(
      autocorrect: false,
      validator: (inputString) {
        return _nameRegExp.hasMatch(inputString)
            ? null
            : S.of(context).validNameShouldContainLettersSpacesAndDashes;
      },
      onSaved: (inputString) {
        provider.name = inputString;
      },
      decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
          prefixIcon: Icon(Icons.person),
          hintText: S.of(context).enterYourName,
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blue[200]))),
    );
  }

  Widget _surnameTextField(CreateUserProvider provider) {
    return TextFormField(
      autocorrect: false,
      validator: (inputString) {
        return _nameRegExp.hasMatch(inputString)
            ? null
            : S.of(context).validSurnameShouldContainLettersSpacesAndDashes;
      },
      onSaved: (inputString) {
        provider.surname = inputString;
      },
      decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
          prefixIcon: Icon(Icons.person),
          hintText: S.of(context).enterYourSurname,
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blue[200]))),
    );
  }

  Widget _registerButton(CreateUserProvider provider) {
    return (!this.widget.isLoading)
        ? Container(
            height: 50,
            width: _deviceWidth,
            child: OutlinedButton(
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  provider.onCreateUser(this.widget.onRegisterSuccess, this.widget.onRegisterError);
                }
              },
              style: ButtonStyles.blackOutlinedButtonStyle(),
              child: Text(S.of(context).signUp,
                  style: ButtonTextStyles.blackOutlinedButtonTextStyle()),
            ),
          )
        : Align(
            alignment: Alignment.center, child: CircularProgressIndicator());
  }  
}

