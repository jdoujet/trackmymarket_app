import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';
import 'package:trackmymarket_app/main.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  bool isWorking = false;
  String result="";
  late CameraController cameraController;
  late CameraImage imgCamera;

  loadModel() async
  {
    await Tflite.loadModel(
      model: "assets/mobilenet_v1_1.0_224.tflite",
      labels: "assets/mobilenet_v1_1.0_224.txt",
    );
  }

  initCamera()
  {
    cameraController = CameraController(cameras[0], ResolutionPreset.medium);
    cameraController.initialize().then((value)
    {
      if(!mounted)
      {
        return;
      }
      setState(() {
        cameraController.startImageStream((imageFromStream) =>
        {
          //if the camera isnt busy then we can start the live camera
          if(!isWorking)
          {
            //it means that the camera is busy now
            isWorking = true,
            imgCamera = imageFromStream,
            runModelOnStreamFrames(),
          }
        });
      });
    });
  }

  runModelOnStreamFrames() async{
    if(imgCamera!=null)
    {
      var recognitions = await Tflite.runModelOnFrame(
          bytesList: imgCamera.planes.map((plane)
          {
            return plane.bytes;
          }).toList(),

          imageHeight: imgCamera.height,
          imageWidth: imgCamera.width,
          imageMean: 127.5,
          imageStd: 127.5,
          rotation: 90,
          numResults: 2,
          threshold: 0.1,
          asynch: true,
      );
      
      result = "";

      //verify is its not null before displaying result and probability
      recognitions?.forEach((response)
      {
        result += response["label"] + " " + (response["confidence"] as double).toStringAsFixed(2)+ "\n\n";
      });

      //this component and its children are re-rendered with the updated state.
      setState(() {
        result;
      });

      isWorking=false;
    }
  }
  @override
  //load the model when init state
  void initState() {
    super.initState();
    loadModel();
  }

  @override
  //dispose method used to release the memory allocated to variables when state object is removed.
  void dispose() async{
    super.dispose();

    await Tflite.close();
    cameraController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SafeArea(
        child: Scaffold(
          body: Container(
            decoration: BoxDecoration(
              color: Colors.orange,
            ),
            child: Column(
              children: [
                Stack(
                  children: [
                    Center(
                      child: Container(
                        color: Colors.orange,
                        height: 320,
                        width: 360,
                        child: Image.asset("assets/trackmymarket.png"),
                      ),
                    ),
                    Center(
                      child: FlatButton(
                        onPressed : ()
                        {
                          initCamera();
                        },
                        child: Container(
                          margin: EdgeInsets.only(top:35),
                          height : 270,
                          width: 360,
                          child: imgCamera == null
                              ? Container(
                            height: 270,
                            width: 360,
                            child: Icon(Icons.photo_camera_front, color: Colors.blueAccent, size: 40,),
                          )
                              : AspectRatio(
                            aspectRatio: cameraController.value.aspectRatio,
                            child: CameraPreview(cameraController),
                          ),
                        ),
                      ),

                    ),
                  ],
                ),
                Center(
                  child: Container(
                    margin: EdgeInsets.only(top: 55.0),
                    child: SingleChildScrollView(
                      child: Text(
                        result,
                        style: TextStyle(
                          backgroundColor: Colors.blueAccent,
                          fontSize: 30.0,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),

          ),
        ),
      ),

    );
  }
}
