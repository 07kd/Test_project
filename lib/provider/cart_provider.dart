import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_project/apis/get_cart_api.dart';

class CartState {
  final String statusMessage;
  final List<Map<String, dynamic>> productList;
  final List<Map<String, dynamic>> cartItems;
  final bool isLoading;

  CartState({
    this.statusMessage = "",
    this.productList = const [],
    this.cartItems = const [],
    this.isLoading = false,
  });

  CartState copyWith({
    String? statusMessage,
    List<Map<String, dynamic>>? productList,
    List<Map<String, dynamic>>? cartItems,
    bool? isLoading,
  }) {
    return CartState(
      statusMessage: statusMessage ?? this.statusMessage,
      productList: productList ?? this.productList,
      cartItems: cartItems ?? this.cartItems,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class GetCartNotifier extends Notifier<CartState> {
  @override
  CartState build() => CartState();

  Future<void> getCartDetailsCustomer() async {
    state = state.copyWith(isLoading: true, statusMessage: "");
    try {
      final response = await GetCartApi.GetCartData();

      if (response["carts"] != null) {
        final carts = List<Map<String, dynamic>>.from(response["carts"]);
        final allProducts = <Map<String, dynamic>>[];

        for (var cart in carts) {
          if (cart["products"] != null) {
            allProducts
                .addAll(List<Map<String, dynamic>>.from(cart["products"]));
          }
        }

        state = state.copyWith(
          productList: allProducts,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          statusMessage: "No cart data found.",
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        statusMessage: "Something went wrong.",
        isLoading: false,
      );
    }
  }

  Map<String, dynamic> _updateTotals(Map<String, dynamic> item) {
    final double price = (item["price"] is int)
        ? (item["price"] as int).toDouble()
        : item["price"] as double;
    final int quantity = item["quantity"] as int;
    final double discountPercent = (item["discountPercentage"] ?? 0).toDouble();

    return {
      ...item,
      "total": price * quantity,
      "discountedTotal":
          (price * quantity * (1 - discountPercent / 100)).toDouble(),
    };
  }

  void addToCart(Map<String, dynamic> item) {
    final existingItemIndex =
        state.cartItems.indexWhere((cartItem) => cartItem["id"] == item["id"]);
    List<Map<String, dynamic>> updatedCartItems = List.from(state.cartItems);

    if (existingItemIndex != -1) {
      final updatedItem =
          Map<String, dynamic>.from(updatedCartItems[existingItemIndex]);
      updatedItem["quantity"] = (updatedItem["quantity"] ?? 1) + 1;
      updatedCartItems[existingItemIndex] = _updateTotals(updatedItem);
    } else {
      final newItem = Map<String, dynamic>.from(item);
      newItem.remove("total");
      newItem.remove("discountedTotal");
      newItem["quantity"] = 1;
      updatedCartItems.add(_updateTotals(newItem));
    }

    state = state.copyWith(cartItems: updatedCartItems);
  }

  void incrementQuantity(int itemId) {
    final itemIndex =
        state.cartItems.indexWhere((item) => item["id"] == itemId);
    if (itemIndex != -1) {
      final updatedCartItems = List<Map<String, dynamic>>.from(state.cartItems);
      final updatedItem =
          Map<String, dynamic>.from(updatedCartItems[itemIndex]);
      updatedItem["quantity"] = (updatedItem["quantity"] ?? 1) + 1;
      updatedCartItems[itemIndex] = _updateTotals(updatedItem);
      state = state.copyWith(cartItems: updatedCartItems);
    }
  }

  void decrementQuantity(int itemId) {
    final itemIndex =
        state.cartItems.indexWhere((item) => item["id"] == itemId);
    if (itemIndex != -1) {
      final updatedCartItems = List<Map<String, dynamic>>.from(state.cartItems);
      final updatedItem =
          Map<String, dynamic>.from(updatedCartItems[itemIndex]);
      if (updatedItem["quantity"] > 1) {
        updatedItem["quantity"] = updatedItem["quantity"] - 1;
        updatedCartItems[itemIndex] = _updateTotals(updatedItem);
      } else {
        updatedCartItems.removeAt(itemIndex);
      }
      state = state.copyWith(cartItems: updatedCartItems);
    }
  }

  double get totalCartPrice {
    return state.cartItems
        .fold(0.0, (sum, item) => sum + (item["discountedTotal"] as double));
  }
}
