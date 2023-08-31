// ignore_for_file: library_private_types_in_public_api, must_be_immutable
import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:async';
import 'package:fl_downloader/fl_downloader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:circle_progress_bar/circle_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:vtudom/views/error_page.dart';
import 'package:vtudom/views/loading_page.dart';
import 'package:vtudom/widget/banner_ad.dart';
import 'package:vtudom/widget/iconss.dart';
import 'package:vtudom/widget/spacing.dart';
// import 'package:webview_flutter/webview_flutter.dart';
import 'package:vtudom/utils/color.dart';
import 'package:vtudom/widget/texts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/cupertino.dart';

class WebPage extends StatefulWidget {
  static const String webPage = "webPage";
  WebPage({
    Key? key,
//    required this.loginType,
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
  // final urlController = TextEditingController(
  //   text:
  //       'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
  // );
  String downloadUrl = "";
  bool userCanGoBack = false;
  bool userCanGoForward = false;
  InAppWebViewController? webViewController;
  //..setBackgroundColor(covnst Color(0x00000000)
  final GlobalKey webViewKey = GlobalKey();

  ConnectivityResult _connectionResult = ConnectivityResult.none;
  // late final WebViewController controller;
  // bool isError = false;
  // var progressBar = 0;
  final Connectivity _connectivity = Connectivity();

  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  // List<String> downloadExtensions = [
  //   // Document Extensions
  //   '.doc',
  //   '.docx',
  //   '.pdf',
  //   '.txt',
  //   '.ppt',
  //   '.pptx',
  //   '.jpg',
  //   '.jpeg',
  //   '.png',
  //   '.gif',
  //   '.svg',
  // ];

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
        // This is a way of auto-opening downloaded file right after a download is completed
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
        // Here I am attaching the download progress to the download task again
        // after an paused status because the download task can be paused by
        // the system when the connection is lost or is waiting for a wifi
        // connection see https://developer.android.com/reference/android/app/DownloadManager#PAUSED_QUEUED_FOR_WIFI
        // for the possible reasons of a download task to be auto-paused by the
        // system (this applies to Windows too as the plugin sets the same suspension
        // policies for Windows downloads).
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
//  webViewController = InAppWebViewController(id, webview)
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    // webViewController = InAppWebViewController(id, webview)
    //   ..setJavaScriptMode(JavaScriptMode.unrestricted)
    //   ..setNavigationDelegate(
    //     NavigationDelegate(onProgress: (int progress) {
    //       setState(() {
    //         isError = false;
    //         progressBar = progress;
    //       });
    //     }, onPageStarted: (String url) {
    //       print('page started with this URL: $url');
    //       setState(() {
    //         progressBar = 0;
    //         url = siteUrl;
    //       });
    //     }, onPageFinished: (String url) {
    //       setState(() {
    //         progressBar = 100;
    //         siteUrl = url;
    //       });
    //       print('page finished with this URL: $url :  $siteUrl');
    //       canGoBack();
    //       canGoForward();
    //     }, onWebResourceError: (WebResourceError error) {
    //       controller.reload();
    //     }, onNavigationRequest: (NavigationRequest request) {
    //       Uri uri = Uri.parse(request.url);
    //       for (String extension in downloadExtensions) {
    //         if (request.url.contains(extension)) {
    //           FileDownloader.downloadFile(
    //               url: request.url,
    //               name: uri.pathSegments.last.replaceAll(extension, ''),
    //               onProgress: (String? fileName, double progress) {
    //                 // print('FILE fileName HAS PROGRESS $progress');
    //                 BotToast.showCustomLoading(toastBuilder: (action) {
    //                   return Center(
    //                     child: SizedBox.square(
    //                       dimension: 90,
    //                       child: Container(
    //                         decoration: BoxDecoration(
    //                             border: Border.all(color: white),
    //                             borderRadius: BorderRadius.circular(30),
    //                             color: grey.withOpacity(0.6)),
    //                         child: Column(
    //                           mainAxisSize: MainAxisSize.min,
    //                           mainAxisAlignment: MainAxisAlignment.center,
    //                           children: [
    //                             const YMargin(5),
    //                             SizedBox(
    //                               width: 50,
    //                               child: CircleProgressBar(
    //                                 foregroundColor: primaryColor,
    //                                 backgroundColor: white,
    //                                 value: progress / 100,
    //                                 child: AnimatedCount(
    //                                   count: 0.5,
    //                                   unit: '%',
    //                                   duration: Duration(milliseconds: 500),
    //                                 ),
    //                               ),
    //                             ),
    //                             const YMargin(10),
    //                             TextOf('Dowloading...', sizea1, white,
    //                                 FontWeight.w400),
    //                           ],
    //                         ),
    //                       ),
    //                     ),
    //                   );
    //                 });
    //               },
    //               onDownloadCompleted: (String path) {
    //                 print('FILE DOWNLOADED TO PATH: $path');
    //               },
    //               onDownloadError: (String error) {
    //                 print('DOWNLOAD ERROR: $error');
    //               });
    //         }
    //       }
    //       return NavigationDecision.navigate;
    //       // request.url.contains(downloadExtensions.any((element) => element==));
    //     }),
    //   )
    //   ..loadRequest(Uri.parse(siteUrl));
    super.initState();
  }

  // Future<void> goForward() async {
  //   await webViewController?.goForward();
  // }

  // Future<bool?> checkCanGoBack() async {
  //   return await webViewController?.canGoBack();
  // }

  // Future<bool?> checkCanGoForward() async {
  //   return await webViewController?.canGoForward();
  // }

  // bool canGoBack() {
  //   checkCanGoBack().then((value) {
  //     setState(() {
  //       userCanGoBack = value ?? false;
  //     });
  //     // print('go back $value');
  //   });
  //   return userCanGoBack;
  // }

  // bool canGoForward() {
  //   checkCanGoForward().then((value) {
  //     setState(() {
  //       userCanGoForward = value ?? false;
  //     });
  //     // print('can go back $value');
  //   });
  //   return userCanGoForward;
  // }

  // Future<void> goBack() async {
  //   await webViewController?.goBack();
  // }

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
                // Container(
                //     width: double.infinity,
                //     child: Column(
                //       children: [
                //         YMargin(10),
                //         // Padding(
                //         //     padding: EdgeInsets.symmetric(horizontal: 15),
                //         //     child: Row(
                //         //         mainAxisAlignment:
                //         //             MainAxisAlignment.spaceBetween,
                //         //         mainAxisSize: MainAxisSize.min,
                //         //         children: [
                //         //           Expanded(
                //         //             flex: 2,
                //         //             child: Row(
                //         //               mainAxisAlignment:
                //         //                   MainAxisAlignment.start,
                //         //               children: [
                //         //                 Card(
                //         //                   color: Colors.primaryColor[100],
                //         //                   shadowColor: Colors.primaryColor[100],
                //         //                   elevation: 2,
                //         //                   shape: RoundedRectangleBorder(
                //         //                       borderRadius:
                //         //                           BorderRadius.circular(30)),
                //         //                   child: Padding(
                //         //                     padding: const EdgeInsets.all(5.0),
                //         //                     child: Row(
                //         //                         mainAxisAlignment:
                //         //                             MainAxisAlignment
                //         //                                 .spaceBetween,
                //         //                         children: [
                //         //                           Tooltip(
                //         //                             message: 'Previous',
                //         //                             child: InkWell(
                //         //                               onTap: () {
                //         //                                 print(
                //         //                                     "can go back: $canGoBack()");
                //         //                                 if (canGoBack() ==
                //         //                                     true) {
                //         //                                   goBack();
                //         //                                 } else {
                //         //                                   BotToast.showText(
                //         //                                     text:
                //         //                                         "No previous page in stack!",
                //         //                                     duration: Duration(
                //         //                                         seconds: 2),
                //         //                                     contentColor: Colors
                //         //                                         .black
                //         //                                         .withOpacity(
                //         //                                             .7),
                //         //                                     textStyle: TextStyle(
                //         //                                         fontSize: 16.0,
                //         //                                         color: Colors
                //         //                                             .white),
                //         //                                     align: Alignment
                //         //                                         .center,
                //         //                                     borderRadius:
                //         //                                         BorderRadius
                //         //                                             .circular(
                //         //                                                 30),
                //         //                                     contentPadding:
                //         //                                         EdgeInsets
                //         //                                             .symmetric(
                //         //                                                 horizontal:
                //         //                                                     10,
                //         //                                                 vertical:
                //         //                                                     15),
                //         //                                   );
                //         //                                 }
                //         //                               },
                //         //                               child: IconOf(
                //         //                                   Icons
                //         //                                       .arrow_back_ios_rounded,
                //         //                                   25,
                //         //                                   canGoBack() == true
                //         //                                       ? primaryColor
                //         //                                       : grey),
                //         //                             ),
                //         //                           ),
                //         //                           XMargin(25),
                //         //                           Tooltip(
                //         //                             message: 'Forward',
                //         //                             child: InkWell(
                //         //                               onTap: () {
                //         //                                 print(
                //         //                                     "can go forward: $canGoForward()");
                //         //                                 if (canGoForward() ==
                //         //                                     true) {
                //         //                                   goForward();
                //         //                                 } else {
                //         //                                   BotToast.showText(
                //         //                                     text:
                //         //                                         "No next page in stack!",
                //         //                                     duration: Duration(
                //         //                                         seconds: 2),
                //         //                                     contentColor: Colors
                //         //                                         .black
                //         //                                         .withOpacity(
                //         //                                             .7),
                //         //                                     textStyle: TextStyle(
                //         //                                         fontSize: 16.0,
                //         //                                         color: Colors
                //         //                                             .white),
                //         //                                     align: Alignment
                //         //                                         .center,
                //         //                                     borderRadius:
                //         //                                         BorderRadius
                //         //                                             .circular(
                //         //                                                 30),
                //         //                                     contentPadding:
                //         //                                         EdgeInsets
                //         //                                             .symmetric(
                //         //                                                 horizontal:
                //         //                                                     10,
                //         //                                                 vertical:
                //         //                                                     15),
                //         //                                   );
                //         //                                 }
                //         //                               },
                //         //                               child: IconOf(
                //         //                                   Icons
                //         //                                       .arrow_forward_ios_rounded,
                //         //                                   25,
                //         //                                   canGoForward() == true
                //         //                                       ? primaryColor
                //         //                                       : grey),
                //         //                             ),
                //         //                           )
                //         //                         ]),
                //         //                   ),
                //         //                 ),
                //         //               ],
                //         //             ),
                //         //           ),
                //         //           Expanded(
                //         //             flex: 1,
                //         //             child: Column(children: [
                //         //               CircleAvatar(
                //         //                 radius: 17,
                //         //                 backgroundColor: primaryColor,
                //         //                 child: CircleAvatar(
                //         //                     radius: 16,
                //         //                     backgroundColor: white,
                //         //                     child: ImageIcon(
                //         //                         AssetImage(widget.imageIcon!),
                //         //                         size: 30)),
                //         //               ),
                //         //               YMargin(2),
                //         //               TextOf(
                //         //                   widget.loginType ==
                //         //                           LoginType.individual
                //         //                       ? 'INDIVIDUAL'
                //         //                       : widget.loginType ==
                //         //                               LoginType.agent
                //         //                           ? 'AGENT'
                //         //                           : widget.loginType ==
                //         //                                   LoginType.merchant
                //         //                               ? 'MERCHANT'
                //         //                               : widget.loginType ==
                //         //                                       LoginType.staff
                //         //                                   ? 'STAFF'
                //         //                                   : widget.loginType ==
                //         //                                           LoginType
                //         //                                               .aggregator
                //         //                                       ? 'AGGREGATOR'
                //         //                                       : 'OUR WEBSITE',
                //         //                   12,
                //         //                   primaryColor,
                //         //                   FontWeight.w800),
                //         //             ]),
                //         //           ),
                //         //           Expanded(
                //         //             flex: 2,
                //         //             child: Row(
                //         //               mainAxisAlignment: MainAxisAlignment.end,
                //         //               children: [
                //         //                 InkWell(
                //         //                     onTap: () {
                //         //                       print("reload------");
                //         //                       webViewController?.reload();
                //         //                     },
                //         //                     child: Tooltip(
                //         //                       message: 'Refresh',
                //         //                       child: Card(
                //         //                         color: Colors.primaryColor[100],
                //         //                         shadowColor: Colors.primaryColor[100],
                //         //                         elevation: 2,
                //         //                         shape: RoundedRectangleBorder(
                //         //                             borderRadius:
                //         //                                 BorderRadius.circular(
                //         //                                     30)),
                //         //                         child: Padding(
                //         //                           padding:
                //         //                               const EdgeInsets.all(5.0),
                //         //                           child: IconOf(
                //         //                               Icons.refresh, 25, primaryColor),
                //         //                         ),
                //         //                       ),
                //         //                     )),
                //         //               ],
                //         //             ),
                //         //           ),
                //         //         ])),
                //         Divider(color: primaryColor),
                //       ],
                //     )),
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
                                // downloadUrl = this.url;
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
                                  // Launch the App
                                  // ignore: deprecated_member_use
                                  await launch(
                                    url,
                                  );
                                  // and cancel the request
                                  return NavigationActionPolicy.CANCEL;
                                }
                              }

                              return NavigationActionPolicy.ALLOW;
                            },
                            onLoadStop: (controller, url) async {
                              pullToRefreshController.endRefreshing();
                              setState(() {
                                this.url = url.toString();
                                // downloadUrl = this.url;
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
                                // downloadUrl = this.url;
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

                              // Directory? tempDir =
                              //     await getExternalStorageDirectory();
                              // setState(() {});
                              // print(
                              //     "progress: $progress\n onDownload ${url.url.toString()}\n ${tempDir!.path}");
                              // await FlutterDownloader.enqueue(
                              //   url: url.url.toString(),
                              //   fileName: url.suggestedFilename!
                              //       .replaceAll("_", " "), //File Name
                              //   savedDir: tempDir.path,
                              //   showNotification: true,
                              //   requiresStorageNotLow: false,
                              //   openFileFromNotification: true,
                              //   saveInPublicStorage: true,
                              // );
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
                      // if (webViewController != null) {
                      //         return InAppWebView(
                      //           key: webViewKey,
                      //           initialUrlRequest:
                      //               URLRequest(url: Uri.parse(siteUrl)),
                      //           initialOptions: options,
                      //           initialUserScripts:
                      //               UnmodifiableListView<UserScript>([]),
                      //           contextMenu: contextMenu,
                      //           pullToRefreshController:
                      //               pullToRefreshController,
                      //           onWebViewCreated:
                      //               (InAppWebViewController controller) async {
                      //             webViewController = controller;
                      //             setState(() {});
                      //           },
                      //           onLoadStart: (controller, url) {
                      //             setState(() {
                      //               this.url = url.toString();
                      //               urlController.text = this.url;
                      //             });
                      //           },
                      //           androidOnPermissionRequest:
                      //               (controller, origin, resources) async {
                      //             return PermissionRequestResponse(
                      //                 resources: resources,
                      //                 action: PermissionRequestResponseAction
                      //                     .GRANT);
                      //           },
                      //           shouldOverrideUrlLoading:
                      //               (controller, navigationAction) async {
                      //             var uri = navigationAction.request.url!;

                      //             if (![
                      //               "http",
                      //               "https",
                      //               "file",
                      //               "chrome",
                      //               "data",
                      //               "javascript",
                      //               "about"
                      //             ].contains(uri.scheme)) {
                      //               // ignore: deprecated_member_use
                      //               if (await canLaunch(url)) {
                      //                 // Launch the App
                      //                 // ignore: deprecated_member_use
                      //                 await launch(
                      //                   url,
                      //                 );
                      //                 // and cancel the request
                      //                 return NavigationActionPolicy.CANCEL;
                      //               }
                      //             }

                      //             return NavigationActionPolicy.ALLOW;
                      //           },
                      //           onLoadStop: (controller, url) async {
                      //             pullToRefreshController.endRefreshing();
                      //             setState(() {
                      //               this.url = url.toString();
                      //               urlController.text = this.url;
                      //             });
                      //           },
                      //           onLoadError: (controller, url, code, message) {
                      //             pullToRefreshController.endRefreshing();
                      //             setState(() {
                      //               progress = 0.0;
                      //             });
                      //           },
                      //           onProgressChanged: (controller, progress) {
                      //             if (progress == 1.0) {
                      //               pullToRefreshController.endRefreshing();
                      //             }
                      //             setState(() {
                      //               this.progress = progress.toDouble();
                      //               urlController.text = this.url;
                      //             });
                      //           },
                      //           onDownloadStartRequest:
                      //               (controller, url) async {
                      //             Directory? tempDir =
                      //                 await getExternalStorageDirectory();
                      //             setState(() {});
                      //             print(
                      //                 "progress: $progress\n onDownload ${url.url.toString()}\n ${tempDir!.path}");
                      //             await FlutterDownloader.enqueue(
                      //               url: url.url.toString(),
                      //               fileName: url.suggestedFilename!
                      //                   .replaceAll("_", " "), //File Name
                      //               savedDir: tempDir.path,
                      //               showNotification: true,
                      //               requiresStorageNotLow: false,
                      //               openFileFromNotification: true,
                      //               saveInPublicStorage: true,
                      //             );
                      //           },
                      //           onUpdateVisitedHistory:
                      //               (controller, url, androidIsReload) {
                      //             setState(() {
                      //               this.url = url.toString();
                      //               urlController.text = this.url;
                      //             });
                      //           },
                      //           onConsoleMessage: (controller, consoleMessage) {
                      //             print(consoleMessage);
                      //           },
                      //         );

                      //       } else {
                      //         return Center(
                      //             child: CupertinoActivityIndicator(
                      //           color: primaryColor,
                      //           animating: true,
                      //           radius: 30,
                      //         ));
                      //       },

                      progress < 1.0
                          ? LoadingPage()
                          //   if (downloadProgress > 0 && downloadProgress < 100)
                          // LinearProgressIndicator(
                          //   value: progress / 100,
                          //   color: Colors.orange,
                          // ),
                          : Container(),
                    ],
                  ),
                )
              ]),
            ),
          )
        : ErrorPage(controller: webViewController);
  }
}


  // onDownloadStartRequest: (controller, url) async {
  //                         Directory? tempDir =
  //                             await getExternalStorageDirectory();
  //                         setState(() {});
  //                         print(
  //                             "progress: $progress\n onDownload ${url.url.toString()}\n ${tempDir!.path}");
  //                         await FlutterDownloader.enqueue(
  //                           url: url.url.toString(),
  //                           fileName: url.suggestedFilename!
  //                               .replaceAll("_", " "), //File Name
  //                           savedDir: tempDir.path,
  //                           showNotification: true,
  //                           requiresStorageNotLow: false,
  //                           openFileFromNotification: true,
  //                           saveInPublicStorage: true,
  //                         );
  //                       },