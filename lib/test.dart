import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_beacon/flutter_beacon.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FlutterBeacon.initializeScanning;

  print('Starting Beacon Scan...');

  listenForBeacons();
}

void listenForBeacons() async {
  await requestPermissions();
  _rangingStream.listen((RangingResult result) {
    for (Beacon beacon in result.beacons) {
      print('Found beacon: ${beacon.beaconId}');
      print('  Distance: ${beacon.distance}m');
      print('  Major: ${beacon.major}');
      print('  Minor: ${beacon.minor}');
      print('---');
    }
  });
}

Future<void> requestPermissions() async {
  await FlutterBeacon.requestPermissions();
  await FlutterBeacon.requestIOSPermissions();
}

Stream<RangingResult> get _rangingStream => FlutterBeacon.rangingStream;
