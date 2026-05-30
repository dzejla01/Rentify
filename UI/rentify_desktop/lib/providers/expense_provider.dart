import 'package:rentify_desktop/models/expense.dart';
import 'base_provider.dart';

class ExpenseProvider extends BaseProvider<Expense> {
  ExpenseProvider() : super("Expense");

  @override
  Expense fromJson(dynamic data) {
    return Expense.fromJson(data);
  }
}
