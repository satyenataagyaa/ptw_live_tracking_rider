// ignore_for_file: constant_identifier_names

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:ptw_live_tracking_rider/models/ModelProvider.dart';
import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
//     as bg;
// import 'package:background_fetch/background_fetch.dart';
// import 'package:http/http.dart' as http;

// import '../app.dart';
// import '../config/env.dart';
import 'map_view.dart';
import 'event_list.dart';
// import './util/dialog.dart' as util;
// import './util/test.dart';

import 'shared_events.dart';

// For pretty-printing location JSON
JsonEncoder encoder = const JsonEncoder.withIndent("    ");

/// The main home-screen of the AdvancedApp.  Builds the Scaffold of the App.
///
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State createState() => HomeViewState();
}

class HomeViewState extends State<HomeView>
    with TickerProviderStateMixin<HomeView>, WidgetsBindingObserver {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  TabController? _tabController;
  final StreamController<Location> _locationController =
      StreamController<Location>();

  // bool? _isMoving;
  bool? _enabled;
  // String? _motionActivity;
  // String? _odometer;
  // int? _batteryLevel;
  StreamSubscription<GraphQLResponse<Location>>? subscription;

  late void Function() _disableMapTracking;

  // DateTime? _lastRequestedTemporaryFullAccuracy;

  List<Event> events = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    // _isMoving = false;
    _enabled = false;
    // _motionActivity = 'UNKNOWN';
    // _odometer = '0';
    // _batteryLevel = 0;

    _tabController = TabController(length: 2, initialIndex: 0, vsync: this);
    _tabController?.addListener(_handleTabChange);

    // initPlatformState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("[home_view didChangeAppLifecycleState] : $state");
    // if (state == AppLifecycleState.paused) {
    //   // Do nothing.
    //   /* For testing location access in background on Android 12.
    //   new Timer(Duration(seconds: 21), () async {
    //     var location = await bg.BackgroundGeolocation.getCurrentPosition();
    //     print("************ [location] $location");
    //   });
    //   */
    // } else if (state == AppLifecycleState.resumed) {
    //   if (!_enabled!) return;

    //   DateTime now = DateTime.now();
    //   var _lastRequestedTemporaryFullAccuracy =
    //       this._lastRequestedTemporaryFullAccuracy;
    //   if (_lastRequestedTemporaryFullAccuracy != null) {
    //     Duration dt = _lastRequestedTemporaryFullAccuracy.difference(now);
    //     if (dt.inSeconds < 10) return;
    //   }
    //   _lastRequestedTemporaryFullAccuracy = now;
    //   bg.BackgroundGeolocation.requestTemporaryFullAccuracy("DemoPurpose");
    // }
  }

  // void initPlatformState() async {
  //   SharedPreferences prefs = await _prefs;
  //   String? orgname = prefs.getString("orgname");
  //   String? username = prefs.getString("username");

  //   // Sanity check orgname & username:  if invalid, go back to HomeApp to re-register device.
  //   if (orgname == null || username == null) {
  //     return runApp(const HomeApp());
  //   }

  //   _configureBackgroundGeolocation(orgname, username);
  //   _configureBackgroundFetch();
  // }

  Future<void> subscribe() async {
    const field = 'subscribe';
    const graphQLDocument = '''
      subscription subscribe(\$tripId: String!) {
        $field(tripId: \$tripId) {
          tripId
          latitude
          longitude
        }
      }
     ''';
    final subscriptionRequest = GraphQLRequest<Location>(
      document: graphQLDocument,
      modelType: Location.classType,
      variables: <String, dynamic>{
        'tripId': '12345',
      },
      decodePath: field,
    );
    final Stream<GraphQLResponse<Location>> operation = Amplify.API.subscribe(
      subscriptionRequest,
      onEstablished: () => safePrint('Subscription established'),
    );
    subscription = operation.listen(
      (event) {
        // safePrint('Subscription event data received: ${event.data}');
        _locationController.sink.add(event.data!);
      },
      onError: (Object e) => safePrint('Error in subscription stream: $e'),
    );
  }

  void unsubscribe() {
    subscription?.cancel();
    subscription = null;
  }

  // void _configureBackgroundGeolocation(orgname, username) async {
  //   // 1.  Listen to events (See docs for all 13 available events).
  //   bg.BackgroundGeolocation.onLocation(_onLocation, _onLocationError);
  //   bg.BackgroundGeolocation.onMotionChange(_onMotionChange);
  //   bg.BackgroundGeolocation.onActivityChange(_onActivityChange);
  //   bg.BackgroundGeolocation.onProviderChange(_onProviderChange);
  //   bg.BackgroundGeolocation.onHttp(_onHttp);
  //   bg.BackgroundGeolocation.onConnectivityChange(_onConnectivityChange);
  //   bg.BackgroundGeolocation.onHeartbeat(_onHeartbeat);
  //   bg.BackgroundGeolocation.onGeofence(_onGeofence);
  //   bg.BackgroundGeolocation.onSchedule(_onSchedule);
  //   bg.BackgroundGeolocation.onPowerSaveChange(_onPowerSaveChange);
  //   bg.BackgroundGeolocation.onEnabledChange(_onEnabledChange);
  //   bg.BackgroundGeolocation.onNotificationAction(_onNotificationAction);

  //   bg.BackgroundGeolocation.onAuthorization((bg.AuthorizationEvent event) {
  //     print("********************** Authorization: $event");
  //   });

  //   bg.TransistorAuthorizationToken token =
  //       await bg.TransistorAuthorizationToken.findOrCreate(
  //           orgname, username, ENV.TRACKER_HOST);

  //   // 2.  Configure the plugin
  //   bg.BackgroundGeolocation.ready(bg.Config(
  //     reset:
  //         false, // <-- lets the Settings screen drive the config rather than re-applying each boot.
  //     // Convenience option to automatically configure the SDK to post to Transistor Demo server.
  //     transistorAuthorizationToken: token,
  //     // Logging & Debug
  //     debug: true,
  //     logLevel: bg.Config.LOG_LEVEL_VERBOSE,
  //     // Geolocation options
  //     // desiredAccuracy: bg.Config.DESIRED_ACCURACY_NAVIGATION,
  //     desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
  //     // distanceFilter: 10.0,
  //     // Activity recognition options
  //     stopTimeout: 5,
  //     backgroundPermissionRationale: bg.PermissionRationale(
  //         title:
  //             "Allow {applicationName} to access this device's location even when the app is closed or not in use.",
  //         message:
  //             "This app collects location data to enable recording your trips to work and calculate distance-travelled.",
  //         positiveAction: 'Change to "{backgroundPermissionOptionLabel}"',
  //         negativeAction: 'Cancel'),
  //     // HTTP & Persistence
  //     autoSync: true,
  //     // autoSync: false,
  //     // Application options
  //     foregroundService: true,
  //     stopOnTerminate: false,
  //     startOnBoot: true,
  //     enableHeadless: true,
  //     heartbeatInterval: 60,
  //   )).then((bg.State state) async {
  //     print('[ready] ${state.toMap()}');
  //     print('[didDeviceReboot] ${state.didDeviceReboot}');
  //     if (state.schedule!.isNotEmpty) {
  //       bg.BackgroundGeolocation.startSchedule();
  //     }
  //     var destroyed = await bg.BackgroundGeolocation.destroyLocations();
  //     print('Locations destroyed: $destroyed');
  //     setState(() {
  //       _enabled = state.enabled;
  //       _isMoving = state.isMoving;
  //     });
  //   }).catchError((error) {
  //     print('[ready] ERROR: $error');
  //   });

  //   // Fetch currently selected tab.
  //   SharedPreferences prefs = await _prefs;
  //   int? tabIndex = prefs.getInt("tabIndex");

  //   // Which tab to view?  MapView || EventList.   Must wait until after build before switching tab or bad things happen.
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     if (tabIndex != null) {
  //       _tabController?.animateTo(tabIndex);
  //     }
  //   });
  // }

  // Configure BackgroundFetch (not required by BackgroundGeolocation).
  // void _configureBackgroundFetch() async {
  //   BackgroundFetch.configure(
  //       BackgroundFetchConfig(
  //           minimumFetchInterval: 15,
  //           startOnBoot: true,
  //           stopOnTerminate: false,
  //           enableHeadless: true,
  //           requiresStorageNotLow: false,
  //           requiresBatteryNotLow: false,
  //           requiresCharging: false,
  //           requiresDeviceIdle: false,
  //           requiredNetworkType: NetworkType.NONE), (String taskId) async {
  //     print("[BackgroundFetch] received event $taskId");
  //     bg.Logger.debug("🔔 [BackgroundFetch start] " + taskId);
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     int count = 0;
  //     if (prefs.get("fetch-count") != null) {
  //       count = prefs.getInt("fetch-count")!;
  //     }
  //     prefs.setInt("fetch-count", ++count);
  //     print('[BackgroundFetch] count: $count');

  //     if (taskId == 'flutter_background_fetch') {
  //       try {
  //         // Fetch current position
  //         var location = await bg.BackgroundGeolocation.getCurrentPosition(
  //             samples: 2,
  //             maximumAge: 1000 * 10, // 30 seconds ago
  //             timeout: 30,
  //             desiredAccuracy: 40,
  //             extras: {"event": "background-fetch", "headless": false});
  //         print("[location] $location");
  //       } catch (error) {
  //         print("[location] ERROR: $error");
  //       }

  //       // Test scheduling a custom-task in fetch event.
  //       BackgroundFetch.scheduleTask(TaskConfig(
  //           taskId: "com.transistorsoft.customtask",
  //           delay: 5000,
  //           periodic: false,
  //           forceAlarmManager: false,
  //           stopOnTerminate: false,
  //           enableHeadless: true));
  //     }
  //     bg.Logger.debug("🔔 [BackgroundFetch finish] " + taskId);
  //     BackgroundFetch.finish(taskId);
  //   });
  // }

  // void _onClickEnable(enabled) async {
  //   bg.BackgroundGeolocation.playSound(util.Dialog.getSoundId("BUTTON_CLICK"));
  //   if (enabled) {
  //     bg.State state = await bg.BackgroundGeolocation.state;
  //     if (state.trackingMode == 1) {
  //       state = await bg.BackgroundGeolocation.start();
  //     } else {
  //       state = await bg.BackgroundGeolocation.startGeofences();
  //     }
  //     print('[start] success: $state');
  //     setState(() {
  //       _enabled = state.enabled;
  //       _isMoving = state.isMoving;
  //     });
  //   } else {
  //     bg.State state = await bg.BackgroundGeolocation.stop();
  //     print('[stop] success: $state');
  //     setState(() {
  //       _enabled = state.enabled;
  //       _isMoving = state.isMoving;
  //     });
  //   }
  // }
  void _onClickEnable(enabled) async {
    if (enabled) {
      subscribe();
    } else {
      unsubscribe();
      _disableMapTracking();
    }
    setState(() {
      _enabled = enabled;
    });
  }

  // Manually toggle the tracking state:  moving vs stationary
  // void _onClickChangePace() {
  //   setState(() {
  //     _isMoving = !_isMoving!;
  //   });
  //   print("[onClickChangePace] -> $_isMoving");

  //   bg.BackgroundGeolocation.changePace(_isMoving!).then((bool isMoving) {
  //     print('[changePace] success $isMoving');
  //   }).catchError((e) {
  //     print('[changePace] ERROR: ' + e.code.toString());
  //   });
  // }

  // Manually fetch the current position.
  void _onClickGetCurrentPosition() async {
    // bg.BackgroundGeolocation.playSound(util.Dialog.getSoundId("BUTTON_CLICK"));

    // bg.BackgroundGeolocation.getCurrentPosition(
    //     persist: true, // <-- do not persist this location
    //     desiredAccuracy: 40, // <-- desire an accuracy of 40 meters or less
    //     maximumAge: 5000, // <-- Up to 10s old is fine.
    //     timeout: 30, // <-- wait 30s before giving up.
    //     samples: 3, // <-- sample just 1 location
    //     extras: {"getCurrentPosition": true}).then((bg.Location location) {
    //   print('[getCurrentPosition] - $location');
    // }).catchError((error) {
    //   print('[getCurrentPosition] ERROR: $error');
    // });
  }

  ////
  // Event handlers
  //

  // void _onLocation(bg.Location location) async {
  //   print('[${bg.Event.LOCATION}] - $location');

  //   await _handleLocation(location);

  //   setState(() {
  //     events.insert(0, Event(bg.Event.LOCATION, location, location.toString()));
  //     _odometer = (location.odometer / 1000.0).toStringAsFixed(1);
  //   });
  // }

  // Future<void> _handleLocation(bg.Location location) async {
  //   var count = await bg.BackgroundGeolocation.count;
  //   print('Number of buffered locations: $count');
  //   if (count > 0) {
  //     final locations = await bg.BackgroundGeolocation.locations;
  //     locations.sort((a, b) {
  //       var adate = DateTime.parse(a['timestamp']);
  //       var bdate = DateTime.parse(b['timestamp']);
  //       return adate.compareTo(bdate);
  //     });
  //     for (Map<dynamic, dynamic> l in locations) {
  //       bg.Location loc = bg.Location(l);
  //       await publishLocation(loc);
  //       await bg.BackgroundGeolocation.destroyLocation(loc.uuid);
  //     }
  //   }

  //   // await bg.BackgroundGeolocation.destroyLocations();
  //   count = await bg.BackgroundGeolocation.count;
  //   print('Number of buffered locations after handling: $count');
  // }

  // void _onLocationError(bg.LocationError error) {
  //   print('[${bg.Event.LOCATION}] ERROR - $error');
  //   setState(() {
  //     events.insert(
  //         0, Event(bg.Event.LOCATION + " error", error, error.toString()));
  //   });
  // }

  // void _onMotionChange(bg.Location location) {
  //   print('[${bg.Event.MOTIONCHANGE}] - $location');

  //   setState(() {
  //     events.insert(
  //         0, Event(bg.Event.MOTIONCHANGE, location, location.toString()));
  //     _isMoving = location.isMoving;
  //   });
  // }

  // void _onEnabledChange(bool enabled) {
  //   print('[${bg.Event.ENABLEDCHANGE}] - $enabled');
  //   setState(() {
  //     _enabled = enabled;
  //     events.clear();
  //     events.insert(
  //         0,
  //         Event(bg.Event.ENABLEDCHANGE, enabled,
  //             '[EnabledChangeEvent enabled: $enabled]'));
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PTW Rider'),
        centerTitle: true,
        backgroundColor: Colors.amberAccent,
        foregroundColor: Colors.black,
        actions: <Widget>[
          Switch(value: _enabled!, onChanged: _onClickEnable),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.red,
          tabs: const [
            Tab(icon: Icon(Icons.map)),
            Tab(icon: Icon(Icons.list)),
          ],
        ),
      ),
      //body: body,
      body: SharedEvents(
        events: events,
        child: TabBarView(
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            MapView(
              locationController: _locationController,
              mapBuilder: (context, onDisable) {
                _disableMapTracking = onDisable;
              },
            ),
            const EventList(),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
          color: Colors.amberAccent,
          child: Container(
              padding: const EdgeInsets.only(left: 5.0, right: 5.0),
              child: const Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    // IconButton(
                    //   icon: const Icon(Icons.gps_fixed),
                    //   onPressed: _onClickGetCurrentPosition,
                    // ),
                    // TextButton(
                    //     onPressed: _onClickTestMode,
                    //     style: ButtonStyle(
                    //         foregroundColor:
                    //             MaterialStateProperty.all<Color>(Colors.black)),
                    //     child: Text('$_motionActivity · $_odometer km')),
                    // MaterialButton(
                    //     minWidth: 50.0,
                    //     color: (_isMoving!) ? Colors.red : Colors.green,
                    //     onPressed: _onClickChangePace,
                    //     child: Icon(
                    //         (_isMoving!) ? Icons.pause : Icons.play_arrow,
                    //         color: Colors.white))
                  ]))),
    );
  }

  @override
  void dispose() {
    unsubscribe();
    _locationController.close();
    _tabController?.removeListener(_handleTabChange);
    _tabController?.dispose();
    super.dispose();

    // bg.BackgroundGeolocation.setOdometer(0.0).catchError((error) {
    //   print('************ dispose [setOdometer] ERROR $error');
    // });
  }

  void _handleTabChange() async {
    if (!_tabController!.indexIsChanging) {
      return;
    }
    final SharedPreferences prefs = await _prefs;
    prefs.setInt("tabIndex", _tabController!.index);
  }
}
