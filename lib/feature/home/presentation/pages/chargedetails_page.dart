import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:arch/feature/home/presentation/controllers/home_controller.dart'; // Auth controller
import 'package:arch/utils/widgets/inputfield/input_feild.dart'; // Import the UserIdInput
import 'package:arch/utils/widgets/button/button.dart'; // Import the SimpleButton

class LoginPage extends StatelessWidget {
  LoginPage({super.key});
  final controller = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView( // Wrapping entire body in a SingleChildScrollView
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Enter User ID",
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Obx(() {
                        return UserIdInput(
                          controller: controller.userIdController,
                          errorText: controller.validationError.value,
                          onChanged: (value) {
                            controller.validationError.value = controller.validateUserId();
                          },
                        );
                      }),
                      const SizedBox(height: 16),
                      Obx(() {
                        return SimpleButton(
                          text: 'Get Details',
                          onPressed: controller.isLoading.value
                              ? () {} // Provide an empty function if loading is true
                              : () {
                            controller.validationError.value = controller.validateUserId();
                            if (controller.validationError.value == null) {
                              controller.handleGetChargerDetails();
                            }
                          },
                          isLoading: controller.isLoading.value,
                        );
                      }),
                      const SizedBox(height: 24),
                      Obx(() {

                        return Container(); // Empty container if no error
                      }),
                      const SizedBox(height: 24),
                      Obx(() {
                        if (controller.isLoading.value) {
                          return Center(child: CircularProgressIndicator());
                        } else if (controller.chargerDetails.isNotEmpty) {
                          return ListView.builder(
                            shrinkWrap: true, // To prevent overflow in column
                            physics: NeverScrollableScrollPhysics(), // Disable internal scrolling
                            itemCount: controller.chargerDetails.length,
                            itemBuilder: (context, index) {
                              final details = controller.chargerDetails[index];
                              return ListTile(
                                contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                                title: Text('Charger ID: ${details.chargerId ?? 'N/A'}', style: TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Model: ${details.model ?? 'N/A'}'),
                                    Text('Type: ${details.type ?? 'N/A'}'),
                                    Text('Vendor: ${details.vendor ?? 'N/A'}'),
                                    Text('Max Current: ${details.maxCurrent ?? 'N/A'} A'),
                                    Text('Max Power: ${details.maxPower ?? 'N/A'} W'),
                                    Text('Socket Count: ${details.socketCount ?? 'N/A'}'),
                                    Text('IP: ${details.ip ?? 'N/A'}'),
                                    Text('Address: ${details.address ?? 'N/A'}'),
                                  ],
                                ),
                              );
                            },
                          );
                        }
                        return Container(); // No details to show
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
