import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:ptw_live_tracking_rider/advanced/app.dart';
import 'package:ptw_live_tracking_rider/models/ModelProvider.dart';

import 'amplifyconfiguration.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _configureAmplify();
  runApp(const GeolocationApp());
}

Future<void> _configureAmplify() async {
  try {
    // Create the API plugin
    //
    final api = AmplifyAPI(
      options: APIPluginOptions(modelProvider: ModelProvider.instance),
    );

    // Add the plugins
    await Amplify.addPlugins([api]);
    await Amplify.configure(amplifyconfig);

    safePrint('Successfully configured');
  } on AmplifyAlreadyConfiguredException {
    safePrint(
        'Tried to reconfigure Amplify; this can occur when your app restarts on Android.');
  } on Exception catch (e) {
    safePrint('Error configuring Amplify: $e');
  }
}
