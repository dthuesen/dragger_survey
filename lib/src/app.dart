import 'package:dragger_survey/src/screens/dragger_screen.dart';
import 'package:dragger_survey/src/screens/splash_screen.dart';
import 'package:dragger_survey/src/screens/survey_set_details_screen.dart';
import 'package:dragger_survey/src/screens/survey_set_scaffold_screen.dart';
import 'package:dragger_survey/src/screens/survey_sets_list_screen.dart';
import 'package:dragger_survey/src/screens/login_screen.dart';
import 'package:dragger_survey/src/screens/profile_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:dragger_survey/src/styles.dart';
import 'blocs/blocs.dart';

class App extends StatelessWidget {
  final navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provider<FirebaseAuthService>(
        //   builder: (_) => FirebaseAuthService(),
        // ),
        ChangeNotifierProvider<SignInBloc>.value(
          value: SignInBloc(),
        ),
        ChangeNotifierProvider<MatrixGranularityBloc>.value(
          value: MatrixGranularityBloc(),
        ),
        ChangeNotifierProvider<DraggableItemBloc>.value(
          value: DraggableItemBloc(),
        ),
        ChangeNotifierProvider<PrismSurveyBloc>.value(
          value: PrismSurveyBloc(),
        ),
        ChangeNotifierProvider<FabBloc>.value(
          value: FabBloc(),
        )
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/draggerboard':
              return PageTransition(
                duration: Duration(milliseconds: 400),
                child: DraggerScreen(),
                type: PageTransitionType.downToUp,
              );
              break;
            case '/surveysetslist':
              return PageTransition(
                duration: Duration(milliseconds: 400),
                child: SurveySetsListScreen(),
                type: PageTransitionType.fade,
              );
              break;
            case '/surveysetscaffold':
              return PageTransition(
                duration: Duration(milliseconds: 400),
                child: SurveySetScaffoldScreen(),
                type: PageTransitionType.fade,
              );
              break;
            case '/home':
              return PageTransition(
                duration: Duration(milliseconds: 400),
                child: SurveySetsListScreen(),
                type: PageTransitionType.fade,
              );
              break;
            case '/login':
              return PageTransition(
                duration: Duration(milliseconds: 400),
                child: LoginScreen(),
                type: PageTransitionType.fade,
              );
              break;
            case '/profile':
              return PageTransition(
                duration: Duration(milliseconds: 400),
                child: ProfileScreen(),
                type: PageTransitionType.fade,
              );
              break;
            case '/surveysetdetails':
              return PageTransition(
                duration: Duration(milliseconds: 400),
                child: SurveySetDetailsScreen(),
                type: PageTransitionType.fade,
              );
              break;
            case '/draggerboard':
              return PageTransition(
                duration: Duration(milliseconds: 400),
                child: DraggerScreen(),
                type: PageTransitionType.fade,
              );
              break;
            case '/surveysethowtoscreen':
              return PageTransition(
                duration: Duration(milliseconds: 400),
                child: DraggerScreen(),
                type: PageTransitionType.fade,
              );
              break;
            default:
              return null;
          }
        },
        routes: {
          '/home': (context) => SurveySetsListScreen(),
          '/login': (context) => LoginScreen(),
          '/profile': (context) => ProfileScreen(),
          '/draggerboard': (context) => DraggerScreen(),
        },
        theme: ThemeData(
          fontFamily: 'Nunito',
          bottomAppBarTheme: BottomAppBarTheme(color: Styles.colorGreen),
          accentColor: Colors.orangeAccent[300],
          primaryColor: Colors.orange.shade700,
          textTheme: TextTheme(
            body1: TextStyle(fontSize: 18),
            body2: TextStyle(fontSize: 16),
            button: TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.bold),
            headline: TextStyle(fontWeight: FontWeight.bold),
            subhead: TextStyle(color: Colors.grey),
          ),
          buttonTheme: ButtonThemeData(),
        ),
        home: SplashScreen(),
      ),
    );
  }
}
