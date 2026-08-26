import 'package:flutter/material.dart';
import '../../data/models/category_model.dart';
import '../widgets/category_grid_section.dart';

class AllCategoriesPage extends StatelessWidget {
  final List<CategoryModel> categories;
  final void Function(CategoryModel) onCategoryTap;

  const AllCategoriesPage({
    super.key,
    required this.categories,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    final mainCats = categories.where((c) => c.parentId == null).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('كل الفئات'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: mainCats.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 18,
            crossAxisSpacing: 8,
            childAspectRatio: 0.8,
          ),
          itemBuilder: (context, index) {
            final cat = mainCats[index];
            return InkWell(
              onTap: () => onCategoryTap(cat),
              borderRadius: BorderRadius.circular(16),
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: colorForCategory(cat.icon).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Icon(
                        iconForCategory(cat.icon),
                        color: colorForCategory(cat.icon),
                        size: 26,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    cat.nameAr,
                    style: const TextStyle(fontSize: 10.5),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}