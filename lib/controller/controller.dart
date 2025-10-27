import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_project/provider/cart_provider.dart';

final getCartProvider = NotifierProvider<GetCartNotifier, CartState>(() => GetCartNotifier());