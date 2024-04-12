import 'package:flutter/material.dart';

import 'package:custom_text_example/widgets/description.dart';

class HorizontalLayout extends StatelessWidget {
  const HorizontalLayout({
    required this.maxWidth,
    required this.description,
    required this.example,
    required this.output,
  });

  final double maxWidth;
  final Description description;
  final Widget example;
  final Widget output;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                description,
                example,
              ],
            ),
          ),
        ),
        const VerticalDivider(
          width: 1.0,
          thickness: 1.0,
          color: Colors.black26,
        ),
        Expanded(
          flex: 3,
          child: SizedBox(
            height: double.infinity,
            child: output,
          ),
        ),
      ],
    );
  }
}

class VerticalLayout extends StatelessWidget {
  const VerticalLayout({
    required this.maxHeight,
    required this.description,
    required this.example,
    required this.output,
  });

  final double maxHeight;
  final Description description;
  final Widget example;
  final Widget output;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: maxHeight,
        ),
        child: IntrinsicHeight(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              description,
              Expanded(
                child: example,
              ),
              const Divider(
                height: 1.0,
                thickness: 1.0,
                color: Colors.black26,
              ),
              SizedBox(
                width: double.infinity,
                height: 150.0,
                child: output,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
