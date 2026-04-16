import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:waternode/app/presentation/widgets/workbench_section.dart';
import 'package:waternode/features/credentials/application/credential_controller.dart';
import 'package:waternode/features/credentials/domain/models/account_credential.dart';
import 'package:waternode/features/devices/application/device_controller.dart';
import 'package:waternode/features/devices/domain/models/device_station.dart';

class DispatchWorkbenchSection extends StatelessWidget {
  const DispatchWorkbenchSection({
    super.key,
    required this.credentialController,
    required this.deviceController,
  });

  final CredentialController credentialController;
  final DeviceController deviceController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(
      () => WorkbenchSection(title: '极速取水控制台', child: _buildContent(theme)),
    );
  }

  Widget _buildContent(ThemeData theme) {
    final selectedCredentialMobile =
        deviceController.selectedCredential.value?.mobile;
    final selectedStationId = deviceController.selectedStation.value?.id;
    final lastError = deviceController.lastError.value;
    final isLoading = deviceController.isLoading.value;
    final accountItems = credentialController.credentials
        .where((item) => item.isValid)
        .map(
          (item) => DropdownMenuItem<String>(
            value: item.mobile,
            child: Text(_accountLabel(item), overflow: TextOverflow.ellipsis),
          ),
        )
        .toList(growable: false);
    final stationItems = deviceController.stations
        .map(
          (item) => DropdownMenuItem<String>(
            value: item.id,
            child: Text(_stationLabel(item), overflow: TextOverflow.ellipsis),
          ),
        )
        .toList(growable: false);

    return LayoutBuilder(
      builder: (context, constraints) {
        final fieldWidth = _fieldWidth(constraints.maxWidth);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: fieldWidth,
                  child: _SelectionField<String>(
                    fieldKey: const Key('workbench-account-select'),
                    label: '指派账户',
                    value: selectedCredentialMobile,
                    items: accountItems,
                    onChanged: (value) {
                      final credential = credentialController.credentials
                          .firstWhereOrNull((item) => item.mobile == value);
                      if (credential != null) {
                        deviceController.selectCredential(credential);
                      }
                    },
                  ),
                ),
                SizedBox(
                  width: fieldWidth,
                  child: _SelectionField<String>(
                    fieldKey: const Key('workbench-station-select'),
                    label: '设备终端',
                    value: selectedStationId,
                    items: stationItems,
                    onChanged: (value) {
                      if (value != null) {
                        deviceController.selectStationById(value);
                      }
                    },
                  ),
                ),
              ],
            ),
            if (lastError != null) ...[
              const SizedBox(height: 12),
              Text(
                lastError,
                style: TextStyle(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 88,
                    child: FilledButton.tonal(
                      key: const Key('water-action-7.5'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        minimumSize: const Size.fromHeight(88),
                      ),
                      onPressed: isLoading
                          ? null
                          : () => _confirmAndSend(
                              context,
                              quantity: 1,
                              volumeLabel: '7.5L',
                            ),
                      child: _WaterActionContent(
                        icon: Icons.water_drop_outlined,
                        label: '7.5L',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 88,
                    child: FilledButton(
                      key: const Key('water-action-15'),
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        minimumSize: const Size.fromHeight(88),
                      ),
                      onPressed: isLoading
                          ? null
                          : () => _confirmAndSend(
                              context,
                              quantity: 2,
                              volumeLabel: '15L',
                            ),
                      child: const _WaterActionContent(
                        icon: Icons.water_drop_rounded,
                        label: '15L',
                        emphasize: true,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  double _fieldWidth(double maxWidth) {
    if (maxWidth < 720) {
      return maxWidth;
    }
    if (maxWidth < 1080) {
      return (maxWidth - 16) / 2;
    }
    return (maxWidth - 32) / 3;
  }

  String _accountLabel(AccountCredential credential) {
    final remark = credential.remark?.trim();
    if (remark != null && remark.isNotEmpty) {
      return remark;
    }
    return '尾号${credential.mobile.substring(credential.mobile.length - 4)}';
  }

  String _stationLabel(DeviceStation station) {
    final address = station.address;
    if (address == null || address.trim().isEmpty) {
      return station.name;
    }
    return '${station.name} · $address';
  }

  Future<void> _confirmAndSend(
    BuildContext context, {
    required int quantity,
    required String volumeLabel,
  }) async {
    final stationName = deviceController.selectedStation.value?.name ?? '当前设备';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认取水'),
        content: Text('将向 $stationName 下发 $volumeLabel 取水指令。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('确认'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    await deviceController.sendCommand(quantity: quantity);
  }
}

class _WaterActionContent extends StatelessWidget {
  const _WaterActionContent({
    required this.icon,
    required this.label,
    this.emphasize = false,
  });

  final IconData icon;
  final String label;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle =
        (emphasize ? theme.textTheme.titleLarge : theme.textTheme.titleMedium)
            ?.copyWith(
              fontSize: emphasize ? 20 : 18,
              height: 1,
              fontWeight: FontWeight.w800,
            );

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: emphasize ? 26 : 24),
        const SizedBox(height: 6),
        Text(label, style: textStyle),
      ],
    );
  }
}

class _SelectionField<T> extends StatelessWidget {
  const _SelectionField({
    required this.fieldKey,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.helperText,
  });

  final Key fieldKey;
  final String label;
  final String? helperText;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      key: fieldKey,
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label, helperText: helperText),
      items: items,
      onChanged: items.isEmpty ? null : onChanged,
    );
  }
}
