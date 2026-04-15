import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:waternode/features/devices/application/device_controller.dart';
import 'package:waternode/features/devices/domain/models/region_option.dart';
import 'package:waternode/features/devices/presentation/widgets/device_station_card.dart';

class DeviceStationPage extends GetView<DeviceController> {
  const DeviceStationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<RegionOption>(
                  key: ValueKey(controller.selectedSource.value?.code),
                  initialValue: controller.selectedSource.value,
                  decoration: const InputDecoration(labelText: '设备列表'),
                  items: controller.sources
                      .map(
                        (item) => DropdownMenuItem<RegionOption>(
                          value: item,
                          child: Text(item.name),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: controller.selectSource,
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.tonalIcon(
                onPressed: controller.isLoading.value
                    ? null
                    : () async {
                        try {
                          await controller.loadStations();
                        } catch (error) {
                          if (!context.mounted) {
                            return;
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(error.toString())),
                          );
                        }
                      },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('刷新设备'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _FreeWaterConfigCard(controller: controller),
          if (controller.lastError.value != null) ...[
            const SizedBox(height: 12),
            _ErrorBanner(message: controller.lastError.value!),
          ],
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                if (controller.isLoading.value)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (controller.stations.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('当前列表没有可用设备。'),
                    ),
                  )
                else
                  for (final station in controller.stations)
                    DeviceStationCard(
                      station: station,
                      actionLabel: _buildActionLabel(),
                      isDispatching:
                          controller.dispatchingStationId.value == station.id,
                      onDispatch: () async {
                        try {
                          await controller.sendCommand(station);
                        } catch (error) {
                          if (!context.mounted) {
                            return;
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(error.toString())),
                          );
                        }
                      },
                    ),
                if (controller.logs.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Divider(),
                  for (final log in controller.logs) ListTile(title: Text(log)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _buildActionLabel() {
    final config = controller.freeWaterConfig.value;
    if (config == null) {
      return '立即取水';
    }
    return '立即取水 ${config.waterVolume.toStringAsFixed(1)}L';
  }
}

class _FreeWaterConfigCard extends StatelessWidget {
  const _FreeWaterConfigCard({required this.controller});

  final DeviceController controller;

  @override
  Widget build(BuildContext context) {
    final config = controller.freeWaterConfig.value;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('免费接水配置', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            if (config == null)
              const Text('尚未加载配置。')
            else
              Text(
                '默认 ${config.waterVolume.toStringAsFixed(1)}L/次，'
                '每日上限 ${config.dayLimit} 次，'
                '豆值 ${config.beanValue}。',
              ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.errorContainer,
      borderRadius: BorderRadius.circular(16),
      child: Padding(padding: const EdgeInsets.all(16), child: Text(message)),
    );
  }
}
