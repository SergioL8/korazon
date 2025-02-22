import 'package:flutter/material.dart';
import 'package:korazon/src/utilities/design_variables.dart';



final iconGradient = LinearGradient(
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
  colors: [
    Color.fromARGB(255, 210, 15, 132),
    Color.fromRGBO(255, 58, 176, 1),
  ]
);


class GradientBorderButton extends StatelessWidget {
  const GradientBorderButton({super.key, required this.onTap, required this.text});
  
  final VoidCallback onTap;
  final String text;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          ShaderMask(
            shaderCallback: (Rect bounds) {
              return borderGradient.createShader(bounds);
            },
            child: Container(
              height: 55,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.white, // placeholder color (really this is replaced by the gradient)
                  width: 1.75
                ),
              ),
            ),
          ),
          Row(
            children: [
              SizedBox(width: 25),
              Text(
                text,
                style: whiteSubtitle,
                overflow: TextOverflow.ellipsis,
              ),
              Spacer(),
              ShaderMask(
                shaderCallback: (Rect bounds) {
                  return iconGradient.createShader(bounds);
                },
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 15),
            ],
          )
        ]
      ),
    );
  }
}



