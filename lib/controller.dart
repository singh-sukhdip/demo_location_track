import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class LocationController extends FullLifeCycleController
    with FullLifeCycleMixin {
  static LocationController get to => Get.find<LocationController>();

  //late StreamController<ServiceStatus> serviceStatusStream;

  var status = ServiceStatus.disabled.obs;
  late Rx<LocationPermission> locationPermission =
      LocationPermission.unableToDetermine.obs;
  late Rx<Position> userPosition = Position(
          longitude: 0.0,
          latitude: 0.0,
          timestamp: DateTime.now(),
          accuracy: 0.0,
          altitude: 0.0,
          heading: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0)
      .obs;

  @override
  void onInit() {
    super.onInit();
    //serviceStatusStream.addStream(getLocationServiceStatusStream());
    status.bindStream(getLocationServiceStatusStream());
  }

  @override
  void onReady() async {
    super.onReady();
    status.value = await Geolocator.isLocationServiceEnabled()
        ? ServiceStatus.enabled
        : ServiceStatus.disabled;
    locationPermission.value = await getLocationPermission();
    print(locationPermission.value);
    status.listen((event) async {
      if (event == ServiceStatus.enabled && await isLocationGranted()) {
        //locationPermission.value = await getLocationPermission();
        userPosition.bindStream(getUserPositionStream());
      }
    });
  }

  @override
  void onClose() {
    //serviceStatusStream.close();
    super.onClose();
  }

  @override
  void onDetached() {
    // TODO: implement onDetached
  }

  @override
  void onInactive() {
    // TODO: implement onInactive
  }

  @override
  void onPaused() {
    // TODO: implement onPaused
  }

  @override
  void onResumed() async {
    locationPermission.value = await getLocationPermission();
  }

  Stream<ServiceStatus> getLocationServiceStatusStream() async* {
    yield* Geolocator.getServiceStatusStream(); //yield* for returning stream
  }

  Stream<LocationPermission> getLocationPermissionStream() async* {
    yield await Geolocator
        .checkPermission(); //yield for returning normal values
  }

  Future<LocationPermission> getLocationPermission() async =>
      await Geolocator.checkPermission();

  Future<void> requestLocationPermission() async =>
      locationPermission.value = await Geolocator.requestPermission();

  openLocationSettings() async => Geolocator.openAppSettings();

  Stream<Position> getUserPositionStream() async* {
    yield* Geolocator.getPositionStream();
  }

  Future<bool> isLocationGranted() async {
    var permission = await getLocationPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      return true;
    }
    return false;
  }
}
