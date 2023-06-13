import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fwupd/fwupd.dart';
import 'package:provider/provider.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import 'device_model.dart';
import 'device_store.dart';
import 'fwupd_notifier.dart';
import 'fwupd_x.dart';
import 'src/widgets/release_card.dart';

class ReleasePage extends StatelessWidget {
  const ReleasePage({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<DeviceModel>();
    final device = model.device;
    final releases = model.releases ?? [];
    final currentReleases = releases.where((r) => !r.isDowngrade);
    final oldReleases = releases.where((r) => r.isDowngrade);
    final l10n = AppLocalizations.of(context);

    Widget buildReleaseCard(FwupdRelease release) => ReleaseCard(
          release: release,
          device: device,
          onInstall: () async {
            final notifier = context.read<FwupdNotifier>();
            final store = context.read<DeviceStore>();
            store.showReleases = false;
            await model.install(release);
            await notifier.refresh();

            // refresh [DeviceStore] to force updates of all
            // [DeviceModel]s even if fwupd didn't send an
            // appropriate DBus signal (possible bug in 1.7.5
            // on Ubuntu 22.04)
            // TODO: improve when better solution is found
            await store.refresh();
          },
        );

    return YaruDetailPage(
      appBar: YaruWindowTitleBar(
        title: Text('${device.name} ${device.version}'),
        leading: Navigator.of(context).canPop() ? const YaruBackButton() : null,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
          child: Column(
            children: [
              Column(
                children: currentReleases.map(buildReleaseCard).toList(),
              ),
              if (oldReleases.isNotEmpty)
                YaruExpandable(
                  expandButtonPosition: YaruExpandableButtonPosition.start,
                  header: Text(l10n.olderVersions),
                  child: Column(
                    children: oldReleases
                        .where((release) => release.isDowngrade)
                        .map(buildReleaseCard)
                        .toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
