import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fwupd/fwupd.dart';
import 'package:provider/provider.dart';

import '../../device_model.dart';
import '../../fwupd_x.dart';
import 'confirmation_dialog.dart';
import 'release_card.dart';

Future<void> showReleaseDialog(
  BuildContext context, {
  required FwupdDevice device,
  required List<FwupdRelease> releases,
  required ValueChanged<FwupdRelease> onInstall,
}) {
  return showDialog(
    context: context,
    builder: (_) => ReleaseDialog(
      device: device,
      releases: releases,
      onInstall: onInstall,
    ),
  );
}

class ReleaseDialog extends StatelessWidget {
  const ReleaseDialog({
    super.key,
    required this.device,
    required this.releases,
    required this.onInstall,
  });

  final FwupdDevice device;
  final List<FwupdRelease> releases;
  final ValueChanged<FwupdRelease> onInstall;

  @override
  Widget build(BuildContext context) {
    final selected = context.watch<DeviceModel>().selectedRelease;
    final l10n = AppLocalizations.of(context);
    final String action;
    final String dialogText;

    if (selected?.isDowngrade == true) {
      action = l10n.downgrade;
      dialogText = l10n.downgradeConfirm(
        device.name,
        device.version,
        selected?.version,
      );
    } else if (selected?.isUpgrade == false) {
      action = l10n.reinstall;
      dialogText = l10n.reinstallConfirm(
        device.name,
        device.version,
      );
    } else {
      action = l10n.upgrade;
      dialogText = l10n.upgradeConfirm(
        device.name,
        device.version,
        selected?.version,
      );
    }

    return AlertDialog(
      title: Text('${device.name} ${device.version}'),
      titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      contentPadding: const EdgeInsets.all(4),
      content: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: releases.map((release) {
            return Flexible(
              child: ReleaseCard(
                release: release,
                selected: release == selected,
                onSelected: () =>
                    context.read<DeviceModel>().selectedRelease = release,
              ),
            );
          }).toList(),
        ),
      ),
      buttonPadding: const EdgeInsets.only(left: 16),
      actionsPadding: const EdgeInsets.fromLTRB(0, 0, 12, 12),
      actions: [
        ElevatedButton(
          onPressed: selected != null
              ? () {
                  showConfirmationDialog(
                    context,
                    text: dialogText,
                    onConfirm: () {
                      onInstall(selected);
                      Navigator.of(context).pop();
                    },
                    onCancel: () {},
                  );
                }
              : null,
          child: Text(action),
        ),
        OutlinedButton(
          onPressed: Navigator.of(context).pop,
          child: Text(l10n.cancel),
        )
      ],
    );
  }
}
