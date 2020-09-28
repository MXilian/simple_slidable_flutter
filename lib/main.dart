import 'package:simple_slidable/slidable_controller.dart';
import 'package:flutter/material.dart';
import 'package:simple_slidable/slidable.dart';

void main() {
  runApp(SimpleSladableExample());
}

class SimpleSladableExample extends StatelessWidget {
  final SlidableController controller = SlidableController();

  // This widget is the root of your application.
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  width: 200,
                  height: 100,
                  //
                  // SLIDABLE BEGIN
                  child: Slidable(
                    controller: controller,
                    minShiftPercent: 0.3,
                    percentageBias: 1,
                    child: Container(
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
                    actions: Container(
                      height: double.maxFinite,
                      color: Colors.red,
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 60, width: 120,
                            child: RaisedButton(
                              onPressed: () {},
                              child: Text('Button',
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
                  // SLIDABLE END
                  //
                ),
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