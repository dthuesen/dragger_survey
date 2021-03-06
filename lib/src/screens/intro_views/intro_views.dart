import 'dart:developer';

import 'package:dragger_survey/src/blocs/blocs.dart';
import 'package:dragger_survey/src/screens/intro_views/page_model.dart';
import 'package:dragger_survey/src/shared/shared.dart';
import 'package:dragger_survey/src/styles.dart';
import 'package:flutter/material.dart';
import 'package:intro_views_flutter/intro_views_flutter.dart';
import 'package:provider/provider.dart';

class IntroViews extends StatefulWidget {
  @override
  _IntroViewsState createState() => _IntroViewsState();
}

class _IntroViewsState extends State<IntroViews> {
  // bool _showIntroViewsAgain = true;

  @override
  Widget build(BuildContext context) {
    MediaQueryData mq = MediaQuery.of(context);
    IntroViewsBloc introViewsBloc = Provider.of<IntroViewsBloc>(context);

    double mqWidth = mq.size.width;

    final Widget introViews = IntroViewsFlutter(
      [
        teamPage,
        invitePage,
        setPage,
        surveyPage,
        insightsPage,
        readyPage,
      ],
      onTapDoneButton: () async {
        await Navigator.pushNamedAndRemoveUntil(
          context,
          '/surveysetslist',
          (_) => false,
        ); //MaterialPageRoute
      },
      fullTransition: 150,
      columnMainAxisAlignment: MainAxisAlignment.center,
      showNextButton: false,
      showBackButton: false,
      showSkipButton: true,
      doneText: Text(
        "Done",
        style: TextStyle(
          color: Styles.color_Text,
          fontSize: 12.0,
          fontFamily: "Barlow",
        ),
      ),
      pageButtonTextStyles: TextStyle(
        color: Colors.white,
        fontSize: 12.0,
        fontFamily: "Barlow",
      ),
    );

    return Stack(
      children: <Widget>[
        introViews,
        Positioned(
          height: 40,
          width: mqWidth,
          bottom: 70,
          child: SizedBox(
            child: Material(
              color: Styles.color_Primary.withOpacity(0),
              child: FutureBuilder<dynamic>(
                  future: introViewsBloc.getShowIntroViewsValue(),
                  builder: (context, introViewsSnapshot) {
                    if (introViewsSnapshot.connectionState !=
                        ConnectionState.done) {
                      return Loader();
                    }
                    return CheckboxListTile(
                      activeColor: Styles.color_Primary,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text(
                        "Show intro slides again.",
                        style: TextStyle(
                            color: Styles.color_SecondaryDeepDark
                                .withOpacity(.8),
                            fontWeight: FontWeight.w600),
                      ),
                      value: introViewsSnapshot?.data,
                      onChanged: (value) {
                        log("In PageModel 1 - value of onChanged: $value");
                        introViewsBloc.setShowIntroViews(value);
                        log("In PageModel 1 - value of showIntroViewsAgain: ${introViewsBloc.showIntroViews}");
                      },
                    );
                  }),
            ),
          ),
        ),
      ],
    );
  }
}
