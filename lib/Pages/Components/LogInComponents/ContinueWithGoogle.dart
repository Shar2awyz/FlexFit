import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Continuewithgoogle extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
return Container(

    width: double.infinity,
    height: 50
    ,
    decoration: BoxDecoration(color:Colors.white,borderRadius: BorderRadius.circular(25)),

    child: Padding(padding: EdgeInsets.all(10),child: Row(

      children: [Container(alignment: Alignment.centerLeft,child: Image.asset("images/google.png",width: 70,height: 70,),

      ),
        SizedBox(width: 40,),
        Container(alignment: Alignment.center,child: Text("Continue with google",style: TextStyle(color: Colors.black,fontSize: 17,fontWeight: FontWeight.bold),),),],

    ),)

);
  }


}