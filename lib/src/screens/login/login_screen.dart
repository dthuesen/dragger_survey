import 'dart:developer';

import 'package:dragger_survey/src/blocs/blocs.dart';
import 'package:dragger_survey/src/styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _loggedIn = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        backgroundColor: Styles.color_AppBackground,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Opacity(
                opacity: .73,
                child: SizedBox(
                    height: MediaQuery.of(context).orientation ==
                            Orientation.portrait
                        ? 170
                        : 90,
                    width: double.infinity,
                    child: FlareActor(
                      'assets/dragger_flag_anim.flr',
                      fit: BoxFit.contain,
                      animation: 'dragger-flag-anim',
                    )),
              ),
              SizedBox(
                height:
                    MediaQuery.of(context).orientation == Orientation.portrait
                        ? 180
                        : 140,
                child: Image(
                  image: AssetImage('assets/dragger-logo.png'),
                ),
              ),
              SizedBox(
                height:
                    MediaQuery.of(context).orientation == Orientation.portrait
                        ? 50
                        : 5,
              ),
              buildLoginPart(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLoginPart(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          _loggedIn
              ? Column(
                  children: <Widget>[
                    _openSurveyListButton(context: context),
                    _singOutButton(context: context),
                  ],
                )
              : _singInButton(context: context),
        ],
      ),
    );
  }

  Widget _singInButton({BuildContext context}) {
    final SignInBloc signInBloc = Provider.of<SignInBloc>(context);
    final IntroViewsBloc introViewsBloc = Provider.of<IntroViewsBloc>(context);

    return FutureBuilder<Object>(
        future: introViewsBloc.getShowIntroViewsValue(),
        builder: (context, introViewsValueSnapshot) {
          return OutlineButton(
            splashColor: Styles.color_Secondary,
            onPressed: () async {
              FirebaseUser returnedUser = await signInBloc
                  .signInWithGoogle()
                  .catchError((e) =>
                      print("ERROR in LoginScreen signInwithGoogle: $e "));
              if (returnedUser != null) {
                setState(() {
                  _loggedIn = true;
                });
                signInBloc.createUserInDbIfNotExist(account: returnedUser);
                await Navigator.pushNamedAndRemoveUntil(
                  context,
                  introViewsValueSnapshot.data
                      ? '/introviews'
                      : '/surveysetslist',
                  (_) => false,
                );
              }
            },
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
            highlightElevation: 0,
            borderSide: BorderSide(color: Styles.color_Secondary),
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: Text(
                "Sign-In with Google",
                style:
                    TextStyle(fontSize: 20, color: Styles.color_Secondary),
              ),
            ),
          );
        });
  }

  Widget _openSurveyListButton({BuildContext context}) {
    return OutlineButton(
      splashColor: Styles.color_Secondary,
      onPressed: () {
        Navigator.pushNamed(context, '/surveysetslist');
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      highlightElevation: 0,
      borderSide: BorderSide(color: Styles.color_Secondary),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Open Survey Sets List",
              style: TextStyle(fontSize: 20, color: Styles.color_Secondary),
            )
          ],
        ),
      ),
    );
  }

  Widget _singOutButton({BuildContext context}) {
    final SignInBloc signInBloc = Provider.of<SignInBloc>(context);

    return FlatButton(
      splashColor: Styles.color_Secondary,
      onPressed: () {
        setState(() {
          _loggedIn = false;
        });
        signInBloc.logoutUser();
        Navigator.pushNamed(context, '/login');
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Sign-Out",
              style: TextStyle(fontSize: 20, color: Styles.color_Secondary),
            )
          ],
        ),
      ),
    );
  }
}
