import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../logic/downloader_bloc/downloader_bloc.dart';

class DataUpdateSettingsWidget extends StatelessWidget {
  const DataUpdateSettingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DownloaderBloc, DownloaderState>(
      builder: (context, downloaderState) {
        return Column(
          children: [
            ListTile(
              title: const Text("Update Data"),
              subtitle: Text(
                  "This will re-fetch the entire Qur'an data from the Server.\n\nLast updated: ${downloaderState.lastFetchedDate}"),
              trailing: TextButton(
                onPressed: () {
                  context.read<DownloaderBloc>().add(DownloadQuranEvent());
                },
                child: const Text("Refresh"),
              ),
            ),
          ],
        );
      },
    );
  }
}
