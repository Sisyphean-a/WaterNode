import 'package:flutter/material.dart';
import 'package:waternode/features/devices/domain/models/device_station.dart';

class DeviceStationCard extends StatelessWidget {
  const DeviceStationCard({
    super.key,
    required this.station,
    required this.onDispatch,
  });

  final DeviceStation station;
  final Future<void> Function() onDispatch;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(station.name),
        subtitle: Text('ID: ${station.id}'),
        trailing: FilledButton(
          onPressed: onDispatch,
          child: const Text('下发指令'),
        ),
      ),
    );
  }
}
