import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class EmailLoginPage extends StatefulWidget{
  final VoidCallback onSignedIn;
  const EmailLoginPage({this.onSignedIn});

  @override
  State<StatefulWidget> createState() => _EmailLoginPageState();
}

class _EmailLoginPageState extends State<EmailLoginPage>{
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _emailErrorText = "";
  String _passwordErrorText = "";
  bool _obscureText = true;
  bool _success;
  String _userEmail;

  void _togglePassword() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future<bool> validateEmail(String value) async {
    //Follows HTML5 email validation, for more info: https://html.spec.whatwg.org/multipage/input.html#e-mail-state-%28type=email%29
    String pattern = r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$";
    RegExp regExp = new RegExp(pattern);
    String errorText = "";

    if(value.isEmpty){
      errorText = "Please enter your e-mail";
    }
    else if(!regExp.hasMatch(value)){
      errorText = "Incorrect e-mail format";
    }
    else{
      //if returned list is empty, this means that the e-mail is not registered
      await _auth.fetchSignInMethodsForEmail(value).then((response){
        print(response);
        response.isEmpty? errorText = "E-mail not registered":errorText = "";
      });
    }

    setState(() {
      _emailErrorText = errorText;
    });

    return(errorText==""?true:false);
  }

  bool validatePassword(String value){
    //min 8 char, 1 upper, 1 lower, 1 number, 1 special char, no length limit
    String pattern = r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$";
    RegExp regExp = new RegExp(pattern);
    String errorText = "";

    if(value.isEmpty){
      errorText = "Please enter your password";
    }
    else if(!regExp.hasMatch(value)){
      errorText = "Password criteria not fulfilled";
    }

    setState(() {
      _passwordErrorText = errorText;
    });

    return(errorText==""?true:false);
  }

  void registrationSuccess(String email, String password){
    _emailController.text = email;
    _passwordController.text = password;
  }

  void _signInWithEmailAndPassword() async {
    User user;
    await _auth.signInWithEmailAndPassword(
      email: _emailController.text,
      password: _passwordController.text,
    ).then((response){
      user = response.user;
    }).catchError((error){
      user = null;
    });

    if (user != null) {
      setState(() {
        _success = true;
        _userEmail = user.email;
      });
      widget.onSignedIn();
      Navigator.of(context).pop();
    } else {
      setState(() {
        _success = false;
      });
    }
  }

  void _registerEmailAndPassword() async {
    Navigator.of(context).push(
      MaterialPageRoute(builder:(context) => EmailRegisterPage(onRegistered: registrationSuccess))
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0,0.0,20.0,0.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    child: const Text('Sign in with Email', style: TextStyle(fontSize: 18.0),),
                    padding: const EdgeInsets.all(16),
                    alignment: Alignment.center,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            errorText:  _emailErrorText,
                          ),
                          onChanged: (String value) {
                            validateEmail(value);
                          },
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            errorText: _passwordErrorText,
                          ),
                          onChanged: (value){
                            validatePassword(value);
                          },
                          obscureText: _obscureText,
                        ),
                      ),
                      RaisedButton(
                        onPressed: _togglePassword,
                        child: Text(_obscureText? "Show" : "Hide")
                      )
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    alignment: Alignment.center,
                    child: RaisedButton(
                      onPressed: () async {
                        if (await validateEmail(_emailController.text) && validatePassword(_passwordController.text)) {
                          _signInWithEmailAndPassword();
                        }
                      },
                      child: const Text('Log in'),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      _success == null
                          ? ''
                          : (_success
                          ? 'Successfully signed in ' + _userEmail
                          : 'Wrong Email or Password'),
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Not yet a user?"),
                      TextButton(
                        onPressed: _registerEmailAndPassword,
                        child: Text("click here to register")
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EmailRegisterPage extends StatefulWidget {
  final Function onRegistered;
  const EmailRegisterPage({this.onRegistered});
  @override
  _EmailRegisterPageState createState() => _EmailRegisterPageState();
}

class _EmailRegisterPageState extends State<EmailRegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _emailErrorText = "";
  String _passwordErrorText = "";
  bool _obscureText = true;
  bool _success;
  String _userEmail;

  void _togglePassword() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future<bool> validateEmail(String value) async {
    //Follows HTML5 email validation, for more info: https://html.spec.whatwg.org/multipage/input.html#e-mail-state-%28type=email%29
    String pattern = r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$";
    RegExp regExp = new RegExp(pattern);
    String errorText = "";

    if(value.isEmpty){
      errorText = "Please enter your e-mail";
    }
    else if(!regExp.hasMatch(value)){
      errorText = "Incorrect e-mail format";
    }
    else{
      //if returned list is empty, this means that the e-mail is not registered
      await _auth.fetchSignInMethodsForEmail(value).then((response){
        response.isEmpty? errorText = "":errorText = "E-mail already exists";
      });
    }

    setState(() {
      _emailErrorText = errorText;
    });

    //return(errorText==""?true:false);
    return true;
  }

  bool validatePassword(String value) {
    //min 8 char, 1 upper, 1 lower, 1 number, 1 special char, no length limit
    String pattern = r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$";
    RegExp regExp = new RegExp(pattern);
    String errorText = "";

    if(value.isEmpty){
      errorText = "Please enter your password";
    }
    else if(!regExp.hasMatch(value)){
      errorText = "Password criteria not fulfilled";
    }

    setState(() {
      _passwordErrorText = errorText;
    });

    return(errorText==""?true:false);
  }

  void _register() async {
    User user;
    await _auth.createUserWithEmailAndPassword(
      email: _emailController.text,
      password: _passwordController.text,
    ).then((response){
      user = response.user;
    }).catchError((error){
      user = null;
    });

    if (user != null) {
      setState(() {
        _success = true;
        _userEmail = user.email;
      });
      widget.onRegistered(_emailController.text,_passwordController.text);
      Navigator.of(context).pop();
    } else {
      setState(() {
        _success = true;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20.0,0.0,20.0,0.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    child: const Text('Register with Email', style: TextStyle(fontSize: 18.0),),
                    padding: const EdgeInsets.all(16),
                    alignment: Alignment.center,
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      errorText: _emailErrorText,
                    ),
                    onChanged: (String value) async {
                      await validateEmail(value);
                    },
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            errorText: _passwordErrorText,
                          ),
                          onChanged: (String value) {
                            validatePassword(value);
                          },
                          obscureText: _obscureText,
                        ),
                      ),
                      RaisedButton(
                          onPressed: _togglePassword,
                          child: Text(_obscureText? "Show" : "Hide")
                      )
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    alignment: Alignment.center,
                    child: RaisedButton(
                      onPressed: () async {
                        if (await validateEmail(_emailController.text) && validatePassword(_passwordController.text)) {
                          _register();
                        }
                      },
                      child: const Text('Register'),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: Text(_success == null
                        ? ''
                        : (_success
                        ? 'Successfully registered ' + _userEmail
                        : 'Registration failed')),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
