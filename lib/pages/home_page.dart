import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_project/provider/cart_provider.dart';
import '../controller/controller.dart';
import 'cart_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(getCartProvider.notifier).getCartDetailsCustomer();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Products"),
        actions: [
          Consumer(
            builder: (context, ref, child) {
              final cartItems = ref.watch(getCartProvider).cartItems;
              final hasCartItems = cartItems.isNotEmpty;

              return IconButton(
                icon: Icon(
                  Icons.shopping_cart,
                  color: hasCartItems ? Colors.green : Colors.grey,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final cartState = ref.watch(getCartProvider);
          final products = cartState.productList;
          final cartItems = cartState.cartItems;
          final isLoading = cartState.isLoading;

          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (products.isEmpty) {
            return const Center(child: Text("No products available"));
          }

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final item = products[index];

              final isInCart =
                  cartItems.any((cartItem) => cartItem["id"] == item["id"]);
              final quantity = isInCart
                  ? cartItems.firstWhere(
                      (cartItem) => cartItem["id"] == item["id"])["quantity"]
                  : 0;

              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    item["thumbnail"],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.error),
                  ),
                ),
                title: Text(item["title"]),
                subtitle: Text("₹${(item["price"] as num).toStringAsFixed(2)}"),
                trailing: isInCart
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, color: Colors.red),
                            onPressed: () {
                              ref
                                  .read(getCartProvider.notifier)
                                  .decrementQuantity(item["id"]);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text("${item["title"]} quantity updated"),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                          ),
                          Text(
                            "$quantity",
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, color: Colors.green),
                            onPressed: () {
                              ref
                                  .read(getCartProvider.notifier)
                                  .incrementQuantity(item["id"]);
                            },
                          ),
                        ],
                      )
                    : ElevatedButton(
                        onPressed: () {
                          ref.read(getCartProvider.notifier).addToCart(item);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Add to Cart"),
                      ),
              );
            },
          );
        },
      ),
    );
  }
}
