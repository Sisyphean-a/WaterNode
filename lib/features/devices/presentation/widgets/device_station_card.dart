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
    final theme = Theme.of(context);
    final statusText = station.isOnline ? '在线' : '离线';
    final statusColor = station.isOnline
        ? Colors.green.shade700
        : theme.colorScheme.error;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.42,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  station.name,
                  style: theme.textTheme.titleSmall,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  statusText,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: statusColor,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              FilledButton(
                onPressed: isDispatching ? null : onDispatch,
                child: Text(isDispatching ? '执行中' : actionLabel),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              Text('编号 ${station.deviceNum}'),
              Text('ID ${station.id}'),
              if (station.address != null) Text(station.address!),
              if (station.dispenserTypeDesc != null)
                Text(station.dispenserTypeDesc!),
              if (station.statusDescription != null)
                Text(station.statusDescription!),
            ],
          ),
        ],
      ),
    );
  }
}
