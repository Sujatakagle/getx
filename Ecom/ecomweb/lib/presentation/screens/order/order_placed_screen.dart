import 'package:ecomweb/core/ui.dart';
import 'package:ecomweb/presentation/widgets/gap_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ecomweb/logic/services/app_colors.dart'; // Import TextStyles

class OrderPlacedScreen extends StatefulWidget {
  const OrderPlacedScreen({super.key});

  static const routeName = "order_placed";

  @override
  State<OrderPlacedScreen> createState() => _OrderPlacedScreenState();
}

class _OrderPlacedScreenState extends State<OrderPlacedScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Placed!"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 32
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Icon(CupertinoIcons.cube_box_fill, color: AppColors.textLight, size: 100),
              const GapWidget(size: -8),
              Text("Order Placed!", style: TextStyles.heading3(context)),  // Use TextStyles.heading3 with context
              const GapWidget(size: -5),
              Text("You can check out the status by going to Profile > My Orders", style: TextStyles.body2(context), textAlign: TextAlign.center),  // Use TextStyles.body2 with context

            ],
          ),
        ),
      ),
    );
  }
}
