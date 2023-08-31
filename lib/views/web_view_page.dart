// ignore_for_file: library_private_types_in_public_api, must_be_immutable
import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'package:fl_downloader/fl_downloader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:vtudom/views/error_page.dart';
import 'package:vtudom/views/loading_page.dart';
import 'package:vtudom/widget/banner_ad.dart';
import 'package:vtudom/utils/color.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class WebPage extends StatefulWidget {
  static const String webPage = "webPage";
  WebPage({
    Key? key,
    this.imageIcon = 'assets/images/individual.png',
  }) : super(key: key);

  String? imageIcon;

  @override
  _WebPageState createState() => _WebPageState();
}

class _WebPageState extends State<WebPage> {
  late ContextMenu contextMenu;
  bool firstTime = true;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useOnDownloadStart: true,
        useOnLoadResource: true,
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
        transparentBackground: true,
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
        supportMultipleWindows: true,
        disableDefaultErrorPage: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  bool pageIsLoaded = false;
  double progress = 0;
  late PullToRefreshController pullToRefreshController;
  String siteUrl = 'https://app.vtudom.com.ng/';
  String url = "";
  String downloadUrl = "";
  bool userCanGoBack = false;
  bool userCanGoForward = false;
  InAppWebViewController? webViewController;
  final GlobalKey webViewKey = GlobalKey();

  ConnectivityResult _connectionResult = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();

  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  @override
  void dispose() {
    _connectivitySubscription!.cancel();
    downloadProgressStream.cancel();
    super.dispose();
  }

  int downloadProgress = 0;
  dynamic downloadId;
  String? downloadStatus;
  late StreamSubscription downloadProgressStream;

  @override
  void initState() {
    FlDownloader.initialize();
    downloadProgressStream = FlDownloader.progressStream.listen((event) {
      if (event.status == DownloadStatus.successful) {
        debugPrint('event.progress: ${event.progress}');
        setState(() {
          downloadProgress = event.progress;
          downloadId = event.downloadId;
          downloadStatus = event.status.name;
        });
        FlDownloader.openFile(filePath: event.filePath);
      } else if (event.status == DownloadStatus.running) {
        debugPrint('event.progress: ${event.progress}');
        setState(() {
          downloadProgress = event.progress;
          downloadId = event.downloadId;
          downloadStatus = event.status.name;
        });
      } else if (event.status == DownloadStatus.failed) {
        debugPrint('event: $event');
        setState(() {
          downloadProgress = event.progress;
          downloadId = event.downloadId;
          downloadStatus = event.status.name;
        });
      } else if (event.status == DownloadStatus.paused) {
        debugPrint('Download paused');
        setState(() {
          downloadProgress = event.progress;
          downloadId = event.downloadId;
          downloadStatus = event.status.name;
        });

        Future.delayed(
          const Duration(milliseconds: 250),
          () => FlDownloader.attachDownloadProgress(event.downloadId),
        );
      } else if (event.status == DownloadStatus.pending) {
        debugPrint('Download pending');
        setState(() {
          downloadProgress = event.progress;
          downloadId = event.downloadId;
          downloadStatus = event.status.name;
        });
      }
    });

    contextMenu = ContextMenu(
      menuItems: [
        ContextMenuItem(
            androidId: 1,
            iosId: "1",
            title: "Special",
            action: () async {
              print("Menu item Special clicked!");
              print(await webViewController?.getSelectedText());
              await webViewController?.clearFocus();
            })
      ],
      onHideContextMenu: () {
        print("onHideContextMenu");
      },
      onContextMenuActionItemClicked: (contextMenuItemClicked) async {
        var id = contextMenuItemClicked.androidId;
        print("onContextMenuActionItemClicked: " +
            id.toString() +
            " " +
            contextMenuItemClicked.title);
      },
      options: ContextMenuOptions(hideDefaultSystemContextMenuItems: false),
      onCreateContextMenu: (hitTestResult) async {
        print("onCreateContextMenu");
        print(hitTestResult.extra);
        print(await webViewController?.getSelectedText());
      },
    );
    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: primaryColor,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          webViewController?.reload();
        } else if (Platform.isIOS) {
          webViewController?.loadUrl(
              urlRequest: URLRequest(url: await webViewController?.getUrl()));
        }
      },
    );

    firstTime == true ? siteUrl : () {};
    firstTime = false;
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    super.initState();
  }

  Future loadPage() async {
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        pageIsLoaded = true;
      });
    });
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      _connectionResult = result;
    });
  }

  BannerAdMobContainerState _bannerAdMobContainerState =
      BannerAdMobContainerState();
  @override
  Widget build(BuildContext context) {
    return (_connectionResult == ConnectivityResult.mobile ||
            _connectionResult == ConnectivityResult.wifi)
        ? Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Column(children: [
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (downloadProgress > 0 && downloadProgress < 100)
                        LinearProgressIndicator(
                          value: downloadProgress / 100,
                          color: primaryColor,
                        ),
                      Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          InAppWebView(
                            key: webViewKey,
                            initialUrlRequest:
                                URLRequest(url: Uri.parse(siteUrl)),
                            initialOptions: options,
                            initialUserScripts:
                                UnmodifiableListView<UserScript>([]),
                            contextMenu: contextMenu,
                            pullToRefreshController: pullToRefreshController,
                            onWebViewCreated:
                                (InAppWebViewController controller) async {
                              webViewController = controller;
                              setState(() {});
                            },
                            onLoadStart: (controller, url) {
                              _bannerAdMobContainerState.loadAd();
                              setState(() {
                                this.url = url.toString();
                              });
                            },
                            androidOnPermissionRequest:
                                (controller, origin, resources) async {
                              return PermissionRequestResponse(
                                  resources: resources,
                                  action:
                                      PermissionRequestResponseAction.GRANT);
                            },
                            shouldOverrideUrlLoading:
                                (controller, navigationAction) async {
                              var uri = navigationAction.request.url!;

                              if (![
                                "http",
                                "https",
                                "file",
                                "chrome",
                                "data",
                                "javascript",
                                "about"
                              ].contains(uri.scheme)) {
                                // ignore: deprecated_member_use
                                if (await canLaunch(url)) {
                                  // ignore: deprecated_member_use
                                  await launch(
                                    url,
                                  );
                                  return NavigationActionPolicy.CANCEL;
                                }
                              }

                              return NavigationActionPolicy.ALLOW;
                            },
                            onLoadStop: (controller, url) async {
                              pullToRefreshController.endRefreshing();
                              setState(() {
                                this.url = url.toString();
                              });
                            },
                            onLoadError: (controller, url, code, message) {
                              pullToRefreshController.endRefreshing();
                              setState(() {
                                progress = 0.0;
                              });
                            },
                            onProgressChanged: (controller, progress) {
                              if (progress == 1.0) {
                                pullToRefreshController.endRefreshing();
                              }
                              setState(() {
                                this.progress = progress.toDouble();
                              });
                            },
                            onDownloadStartRequest:
                                (InAppWebViewController controller,
                                    DownloadStartRequest url) async {
                              setState(() {
                                downloadUrl = url.url.toString();
                              });
                              print("downloader tapper: url>>>> $downloadUrl");
                              final permission =
                                  await FlDownloader.requestPermission();
                              if (permission ==
                                  StoragePermissionStatus.granted) {
                                await FlDownloader.download(
                                  downloadUrl,
                                  fileName: url.suggestedFilename!
                                      .replaceAll("html", "")
                                      .replaceAll("_", " "),
                                );
                              } else {
                                debugPrint('Permission denied =(');
                              }
                            },
                            onUpdateVisitedHistory:
                                (controller, url, androidIsReload) {
                              setState(() {
                                this.url = url.toString();
                                // urlController.text = this.url;
                              });
                            },
                            onConsoleMessage: (controller, consoleMessage) {
                              print(consoleMessage);
                            },
                          ),
                          BannerAdMobContainer()
                        ],
                      ),
                      progress < 1.0 ? LoadingPage() : Container(),
                    ],
                  ),
                )
              ]),
            ),
          )
        : ErrorPage(controller: webViewController);
  }
}
