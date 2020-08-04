import 'dart:io' as io;
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

List localDataList = [
  ['Image', 'Video', 'Pdf', 'Audio'],
  [
    'https://firebasestorage.googleapis.com/v0/b/angel-study-circle.appspot.com/o/11.jpg?alt=media&token=6586acff-6fc6-487e-a1ed-d59963e8048c',
    'https://firebasestorage.googleapis.com/v0/b/angel-study-circle.appspot.com/o/big_buck_bunny_720p_5mb.mp4?alt=media&token=64180039-5e62-4aa5-8e18-b1bb7b33bcc3',
    'https://firebasestorage.googleapis.com/v0/b/angel-study-circle.appspot.com/o/FatehSinghResume.pdf?alt=media&token=c1d575ad-c129-4c19-b39d-8d8449941254',
    'https://firebasestorage.googleapis.com/v0/b/angel-study-circle.appspot.com/o/01%20HAUN%20RAH%20NA%20SAKA%20BIN%20DEKHE%20PRITMA%20.mp3?alt=media&token=6b63e6ac-f7a6-4272-990b-623e89026969'
  ],
  ['jpg', 'mp4', 'pdf', 'mp3']
];
String progressString = '0%';
var progressValue = 0.0;

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  @override
  void initState() {
    super.initState();
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('@mipmap/ic_launcher'); 
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: onSelectNotification);
  }

   Future _showNotificationWithoutSound(String path) async {
  var androidPlatformChannelSpecifics = new AndroidNotificationDetails('your channel id', 'your channel name', 'your channel description',playSound: false, importance: Importance.Max, priority: Priority.High);
  var iOSPlatformChannelSpecifics =new IOSNotificationDetails(presentSound: false);
  var platformChannelSpecifics = new NotificationDetails(
      androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
    0,
    'New Post',
    'How to Show Notification in Flutter',
    platformChannelSpecifics,
    payload: path,
  );
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('File Downloading'),
      ),
      body: ListView.builder(
          itemCount: localDataList[0].length,
          itemBuilder: (c, index) {
            return ListTile(
              leading: CircleAvatar(
                child: Center(child: Text((index + 1).toString())),
              ),
              title: Text(localDataList[0][index].toString()),
              subtitle: Text(localDataList[2][index].toString()),
              trailing: RaisedButton(
                onPressed: () {
                  downloadFile(localDataList[1][index], localDataList[0][index], localDataList[2][index]);
                },
                child: Text('Download File'),
              ),
            );
          }),
    );
  }

  Future<void> downloadFile(
      String url, String fileName, String extension) async {
    var dio = new Dio();
    var dir = await getExternalStorageDirectory();
    var knockDir =
        await new Directory('${dir.path}/AZAR').create(recursive: true);
    print("Hello checking the file in Externaal Sorage");
    io.File('${knockDir.path}/$fileName.$extension').exists().then((a) async {
      if(a){
        print('${knockDir.path}/$fileName.$extension');
        _showNotificationWithoutSound('${knockDir.path}/$fileName.$extension');
      }else{
         print("Downloading file");
        openDialog();
        await dio.download(url, '${knockDir.path}/$fileName.$extension',
            onReceiveProgress: (rec, total) {
          if (mounted) {
            setState(() {
              progressValue = (rec / total);
              progressString = ((rec / total) * 100).toStringAsFixed(0) + "%";
              myDialogState.setState(() {
                myDialogState.progressData = progressString;
                myDialogState.progressValue = progressValue;
              });
            });
          }
        });
        if (mounted) {
          setState(() {
            print('${knockDir.path}');
            // TODO write your function to open file
          });
        }
        _showNotificationWithoutSound('${knockDir.path}/$fileName.$extension');
        print("Download completed");
      }
       
      
    });
  }

  openDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return MyDialog();
      },
    );
  }
  Future onSelectNotification(String payload) async {
    final result = await OpenFile.open(payload);

    // showDialog(
    //   context: context,
    //   builder: (_) {
    //     return new AlertDialog(
    //       title: Text("PayLoad"),
    //       content: Text("Payload : $payload"),
    //     );
    //   },
    // );
  }

  Future<void> openFile() async {

 

    setState(() {
      //_openResult = "type=${result.type}  message=${result.message}";
    });

  }
}

_MyDialogState myDialogState;

class MyDialog extends StatefulWidget {
  @override
  _MyDialogState createState() {
    myDialogState = _MyDialogState();
    return myDialogState;
  }
}

class _MyDialogState extends State<MyDialog> {
  String progressData = '0%';
  var progressValue=0.0;
  @override
  Widget build(BuildContext context) {
    print(progressValue);
    return AlertDialog(
      content: LinearProgressIndicator(
        value: progressValue,
        backgroundColor: Colors.red,
      ),
      title: Text(progressData),
      actions: <Widget>[
        progressValue==1.0?RaisedButton(child: Text('Done'), onPressed: () {
        // TODO write your function to open file
          Navigator.pop(context);
      }):Container()
      ],
    );
    
  }


   
}


