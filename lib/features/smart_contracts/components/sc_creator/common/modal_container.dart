import 'package:flutter/material.dart';

class ModalContainer extends StatelessWidget {
  final List<Widget> children;
  final Color color;
  final bool withClose;
  final bool withDecor;
  final double padding;
  final String? title;
  const ModalContainer({
    Key? key,
    this.color = const Color(0xFF0b0d0f),
    this.children = const [],
    this.withClose = false,
    this.withDecor = true,
    this.padding = 32.0,
    this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (withClose || title != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: Row(
                      mainAxisAlignment: withClose && title != null
                          ? MainAxisAlignment.spaceBetween
                          : title != null
                              ? MainAxisAlignment.start
                              : MainAxisAlignment.end,
                      children: [
                        if (title != null)
                          Text(
                            title!,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        if (withClose)
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text(
                              "Close",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                      ],
                    ),
                  ),
                ...children,
                SizedBox(
                  height: 40,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
