import 'package:flutter/material.dart';
import 'package:waternode/features/devices/domain/models/device_station.dart';

class DeviceStationCard extends StatelessWidget {
  const DeviceStationCard({
    super.key,
    required this.station,
    required this.actionLabel,
    required this.isDispatching,
    required this.onDispatch,
  });

  final DeviceStation station;
  final String actionLabel;
  final bool isDispatching;
  final Future<void> Function() onDispatch;

  @override
  Widget build(BuildContext context) {
    final statusText = station.isOnline ? '在线' : '离线';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    station.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                FilledButton(
                  onPressed: isDispatching ? null : onDispatch,
                  child: Text(isDispatching ? '执行中...' : actionLabel),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('设备 ID: ${station.id}'),
            Text('设备编号: ${station.deviceNum}'),
            if (station.address != null) Text('地址: ${station.address}'),
            Text('状态: $statusText / ${station.status}'),
            if (station.dispenserTypeDesc != null)
              Text('类型: ${station.dispenserTypeDesc}'),
            if (station.statusDescription != null)
              Text('详情: ${station.statusDescription}'),
          ],
        ),
      ),
    );
  }
}
