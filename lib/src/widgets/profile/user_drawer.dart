import 'dart:developer';

import 'package:dragger_survey/src/shared/utils.dart';
import 'package:dragger_survey/src/blocs/blocs.dart';
import 'package:dragger_survey/src/screens/screens.dart';
import 'package:dragger_survey/src/styles.dart';
import 'package:dragger_survey/src/widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class UserDrawer extends StatefulWidget {
  const UserDrawer({
    Key key,
  }) : super(key: key);

  @override
  _UserDrawerState createState() => _UserDrawerState();
}

class _UserDrawerState extends State<UserDrawer> {
  @override
  Widget build(BuildContext context) {
    final SignInBloc signInBloc = Provider.of<SignInBloc>(context);
    final IntroViewsBloc introViewsBloc =
        Provider.of<IntroViewsBloc>(context, listen: false);
    final MediaQueryData mq = MediaQuery.of(context);
    final double mqHeight = mq.size.height;
    final bool mqIsPortrait = mq.orientation == Orientation.portrait;

    if (signInBloc.currentUser == null) {
      log("In user_drawer not currentUser data");
      Navigator.pushReplacement(
          context,
          PageTransition(
            curve: Curves.easeIn,
            duration: Duration(milliseconds: 200),
            type: PageTransitionType.fade,
            child: SplashScreen(),
          ));
    }

    log("in UserDrawer - random string: ${Utils.createCryptoRandomString(4)}");

    return FutureBuilder<FirebaseUser>(
      future: signInBloc.currentUser,
      builder:
          (BuildContext context, AsyncSnapshot<FirebaseUser> signInSnapshot) {
        if (signInSnapshot.connectionState != ConnectionState.done) {
          return Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: 50),
              child: AspectRatio(
                aspectRatio: 1,
                child: CircularProgressIndicator(
                  strokeWidth: 10,
                ),
              ),
            ),
          );
        }

        return Drawer(
          elevation: 10,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              DrawerHeader(
                // padding:
                //     EdgeInsets.only(top: 8, left: 16, right: 10, bottom: 0),
                child: Container(
                  alignment: Alignment.topLeft,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Expanded(
                        flex: 4,
                        child: SizedBox(
                          child: Column(
                            children: <Widget>[
                              SizedBox(
                                height: mqIsPortrait
                                    ? mqHeight * .1
                                    : mqHeight * .2,
                                width: mqIsPortrait
                                    ? mqHeight * .1
                                    : mqHeight * .2,
                                child: SignedInUserCircleAvatar(
                                  radiusSmall: 30,
                                ),
                              ),
                              Text(
                                '${signInSnapshot.data.displayName}',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Spacer(
                        flex: 1,
                      ),
                      Expanded(
                        flex: 3,
                        child: QrImage(
                          data:
                              "${signInSnapshot.data.displayName}; ${Utils.createCryptoRandomString(2)}${signInSnapshot.data.uid}${Utils.createCryptoRandomString(2)}",
                        ),
                      ),
                    ],
                  ),
                ),
                decoration: BoxDecoration(
                  color: Styles.color_Primary.withAlpha(100),
                ),
              ),
              SizedBox(
                height: mqHeight * .4,
                child: ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.all(0),
                  children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.account_circle),
                      title: Text('Profil settings'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/profile');
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.people),
                      title: Text('Manage Teams'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/teams');
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.description),
                      title: Text('How-To'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/howto');
                      },
                    ),
                    Consumer<IntroViewsBloc>(
                      builder: (BuildContext context, introViews, child) {
                        return ListTile(
                          leading: introViewsBloc.showIntroViews
                              ? Icon(Icons.check_box)
                              : Icon(Icons.check_box_outline_blank),
                          title: Text('Introviews'),
                          onTap: () {
                            bool currentValue = introViews.showIntroViews;
                            bool newValue = currentValue ? false : true;
                            introViews.setShowIntroViews(newValue);
                            // Navigator.pop(context);
                            // Navigator.pushNamed(context, '/howto');
                          },
                        );
                      },
                      // child: ListTile(
                      //   leading: introViewsBloc.showIOntroViews
                      //       ? Icon(Icons.check_box)
                      //       : Icon(Icons.check_box_outline_blank),
                      //   title: Text('Introviews'),
                      //   onTap: () {
                      //     bool currentValue = introViewsBloc.showIOntroViews;
                      //     bool newValue = currentValue ? false : true;
                      //     introViewsBloc.setShowIntroViews(newValue);
                      //     // Navigator.pop(context);
                      //     // Navigator.pushNamed(context, '/howto');
                      //   },
                      // ),
                    ),
                    ListTile(
                      leading: Icon(Icons.cancel),
                      title: Text('Sign-Out'),
                      onTap: () {
                        Navigator.pop(context, true);
                        Navigator.pushNamed(context, '/login');
                        signInBloc.logoutUser();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
