import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_budget/data/repositories/category_repository.dart';
import 'category_event.dart';
import 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository categoryRepository;

  CategoryBloc(this.categoryRepository) : super(CategoriesLoading()) {
    on<LoadCategories>(_onLoadCategories);
    on<AddCategory>(_onAddCategory);
    on<UpdateCategory>(_onUpdateCategory);
    on<DeleteCategory>(_onDeleteCategory);
  }

  Future<void> _onLoadCategories(
      LoadCategories event, Emitter<CategoryState> emit) async {
    try {
      emit(CategoriesLoading());
      final categories = await categoryRepository.getAllCategories();
      emit(CategoriesLoaded(categories));
    } catch (e) {
      emit(CategoryError('Failed to load transaction types'));
    }
  }

  Future<void> _onAddCategory(
      AddCategory event, Emitter<CategoryState> emit) async {
    try {
      await categoryRepository.createCategory(event.category);
      final categories = await categoryRepository.getAllCategories();
      emit(CategoriesLoaded(categories));
    } catch (e) {
      emit(CategoryError('Failed to add transaction type'));
    }
  }

  Future<void> _onUpdateCategory(
      UpdateCategory event, Emitter<CategoryState> emit) async {
    try {
      await categoryRepository.updateCategory(event.category);
      final categories = await categoryRepository.getAllCategories();
      emit(CategoriesLoaded(categories));
    } catch (e) {
      emit(CategoryError('Failed to update transaction type'));
    }
  }

  Future<void> _onDeleteCategory(
      DeleteCategory event, Emitter<CategoryState> emit) async {
    try {
      await categoryRepository.deleteCategory(event.id);
      final categories = await categoryRepository.getAllCategories();
      emit(CategoriesLoaded(categories));
    } catch (e) {
      emit(CategoryError('Failed to delete transaction type'));
    }
  }
}
