import 'package:audionotes/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cupertino_onboarding/cupertino_onboarding.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';


class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});
  @override
  State<OnboardingPage> createState() => onboardingState();
}

class onboardingState extends State<OnboardingPage> {
  @override
  Widget build(BuildContext context) {
    FlutterNativeSplash.remove();
    return CupertinoOnboarding(
      onPressedOnLastPage: () => Navigator.push(context, CupertinoPageRoute<Widget>(builder: (BuildContext context) {return Home();})),
      pages: [
        WhatsNewPage(
          title: const Text("Welcome to Audionotes!"),
          features: const [
            WhatsNewFeature(
              title: Text('Create your first note!'),
              description: Text(
                  'You can begin creating your own Audionotes in the home screen.'),
              icon: Icon(CupertinoIcons.add_circled),
            ),
            WhatsNewFeature(
              title: Text("Record yourself"),
              description: Text(
                  "An audionote requires audio. Record yourself and pause or stop whenever it may seem necessary to. "),
              icon: Icon(Icons.mic),
            ),
            WhatsNewFeature(
              title: Text('And finally, add notes.'),
              description: Text(
                  "And of course, this is not only a voice note app, you can add text to any timestamp you see needs a note."),
              icon: Icon(CupertinoIcons.pencil),
            ),
          ],
        ),
        const CupertinoOnboardingPage(
          title: Text('Support For Multiple Pages'),
          body: Icon(
            CupertinoIcons.square_stack_3d_down_right,
            size: 200,
          ),
        ),
        const CupertinoOnboardingPage(
          title: Text('Great Look in Light and Dark Mode'),
          body: Icon(
            CupertinoIcons.sun_max,
            size: 200,
          ),
        ),
        const CupertinoOnboardingPage(
          title: Text('Beautiful and Consistent Appearance'),
          body: Icon(
            CupertinoIcons.check_mark_circled,
            size: 200,
          ),
        ),
      ],
    );
  }
}