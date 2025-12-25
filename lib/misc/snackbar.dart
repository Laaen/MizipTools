import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String message){
  final snackbar = SnackBar(content: Text(message), duration: Duration(seconds: 2),);
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(snackbar);
}