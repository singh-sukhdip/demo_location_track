import 'dart:async';

import 'package:demo_location_track/controller.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: GetxLocationTrackView(),
    );
  }
}

class GetxLocationTrackView extends StatelessWidget {
  GetxLocationTrackView({super.key});
  final controller = Get.put(LocationController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Center(
              child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Obx(() {
            if (controller.status.value == ServiceStatus.disabled) {
              return const LocationServiceDisabledWidget();
            } else if (controller.status.value == ServiceStatus.enabled) {
              return LocationServiceEnabledWidget(
                controller: controller,
              );
            }
            return const Text('nothing to show');
          }),
        ],
      ))),
    );
  }
}

class LocationTrackView extends StatefulWidget {
  const LocationTrackView({super.key});

  @override
  State<LocationTrackView> createState() => _LocationTrackViewState();
}

class _LocationTrackViewState extends State<LocationTrackView> {
  late StreamController<ServiceStatus> serviceStatusController;
  late ServiceStatus serviceStatus;
  // late ServiceStatus initialStreamData;
  @override
  void initState() {
    super.initState();
    //locationServiceStatusStream = getLocationServiceStatusStream();
    // initialStreamData = await locationServiceStatusStream.first;
    serviceStatusController = StreamController();
    serviceStatusController.addStream(getLocationServiceStatusStream());
    serviceStatusController.stream.listen((event) {});
    serviceStatus = ServiceStatus.disabled;
  }

  @override
  void dispose() {
    //locationServiceStatusStream.
    serviceStatusController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: StreamBuilder(
          // initialData: initialStreamData,
          //stream: locationServiceStatusStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              // print(snapshot.data.toString());
              // if (snapshot.data == ServiceStatus.enabled) {
              //   return const LocationServiceEnabledWidget();
              // } else if (snapshot.data == ServiceStatus.disabled) {
              //   return const LocationServiceDisabledWidget();
              // }
            }
            if (snapshot.hasError) {
              return Text(
                  'Error occur while fetching location service status ${snapshot.error.toString()}');
            }
            return const Text('nothing to show');
          },
        ),
      ),
    );
  }

  Stream<ServiceStatus> getLocationServiceStatusStream() async* {
    yield* Geolocator.getServiceStatusStream();
  }
}

class LocationException implements Exception {
  String message;
  LocationException(this.message);
}

class ServiceDisabledException extends LocationException {
  ServiceDisabledException(super.message);
}

class LocationDeniedException extends LocationException {
  LocationDeniedException(super.message);
}

class LocationPermanentlyDeniedException extends LocationException {
  LocationPermanentlyDeniedException(super.message);
}

class LocationServiceEnabledWidget extends StatelessWidget {
  const LocationServiceEnabledWidget({super.key, required this.controller});
  final LocationController controller;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(
          Icons.location_on,
          size: 50,
          color: Colors.green,
        ),
        const SizedBox(
          height: 20,
        ),
        Obx(() {
          if (controller.locationPermission.value ==
              LocationPermission.denied) {
            return Column(
              children: [
                const Text(
                    'Location permission is denied. Please request location access.'),
                const SizedBox(
                  height: 15,
                ),
                ElevatedButton(
                    onPressed: () {
                      controller.requestLocationPermission();
                    },
                    child: Text('Give location access')),
              ],
            );
          } else if (controller.locationPermission.value ==
              LocationPermission.deniedForever) {
            return Column(
              children: [
                const Text(
                    'Location permission is permanently denied. Please open settings to grant permission.'),
                const SizedBox(
                  height: 15,
                ),
                ElevatedButton(
                    onPressed: () {
                      controller.openLocationSettings();
                    },
                    child: Text('Open settings')),
              ],
            );
          } else if (controller.locationPermission.value ==
                  LocationPermission.always ||
              controller.locationPermission.value ==
                  LocationPermission.whileInUse) {
            return Text(
                'Location is - Lat: ${controller.userPosition.value.latitude}, Long: ${controller.userPosition.value.longitude}');
          }
          return const Text('not able to detemine location');
        }),
        const SizedBox(
          height: 30,
        ),
        const CustomText(text: 'Location Service enabled')
      ],
    );
  }
}

class LocationServiceDisabledWidget extends StatelessWidget {
  const LocationServiceDisabledWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Icon(
          Icons.location_off,
          size: 50,
          color: Colors.red,
        ),
        SizedBox(
          height: 20,
        ),
        CustomText(text: 'Location Service disabled')
      ],
    );
  }
}

class CustomText extends StatelessWidget {
  const CustomText({super.key, required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
    );
  }
}

class LocationFutureBuilder extends StatelessWidget {
  const LocationFutureBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _determinePosition(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            switch (snapshot.error.runtimeType) {
              case ServiceDisabledException:
                return Column(
                  children: [
                    const Icon(
                      Icons.car_crash,
                      size: 50,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(snapshot.error.toString())
                  ],
                );
              case LocationDeniedException:
                return Column(
                  children: [
                    const Icon(
                      Icons.car_crash,
                      size: 50,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(snapshot.error.toString())
                  ],
                );
              case LocationPermanentlyDeniedException:
                return Column(
                  children: [
                    const Icon(
                      Icons.car_crash,
                      size: 50,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(snapshot.error.toString())
                  ],
                );
              default:
                return const Text('nothing to show');
            }
          }
          if (snapshot.hasData) {
            return Text(
                'Lat: ${snapshot.data?.latitude}, Long: ${snapshot.data?.longitude}');
          }
        }
        return const SizedBox();
      },
    );
  }

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    Future.delayed(const Duration(seconds: 3));
    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error(
          ServiceDisabledException('Location services are disabled.'));
      //return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error(
            LocationDeniedException('Location permissions are denied'));
        //return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(LocationPermanentlyDeniedException(
          'Location permissions are permanently denied, we cannot request permissions.'));
      // return Future.error(
      //     'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }
}
