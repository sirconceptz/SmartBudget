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
