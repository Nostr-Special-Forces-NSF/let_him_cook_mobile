import 'package:flutter/material.dart';

class TimeServingsEdit extends StatelessWidget {
  final TextEditingController prepController;
  final TextEditingController cookController;
  final TextEditingController servingsController;

  const TimeServingsEdit({
    super.key,
    required this.prepController,
    required this.cookController,
    required this.servingsController,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Prep / Cook / Servings',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            // We'll use a Wrap so it flows nicely if the screen is narrow.
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _buildField('Prep Time', prepController, 'e.g. 20 min'),
                _buildField('Cook Time', cookController, 'e.g. 1 hour'),
                _buildField('Servings', servingsController, 'e.g. 4 persons'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller,
    String placeholder,
  ) {
    return SizedBox(
      width: 100, // same style as NutritionalInfoEdit
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          TextField(
            controller: controller,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              isDense: true,
              hintText: placeholder,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 6,
                horizontal: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
