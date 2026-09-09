import 'package:flutter/material.dart';

void ShowSnackBar(BuildContext context, String string) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(string),
      duration: const Duration(seconds: 5),

      width: 480.0, // Width of the SnackBar.
      padding: const EdgeInsets.symmetric(
        horizontal: 3.0, // Inner padding for SnackBar content.
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
    ),
  );
}
