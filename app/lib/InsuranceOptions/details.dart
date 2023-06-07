// a page to display details about a specific item
import 'package:flutter/material.dart';
import 'package:app/model/option_model.dart';

class Description extends StatelessWidget {
  const Description({
    Key? key,
    required this.option,
  }) : super(key: key);

  final OptionModel option;
  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: Text(
              option.description!,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          )
        ]);
  }
}
