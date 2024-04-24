import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';
import 'ble_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BluetoothScanPage extends StatefulWidget {
  const BluetoothScanPage({Key? key}) : super(key: key);

  @override
  State<BluetoothScanPage> createState() => _BluetoothScanPageState();
}

class _BluetoothScanPageState extends State<BluetoothScanPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _showAddDeviceDialog(BluetoothDevice device) async {
    final deviceName = device.name;
    final macAddress = device.id.id;

    // Check if device with the same name and MAC address already exists
    final querySnapshot = await _firestore
        .collection('class')
        .where('name', isEqualTo: deviceName)
        .where('macAddress', isEqualTo: macAddress)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Device already exists, show a message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Device Already Added'),
            content: Text(
                'The Class $deviceName with MAC address $macAddress is already added to the database.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      // Device does not exist, proceed with adding it
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Add Device?'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Do you want to add $deviceName to class?'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Yes'),
                onPressed: () async {
                  // Upload device data to Firestore
                  await _firestore.collection('class').add({
                    'name': deviceName,
                    'macAddress': macAddress,
                  });
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('No'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Nearby Beacons"),
      ),
      body: GetBuilder<BleController>(
        init: BleController(),
        builder: (BleController controller) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StreamBuilder<List<ScanResult>>(
                  stream: controller.scanResults,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            final data = snapshot.data![index];
                            return Card(
                              elevation: 2,
                              child: ListTile(
                                title: Text(data.device.name),
                                subtitle: Text(data.device.id.id),
                                trailing: Text(data.rssi.toString()),
                                onTap: () => _showAddDeviceDialog(data.device),
                              ),
                            );
                          },
                        ),
                      );
                    } else {
                      return Center(
                        child: Text("No Device Found"),
                      );
                    }
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  onPressed: () async {
                    controller.scanDevices();
                  },
                  child: Text("SCAN"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
