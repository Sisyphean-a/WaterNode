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
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<RegionOption>(
                  initialValue: controller.selectedParent.value,
                  decoration: const InputDecoration(labelText: '大区'),
                  items: controller.regions
                      .map(
                        (item) => DropdownMenuItem<RegionOption>(
                          value: item,
                          child: Text(item.name),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: controller.selectParent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<RegionOption>(
                  initialValue: controller.selectedChild.value,
                  decoration: const InputDecoration(labelText: '区域'),
                  items: controller.childOptions
                      .map(
                        (item) => DropdownMenuItem<RegionOption>(
                          value: item,
                          child: Text(item.name),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: controller.selectChild,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                for (final station in controller.stations)
                  DeviceStationCard(
                    station: station,
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
                if (controller.logs.isNotEmpty) const Divider(),
                for (final log in controller.logs) ListTile(title: Text(log)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
