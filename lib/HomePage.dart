import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:snake_game_use_firebase/Food_pixel%5D.dart';
import 'package:snake_game_use_firebase/blank_pixel.dart';
import 'package:snake_game_use_firebase/highScore.dart';
import 'package:snake_game_use_firebase/snakePixel.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

enum snake_deration { UP, DOWN, RIGHT, LEFT }

class _HomePageState extends State<HomePage> {
  final TextEditingController _nameController = TextEditingController();

  /// grid dimenstion
  int rowSize = 10;
  int totalnumberofsquard = 100;
  List<int> snakpos = [
    0,
    1,
    2,
  ];
  int currentscore = 0;

  //CURENT DERATION
  var currentDetation = snake_deration.RIGHT;

  //Food position
  int foodpos = 44;

  //highscore list
  List<String> highscore_DocIds = [];
  late final Future? letsgetDocId;

  @override
  void initState() {
    letsgetDocId = getDocId();
    super.initState();
  }

  Future getDocId() async {
    await FirebaseFirestore.instance
        .collection('snake_hight_score')
        .orderBy('score', descending: true)
        .limit(10)
        .get()
        .then((value) => value.docs.forEach((element) {
              highscore_DocIds.add(element.reference.id);
            }));
  }

  bool gamehasstared = false;

  void startGame() {
    gamehasstared = true;
    Timer.periodic(Duration(milliseconds: 200), (timer) {
      setState(() {
        //keep the snake moving!
        movesnake();
        //check if the game is over
        if (gameover()) {
          timer.cancel();

          //show a message to user

          showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('Game over'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Your score is: ' + currentscore.toString()),
                      TextFormField(
                        controller: _nameController,
                        decoration:
                            InputDecoration(hintText: 'Enter your name'),
                      )
                    ],
                  ),
                  actions: [
                    MaterialButton(
                      onPressed: () {
                        submittedscore();
                        Navigator.of(context).pop();
                        newgame();
                      },
                      color: Colors.pink,
                      child: Text('Submit'),
                    )
                  ],
                );
              });
        }
      });
    });
  }

  Future newgame() async {
    highscore_DocIds = [];
    await getDocId();
    setState(() {
      snakpos = [
        0,
        1,
        2,
      ];
      foodpos = 55;
      currentDetation = snake_deration.RIGHT;
      gamehasstared = false;
      currentscore = 0;
    });
  }

  void submittedscore() {
    var database = FirebaseFirestore.instance;
    database.collection('snake_hight_score').add({
      'name': _nameController.text,
      'score': currentscore,
    });
    _nameController.clear();
  }

  void eatFood() {
    currentscore++;
    while (snakpos.contains(foodpos)) {
      foodpos = Random().nextInt(totalnumberofsquard);
    }
  }

  void movesnake() {
    switch (currentDetation) {
      case snake_deration.RIGHT:
        {
          //if snake is at the last wall need to adjust

          if (snakpos.last % rowSize == 9) {
            snakpos.add(snakpos.last + 1 - rowSize);
          } else {
            //add
            snakpos.add(snakpos.last + 1);
          }
        }
        break;
      case snake_deration.LEFT:
        {
          //if snake is at the last wall need to adjust

          if (snakpos.last % rowSize == 0) {
            snakpos.add(snakpos.last - 1 + rowSize);
          } else {
            //add
            snakpos.add(snakpos.last - 1);
          }
        }
        break;
      case snake_deration.UP:
        {
          //add
          if (snakpos.last < rowSize) {
            snakpos.add(snakpos.last - rowSize + totalnumberofsquard);
          } else {
            snakpos.add(snakpos.last - rowSize);
          }
        }
        break;
      case snake_deration.DOWN:
        {
          //add
          if (snakpos.last + rowSize > totalnumberofsquard) {
            snakpos.add(snakpos.last + rowSize - totalnumberofsquard);
          } else {
            snakpos.add(snakpos.last + rowSize);
          }
        }
        break;
      default:
    }
    //snake eating food
    if (snakpos.last == foodpos) {
      eatFood();
    } else {
      snakpos.removeAt(0);
    }
  }

  bool gameover() {
    // the game is over when the snake run into itself
    //this occurs when there is a duplicate in the snakepos list

    List<int> bodysnake = snakpos.sublist(0, snakpos.length - 1);
    if (bodysnake.contains(snakpos.last)) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            ///score
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    //current score
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // current score
                        Text(
                          'Score',
                          style: TextStyle(fontSize: 25),
                        ),
                        Text(
                          currentscore.toString(),
                          style: TextStyle(fontSize: 25),
                        ),
                      ],
                    ),
                    const SizedBox(
                      width: 200,
                    ),
                    // high score
                    Expanded(
                      child: gamehasstared ? Container()
                          :  FutureBuilder(
                          future: letsgetDocId,
                          builder: (context, snapshot) {
                            return ListView.builder(
                                scrollDirection: Axis.vertical,
                                itemCount: highscore_DocIds.length,
                                itemBuilder: (context, index) {
                                  return highscoretile(
                                      docId: highscore_DocIds[index]);
                                });
                          }),
                    )
                  ],
                ),
              ),
            ),

            /// game grid

            Expanded(
                flex: 3,
                child: GestureDetector(
                  onVerticalDragUpdate: (details) {
                    if (details.delta.dy > 0 &&
                        currentDetation != snake_deration.UP) {
                      currentDetation = snake_deration.DOWN;
                    } else if (details.delta.dy < 0 &&
                        currentDetation != snake_deration.DOWN) {
                      currentDetation = snake_deration.UP;
                    }
                  },
                  onHorizontalDragUpdate: (details) {
                    if (details.delta.dx > 0 &&
                        currentDetation != snake_deration.LEFT) {
                      currentDetation = snake_deration.RIGHT;
                    } else if (details.delta.dx < 0 &&
                        currentDetation != snake_deration.RIGHT) {
                      currentDetation = snake_deration.LEFT;
                    }
                  },
                  child: GridView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: totalnumberofsquard,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: rowSize),
                    itemBuilder: (context, index) {
                      if (snakpos.contains(index)) {
                        return const SnakePixel();
                      } else if (foodpos == index) {
                        return const FoodPixel();
                      } else {
                        return const BlankFixel();
                      }
                    },
                  ),
                )),

            ///play button
            Expanded(
                child: Container(
              child: Center(
                child: MaterialButton(
                  child: Text('PLAY'),
                  color: gamehasstared ? Colors.grey : Colors.pink,
                  onPressed: () {
                    gamehasstared ? () {} : startGame();
                  },
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
