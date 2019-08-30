import 'package:dragger_survey/src/blocs/blocs.dart';
import 'package:dragger_survey/src/styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SigendInUserCircleAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final SignInBloc signInBloc = Provider.of<SignInBloc>(context);
    return FutureBuilder<FirebaseUser>(
        future: signInBloc.currentUser,
        builder: (BuildContext context, AsyncSnapshot<FirebaseUser> snapshot) {
          return GestureDetector(
              onTap: () {
                Scaffold.of(context).openEndDrawer();
              },
              child: Container(
                padding: EdgeInsets.all(8),
                child: CircleAvatar(
                  backgroundColor: Styles.drg_colorDarkerGreen,
                  backgroundImage: snapshot.data != null
                      ? NetworkImage(snapshot.data.photoUrl)
                      : null,
                ),
              ));
        });
  }
}
