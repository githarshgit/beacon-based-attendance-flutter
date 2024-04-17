import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class BeaconScannerPage extends StatefulWidget {
  @override
  _BeaconScannerPageState createState() => _BeaconScannerPageState();
}

class _BeaconScannerPageState extends State<BeaconScannerPage> {
  final FlutterBlue flutterBlue = FlutterBlue.instance;
  List<ScanResult> scanResults = [];

  @override
  void initState() {
    super.initState();
    _startScanning();
  }

  void _startScanning() async {
    bool isAvailable = await flutterBlue.isOn;
    if (!isAvailable) {
      print('Bluetooth is not available or not enabled.');
      return;
    }

    // Start scanning for BLE devices
    flutterBlue.startScan(timeout: Duration(seconds: 4));

    flutterBlue.scanResults.listen((results) {
      setState(() {
        scanResults = results;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Beacon Scanner'),
      ),
      body: ListView.builder(
        itemCount: scanResults.length,
        itemBuilder: (BuildContext context, int index) {
          ScanResult result = scanResults[index];
          return ListTile(
            title: Text('Device ID: ${result.device.id}'),
            subtitle: Text('RSSI: ${result.rssi}'),
            onTap: () {
              print('Tapped on device: ${result.device.id}');
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    flutterBlue.stopScan();
  }
}
