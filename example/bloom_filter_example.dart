// Copyright (c) 2016, kseo. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:bloom_filter/bloom_filter.dart';

main() {
  double falsePositiveProbability = 0.1;
  int expectedSize = 100;

  BloomFilter<String> bloomFilter =
      new BloomFilter<String>(falsePositiveProbability, expectedSize);

  bloomFilter.add("foo");

  if (bloomFilter.mightContain("foo")) {
    // Always returns true
    print("BloomFilter contains foo!");
    print(
        "Probability of a false positive: ${bloomFilter.expectedFalsePositiveProbability}");
  }

  if (bloomFilter.mightContain("bar")) {
    // Should return false, but could return true
    print("There was a false positive.");
  }
}
