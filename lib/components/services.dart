
import 'package:flutter/material.dart';

class Box extends StatefulWidget {
  const Box({
    super.key,
    required this.func,
    required this.side,
    required this.color,
    required this.icon,
    required this.ic,
    required this.title,
    required this.sub,
  });

  final func;
  final side;
  final color;
  final icon;
  final ic;
  final title;
  final sub;
  @override
  State<Box> createState() => _BoxState();
}

class _BoxState extends State<Box> {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: widget.func,
      child: ServiceBox(
          side: widget.side,
          color: widget.color,
          icon: widget.icon,
          ic: widget.ic,
          title: widget.title,
          sub: widget.sub),
    );
  }
}

class ServiceBox extends StatefulWidget {
  const ServiceBox({
    super.key,
    required this.side,
    required this.color,
    required this.icon,
    required this.ic,
    required this.title,
    required this.sub,
  });

  final side;
  final color;
  final icon;
  final ic;
  final title;
  final sub;

  @override
  State<ServiceBox> createState() => _ServiceBoxState();
}

class _ServiceBoxState extends State<ServiceBox> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment:
      widget.side == 'l' ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: widget.side == 'l'
                ? const Radius.circular(20)
                : const Radius.circular(0),
            bottomRight: widget.side == 'r'
                ? const Radius.circular(20)
                : const Radius.circular(0),
          ),
          color: widget.color,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Colors.white,
                ),
                child: Icon(
                  widget.icon,
                  color: widget.ic,
                ),
              ),
            ),
            Text(
              widget.title,
              style: const TextStyle(color: Colors.black, fontSize: 14),
            ),
            Text(
              widget.sub,
              style: const TextStyle(color: Colors.black, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}