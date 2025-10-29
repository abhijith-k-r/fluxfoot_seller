// ! Brand LOGO Adding Widget
import 'package:flutter/material.dart';
import 'package:fluxfoot_seller/core/themes/app_theme.dart';
import 'package:fluxfoot_seller/core/widgets/custom_text.dart';

Widget buildAddEditProductImage({
  required double size,
  required List<String> imageUrls,
  required String title,
  required VoidCallback onAddTap,
  required void Function(int) onRemove,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      customText(14, title, fontWeight: FontWeight.bold),
      SizedBox(height: 8),
      SizedBox(
        height: size * 0.2,
        child: GridView.builder(
          itemCount: imageUrls.length + 1,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 2.99 / 2,
          ),
          itemBuilder: (context, index) {
            if (index == imageUrls.length) {
              return GestureDetector(
                onTap: onAddTap,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: WebColors.borderSideGrey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add_a_photo),
                ),
              );
            }
            // Otherwise, it's an existing image
            final url = imageUrls[index];
            return Stack(
              alignment: Alignment.topRight,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(child: Image.network(url, fit: BoxFit.cover)),
                ),
                // Remove button for the image
                IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: () => onRemove(index),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            );
          },
        ),
      ),
    ],
  );
}
