import 'package:simple_slidable/slide_controller.dart';
import 'package:flutter/material.dart';
import 'package:simple_slidable/slidable.dart';

void main() {
  runApp(SimpleSladableExample());
}

class SimpleSladableExample extends StatelessWidget {
  final SlideController slideController = SlideController();
  final _contr = TextEditingController(text: 'change this text and slide me');

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Simple slidable demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: Material(
          child: Container(
              padding: EdgeInsets.all(16.0),
              color: Colors.white,
              child: SizedBox(
                width: double.maxFinite,
                height: double.maxFinite,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //
                    //
                    // SLIDABLE BEGIN //////////////////////////////////////////////
                    Slidable(
                      controller: slideController,
                      minShiftPercent: 0.3,
                      percentageBias: 1,
                      child: Container(
                        alignment: Alignment.center,
                        width: 200,
                        color: Colors.yellow,
                        child: TextFormField(
                            controller: _contr,
                            onChanged: (_) {
                              print('onChanged');
                              slideController.rebuildState();
                            },
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
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
                              height: 60,
                              width: 120,
                              child: RaisedButton(
                                onPressed: () {},
                                child: Text(
                                  'Button',
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

                    SizedBox(
                      height: 80,
                    ),
                    Text('Optional:',
                        style: TextStyle(
                            decoration: TextDecoration.none,
                            fontSize: 16,
                            color: Colors.black)),
                    SizedBox(
                      height: 10,
                    ),
                    RaisedButton(
                      color: Colors.green,
                      onPressed: () {
                        slideController.isOpened
                            ? slideController.close()
                            : slideController.open();
                      },
                      child: Text(
                        'Slide controller',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              )),
        ));
  }
}
