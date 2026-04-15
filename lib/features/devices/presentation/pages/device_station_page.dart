import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:waternode/app/presentation/widgets/workbench_section.dart';
import 'package:waternode/features/devices/application/device_controller.dart';
import 'package:waternode/features/devices/domain/models/region_option.dart';
import 'package:waternode/features/devices/presentation/widgets/device_station_card.dart';

class DeviceStationPage extends GetView<DeviceController> {
  const DeviceStationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          WorkbenchSection(
            title: '终端筛选',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 240,
                  child: DropdownButtonFormField<RegionOption>(
                    key: ValueKey(controller.selectedSource.value?.code),
                    initialValue: controller.selectedSource.value,
                    decoration: const InputDecoration(labelText: '数据源'),
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
                FilledButton.tonalIcon(
                  onPressed: controller.isLoading.value
                      ? null
                      : () => controller.loadStations(),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('刷新设备'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          WorkbenchSection(
            title: '免费配置',
            child: _ConfigStrip(controller: controller),
          ),
          if (controller.lastError.value != null) ...[
            const SizedBox(height: 10),
            Text(
              controller.lastError.value!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 10),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 980) {
                  return _DeviceBody(controller: controller);
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _StationList(controller: controller),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: _DeviceLogs(controller: controller),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DeviceBody extends StatelessWidget {
  const _DeviceBody({required this.controller});

  final DeviceController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: _StationList(controller: controller)),
        const SizedBox(height: 10),
        SizedBox(height: 180, child: _DeviceLogs(controller: controller)),
      ],
    );
  }
}

class _ConfigStrip extends StatelessWidget {
  const _ConfigStrip({required this.controller});

  final DeviceController controller;

  @override
  Widget build(BuildContext context) {
    final config = controller.freeWaterConfig.value;
    if (config == null) {
      return const Text('尚未加载配置');
    }

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        Text('默认 ${config.waterVolume.toStringAsFixed(1)}L'),
        Text('日上限 ${config.dayLimit} 次'),
        Text('豆值 ${config.beanValue}'),
      ],
    );
  }
}

class _StationList extends StatelessWidget {
  const _StationList({required this.controller});

  final DeviceController controller;

  @override
  Widget build(BuildContext context) {
    return WorkbenchSection(
      title: '设备列表',
      expandChild: true,
      child: controller.isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                for (final station in controller.stations)
                  DeviceStationCard(
                    station: station,
                    actionLabel: _buildActionLabel(controller),
                    isDispatching:
                        controller.dispatchingStationId.value == station.id,
                    onDispatch: () => controller.sendCommand(station),
                  ),
                if (controller.stations.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 24),
                    child: Center(child: Text('当前列表没有可用设备')),
                  ),
              ],
            ),
    );
  }

  String _buildActionLabel(DeviceController controller) {
    final config = controller.freeWaterConfig.value;
    if (config == null) {
      return '立即取水';
    }
    return '立即取水 ${config.waterVolume.toStringAsFixed(1)}L';
  }
}

class _DeviceLogs extends StatelessWidget {
  const _DeviceLogs({required this.controller});

  final DeviceController controller;

  @override
  Widget build(BuildContext context) {
    return WorkbenchSection(
      title: '执行反馈',
      expandChild: true,
      child: ListView(
        children: [
          for (final log in controller.logs)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(log),
            ),
          if (controller.logs.isEmpty) const Text('尚无取水执行记录'),
        ],
      ),
    );
  }
}
