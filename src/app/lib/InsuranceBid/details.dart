// a page to display details about a specific item
import 'package:flutter/material.dart';
import 'package:app/model/basket_model.dart';

class Description extends StatelessWidget {
  const Description({
    Key? key,
    required this.basket,
  }) : super(key: key);

  final BasketModel basket;
  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: Text(
              basket.description!,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          )
        ]);
  }
}
