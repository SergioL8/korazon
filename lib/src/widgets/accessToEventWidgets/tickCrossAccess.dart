import 'package:flutter/material.dart';


class TickCrossAccess extends StatelessWidget {
  const TickCrossAccess({super.key, required this.access});
  final bool access;

  @override
  Widget build(BuildContext context) {
    return access 

    ? Stack( // this is the "image" of the tick at the top of the screen
      alignment: Alignment.center, // aling the tick and the circle
      children: [
        CircleAvatar( // a circle to contain the tick
          radius: 40,
          backgroundColor: Colors.white,
        ),
        Icon( // the tick itself
          Icons.check,
          color: Colors.green,
          size: 50,
        ),
      ],
    )


    : Stack( // this is the "image" of the cross at the top of the screen
      alignment: Alignment.center, // aling the cross and the circle
      children: [
        CircleAvatar( // a circle to contain the cross
          radius: 40,
          backgroundColor: Colors.white,
        ),
        Icon(Icons.close, // the cross itself
          color: const Color.fromARGB(255, 177, 23, 23),
          size: 50,
        ),
      ],
    );
  }
}