import 'package:flutter/material.dart';

// Implement Google sign-in logic if needed

class GoogleButton extends StatelessWidget {
  const GoogleButton({super.key, Future<void> Function()? onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(

        elevation: 5,
        padding: const EdgeInsets.all(12.0),
        // backgroundColor: Colors.red,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      
      label: const Text(
        "Sign in with Google",
        style: TextStyle(color: Colors.black),
      ),
      onPressed: () {},
    );
  }
}

