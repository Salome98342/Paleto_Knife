import 'chef.dart';

class GachaResult {
  final Chef chef;
  final bool isDuplicate;
  final int tokensGranted;
  final int goldGranted;

  GachaResult({
    required this.chef,
    required this.isDuplicate,
    this.tokensGranted = 0,
    this.goldGranted = 0,
  });
}
