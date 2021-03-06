import 'package:simple_slidable/slide_controller.dart';
import 'package:flutter/material.dart';
import 'package:simple_slidable/slidable.dart';

void main() {
  runApp(SimpleSlidableExample());
}

class SimpleSlidableExample extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _SimpleSlidableExampleState();

}

class _SimpleSlidableExampleState extends State<SimpleSlidableExample> {

  final SlideController controller = SlideController();
  double height = 80;

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Simple slidable demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Container(
          padding: EdgeInsets.all(16.0),
          color: Colors.white,
          child: SizedBox(
            width: double.maxFinite,
            height: double.maxFinite,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 200,),
                //
                //
                // SLIDABLE BEGIN //////////////////////////////////////////////
                Slidable(
                  controller: controller,
                  minShiftPercent: 0.3,
                  percentageBias: 1,
                  child: Container(
                    height: height,
                    alignment: Alignment.center,
                    color: Colors.yellow,
                    child: Text(
                      'Slide me',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          decoration: TextDecoration.none),
                    ),
                  ),
                  isLeftEqualsRight: true,
                  slideMenuL: Container(
                    height: double.maxFinite,
                    color: Colors.red,
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 60, width: 180,
                          child: RaisedButton(
                            onPressed: () {
                              setState(() {
                                height == 80 ? height = 160 : height = 80;
                              });
                            },
                            child: Text('Button\n(change size)',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  decoration: TextDecoration.none),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // SLIDABLE END ////////////////////////////////////////////////
                //
                //
                SizedBox(height: 80,),
                Text('Optional:', style: TextStyle(decoration: TextDecoration.none,
                    fontSize: 16, color: Colors.black)),
                SizedBox(height: 10,),
                RaisedButton(
                  color: Colors.green,
                  onPressed: () {
                    controller.isOpened
                        ? controller.close()
                        : controller.open();
                  },
                  child: Text(
                    'Slide controller',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
