import 'package:flutter/material.dart';

class SignUp extends StatefulWidget{
    @override 
    _SignUpState createState() => new _SignUpState();
}

class _SignUpState extends State<SignUp>{

    String _email, _password;
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    @override 
    Widget build(BuildContext context){
        return Scaffold(
            body: Form (
                key: _formKey,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,                    
                    children: <Widget>[
                        Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.all(10),
                            child:Text(
                                'SignIn Page',
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.blue,
                                    ),//Style
                                ),//Text
                        ),
                        TextFormField(
                            validator: (input){
                                if(input.isEmpty){
                                    return 'Please type an email id';
                                }
                            },
                            onSaved: (input) => _email = input,
                            decoration: InputDecoration(
                            labelText: 'Email'
                            ),//Input Decoration
                        ),
                        TextFormField(
                            validator: (input){
                                if(input.length < 6){
                                    return 'Your password needs to be atleast 6 characters';
                                }
                            },
                            onSaved: (input) => _password = input,
                            decoration: InputDecoration(
                            labelText: 'Password'
                            ),//InputDecoration
                            obscureText: true,
                        ),// Password textform field
                        RaisedButton(
                                onPressed: (){},
                                    child: Text('Sign in'),
                        )
                    ],
                ),
            ),
        ); //Scafflod
    }
    void SignIn(){
        final formState = _formKey.currentState;
        if(formState.validate()){
            //TODO functions
        }
    }
}