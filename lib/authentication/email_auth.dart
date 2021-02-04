import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
const bool verifyEmail = true;
const String passwordReq =
    "Passwords must have:\n"
    "1.Minimum 8 characters\n"
    "2.At least 1 uppercase character\n"
    "3.At least 1 lowercase character\n"
    r"4.One special character eg.(@$!%*?&)";

class EmailLoginPage extends StatefulWidget{
  final VoidCallback onSignedIn;
  const EmailLoginPage({this.onSignedIn});

  @override
  State<StatefulWidget> createState() => _EmailLoginPageState();
}
class _EmailLoginPageState extends State<EmailLoginPage>{
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _emailErrorText = "";
  String _passwordErrorText = "";
  String _snackbarText = "";
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
    FocusScope.of(context).unfocus();
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
    
    if(verifyEmail){
      if (user != null && await checkEmailVerification(context)) {
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
    else{
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
  }

  void _registerEmailAndPassword() async {
    Navigator.of(context).push(
      MaterialPageRoute(builder:(context) => EmailRegisterPage(onRegistered: registrationSuccess))
    );
  }

  void resetSuccess(String email, String snackbarText){
    _emailController.text = email;
    FocusScope.of(context).unfocus();
    _snackbarText = snackbarText;
  }

  void _resetPassword() async {
    if(await resetEmailPassword(context,onReset: resetSuccess, email: _emailController.text)){
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          duration: Duration(seconds: 3),
          content: Text(_snackbarText),
          action: SnackBarAction(
            label: 'Ok',
            onPressed: () {
              _scaffoldKey.currentState.removeCurrentSnackBar();
            },
          ),
        )
      );
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
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Column(
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
                              _emailErrorText = "verifying...";
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
                        Tooltip(
                          child: IconButton(
                            icon: Icon(Icons.info, size: 20.0)
                          ),
                          message: passwordReq,
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
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: _resetPassword,
                            child: Text("Forgot Password?")
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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

    if(verifyEmail){
      if (user != null && await checkEmailVerification(context)) {
        setState(() {
          _success = true;
          _userEmail = user.email;
        });
        widget.onRegistered(_emailController.text,_passwordController.text);
        Navigator.of(context).pop();
      } else {
        setState(() {
          _success = false;
        });
      }
    }
    else{
      if (user != null) {
        setState(() {
          _success = true;
          _userEmail = user.email;
        });
        widget.onRegistered(_emailController.text,_passwordController.text);
        Navigator.of(context).pop();
      } else {
        setState(() {
          _success = false;
        });
      }
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
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Padding(
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
                        _emailErrorText = "verifying...";
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
                        Tooltip(
                          child: IconButton(
                              icon: Icon(Icons.info, size: 20.0)
                          ),
                          message: passwordReq,
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
      ),
    );
  }
}

Future checkEmailVerification(BuildContext context) {
  return showCupertinoDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return EmailVerification();
    }
  );
}
class EmailVerification extends StatefulWidget {
  @override
  _EmailVerificationState createState() => _EmailVerificationState();
}
class _EmailVerificationState extends State<EmailVerification> {
  Timer _emailVerifierTimer;
  Timer _resendTimer;
  final _resendDuration = 60;
  int _resendCountdown;
  bool _resendReady = false;
  String _userEmail;

  Future checkIfEmailVerified() async {
    _emailVerifierTimer = Timer.periodic(Duration(seconds: 3), (timer) async {
      await _auth.currentUser.reload();
      if(_auth.currentUser.emailVerified){
        Navigator.of(context).pop(true);
      }
    });
  }

  void sendEmailVerification() async {
    await _auth.currentUser.reload();
    if(!_auth.currentUser.emailVerified){
      await _auth.currentUser.sendEmailVerification();
      _resendCountdown = _resendDuration;
      _resendTimer = new Timer.periodic(Duration(seconds: 1),(timer) async {
        if(_resendCountdown == 0){
          setState(() {
            _resendTimer.cancel();
            _resendReady = true;
          });
        }
        else{
          setState(() {
            _resendCountdown -= 1;
          });
        }
      });
      setState(() {
        _resendReady = false;
      });
    }
    else{
      Navigator.of(context).pop(true);
    }
  }

  @override
  void initState() {
    super.initState();
    _userEmail = _auth.currentUser.email;
    sendEmailVerification();
    checkIfEmailVerified();
  }

  @override
  void dispose() {
    if(_emailVerifierTimer != null){
      _emailVerifierTimer.cancel();
    }
    if(_resendTimer != null){
      _resendTimer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Stack(
        children: [
          Positioned(
              right: 0.0,
              child: GestureDetector(
                  onTap: (){
                    Navigator.of(context).pop(false);
                  },
                  child: Align(
                      alignment: Alignment.topRight,
                      child: CircleAvatar(
                        radius: 14.0,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.close, color: Colors.grey),
                      )
                  )
              )
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0.0,10.0,0.0,10.0),
                child: Center(child:Text('Verifying your E-mail',style: TextStyle(fontSize: 24.0))),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0.0,10.0,0.0,10.0),
                child: Center(child: Text("A verification link has been sent to $_userEmail", textAlign: TextAlign.center,)),
              ),
              RaisedButton(
                onPressed: _resendReady?sendEmailVerification:null,
                child: Text("Resend Verification")
              ),
              _resendReady?Text(""):Center(child: Text("You can resend in $_resendCountdown", style: TextStyle(fontSize:10.0, color: Colors.red)))
            ],
          ),
        ]
      )
    );
  }
}

Future resetEmailPassword(BuildContext context, {Function onReset, String email}) {
  return showCupertinoDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context){
      return EmailResetPassword(onReset: onReset, email: email,);
    }
  );
}
class EmailResetPassword extends StatefulWidget {
  final Function onReset;
  final String email;
  const EmailResetPassword({this.onReset, this.email});
  @override
  _EmailResetPasswordState createState() => _EmailResetPasswordState();
}
class _EmailResetPasswordState extends State<EmailResetPassword> {
  final TextEditingController _emailController = TextEditingController();
  String _emailErrorText = "";

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
        response.isEmpty? errorText = "E-mail not registered":errorText = "";
      });
    }

    setState(() {
      _emailErrorText = errorText;
    });

    return(errorText==""?true:false);
  }

  void _resetPassword() async {
    String snackbarText = "";
    await _auth.sendPasswordResetEmail(email: _emailController.text).then((val){
      snackbarText = "A verification email has been sent to ${_emailController.text}";
    }).catchError((error){
      snackbarText = error;
    });
    widget.onReset(_emailController.text,snackbarText);
    Navigator.of(context).pop(true);
  }

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.email;
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        content: Stack(
          children: [
            Positioned(
                right: 0.0,
                child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop(false);
                    },
                    child: Align(
                        alignment: Alignment.topRight,
                        child: CircleAvatar(
                          radius: 14.0,
                          backgroundColor: Colors.white,
                          child: Icon(
                              Icons.close, color: Colors.grey),
                        )
                    )
                )
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      0.0, 20.0, 0.0, 10.0),
                  child: Center(child: Text('Reset your\npassword',
                      style: TextStyle(fontSize: 24.0))),
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    errorText: _emailErrorText,
                  ),
                  onChanged: (String value) {
                    _emailErrorText = "verifying...";
                    validateEmail(value);
                  },
                ),
                RaisedButton(
                  onPressed: _emailErrorText == ""
                      ? _resetPassword
                      : null,
                  child: Text("Reset"),
                ),
              ],
            ),
          ],
        )
    );
  }
}

