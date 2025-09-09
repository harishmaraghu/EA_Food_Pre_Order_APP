import '../models/product.dart';

abstract class StockRepository {
  Future<List<Product>> getProducts();
  Future<void> updateStock(String productId, int delta);
}
