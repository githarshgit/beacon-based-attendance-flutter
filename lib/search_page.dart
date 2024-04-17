import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';

class BleScanPage extends StatefulWidget {
  @override
  _BleScanPageState createState() => _BleScanPageState();
}

class _BleScanPageState extends State<BleScanPage> {
  final FlutterBlue ble = FlutterBlue.instance;
  List<ScanResult> _scanResults = [];

  Future<void> _requestPermissions() async {
    final bluetoothScanStatus = await Permission.bluetoothScan.status;
    final bluetoothConnectStatus = await Permission.bluetoothConnect.status;

    if (bluetoothScanStatus.isGranted && bluetoothConnectStatus.isGranted) {
      _startScanning();
    } else {
      final bluetoothScanRequestResult =
          await Permission.bluetoothScan.request();
      final bluetoothConnectRequestResult =
          await Permission.bluetoothConnect.request();

      if (bluetoothScanRequestResult.isGranted &&
          bluetoothConnectRequestResult.isGranted) {
        _startScanning();
      } else {
        print('Permissions not granted for Bluetooth scanning and connection');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bluetooth permissions not granted'),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: () => openAppSettings(),
            ),
          ),
        );
      }
    }
  }

  void _startScanning() {
    ble.scanResults.listen((scanResult) {
      setState(() {
        _scanResults.add(scanResult as ScanResult);
      });
    });
    ble.startScan(timeout: Duration(seconds: 10));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BLE Device Scanner'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _requestPermissions,
              child: Text('Request Permissions & Scan'),
            ),
            SizedBox(height: 20),
            _scanResults.isEmpty
                ? CircularProgressIndicator()
                : Expanded(
                    child: ListView.builder(
                      itemCount: _scanResults.length,
                      itemBuilder: (context, index) {
                        final ScanResult result = _scanResults[index];
                        return ListTile(
                          title: Text(result.device.name ?? 'Unknown Device'),
                          subtitle: Text(result.device.id.toString()),
                          trailing: Text(result.rssi.toString()),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
