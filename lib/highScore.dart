import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class highscoretile extends StatelessWidget {
  final String docId;

  highscoretile({Key? key, required this.docId}) : super(key: key);

  CollectionReference highscore =
  FirebaseFirestore.instance.collection('snake_hight_score');

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
        future: highscore.doc(docId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done){
            Map<String, dynamic> data =
                snapshot.data!.data() as Map<String, dynamic>;
            return Row(
              children: [
                Text(data['score'].toString()),
                const SizedBox(width: 5,),
                Text(data['name']),
              ],
            );
          }else{
            return Text('Loading');
          }
        });
  }
}
