import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../models/category.dart';

abstract class CategoryEvent {}

class LoadCategories extends CategoryEvent {}

class AddCategory extends CategoryEvent {
  final Category category;

  AddCategory(this.category);
}

class UpdateCategory extends CategoryEvent {
  final Category category;

  UpdateCategory(this.category);
}

class DeleteCategory extends CategoryEvent {
  final int id;

  DeleteCategory(this.id);
}

class LoadCategoriesWithSpentAmounts extends CategoryEvent {
  final DateTimeRange dateRange;

  LoadCategoriesWithSpentAmounts(this.dateRange);
}

class UpdateLocalizedCategories extends CategoryEvent {
  final AppLocalizations localizations;

  UpdateLocalizedCategories(this.localizations);
}

