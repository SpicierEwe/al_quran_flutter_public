import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';

import '../../logic/downloader_bloc/downloader_bloc.dart';


/*
*
* Display the download progress bar at the bottom of the screen
*
* */

class BottomDownloadBarWidget extends StatelessWidget {
  const BottomDownloadBarWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DownloaderBloc, DownloaderState>(
      builder: (context, downloaderState) {
        bool isError = downloaderState.isError;
        return Visibility(
            visible: downloaderState.isSnackbarVisible,
            // visible: true,

            child: BottomAppBar(
              height: 7.h,
              padding: EdgeInsets.zero,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 3.w,
                  vertical: 1.h,
                ),
                decoration: BoxDecoration(
                  // color: Colors.green,
                  border: Border(
                    top: BorderSide(
                      color:
                      isError ? Colors.red : Colors.green,
                      width: 1.w,
                    ),
                  ),
                ),
                child: Row(
                  crossAxisAlignment:
                  CrossAxisAlignment.center,
                  children: [
                    if (!isError)
                      SizedBox(
                        width: 30,
                        height: 30,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const CircularProgressIndicator(
                              backgroundColor: Colors.white,
                              valueColor:
                              AlwaysStoppedAnimation(
                                  Colors.green),
                            ),
                            Icon(Icons.download,
                                color: Colors.teal.shade400, size: 15)
                          ],
                        ),
                      )
                    // If error show this icon
                    else
                      const SizedBox(
                        width: 30,
                        height: 30,
                        child: Icon(
                          Icons.error,
                          color: Colors.red,
                          size: 30,
                        ),
                      ),

                    // Progress Text ==========================
                    Expanded(
                      child: Center(
                        child: Text(downloaderState.message),
                      ),
                    ),

                    // Error Button ==========================
                    if (isError)
                      ElevatedButton(
                        onPressed: () {
                          context
                              .read<DownloaderBloc>()
                              .add(RetryDownloadEvent());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text(
                          "Retry",
                          style:
                          TextStyle(color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ),
            ));
      },
    );
  }
}
