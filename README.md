# bloom_filter

A stand-alone Bloom filter implementation written in Dart inspired by
[Java-BloomFilter][Java-BloomFilter].

[Java-BloomFilter]: https://github.com/magnuss/java-bloomfilter

## Bloom filters

Bloom filters are used for set membership tests. They are fast and
space-efficient at the cost of accuracy. Although there is a certain probability
of error, Bloom filters never produce false negatives.

## Examples

To create an empty Bloom filter, just call the constructor with the required
false positive probability and the number of elements you expect to add to the
Bloom filter.

```dart
double falsePositiveProbability = 0.1;
int expectedNumberOfElements = 100;

BloomFilter<String> bloomFilter = new
BloomFilter<String>(falsePositiveProbability, expectedNumberOfElements);
```

The constructor chooses a length and number of hash functions which will provide
the given false positive probability (approximately). Note that if you insert
more elements than the number of expected elements you specify, the actual false
positive probability will rapidly increase.

After the Bloom filter has been created, new elements may be added using the
`add` method.

```dart
bloomFilter.add("foo");
```

To check whether an element has been stored in the Bloom filter, use the
`contains` method.

```dart
bloomFilter.contains("foo"); // returns true
```

Keep in mind that the accuracy of this method depends on the false positive
probability. It will always return true for elements which have been added to
the Bloom filter, but it may also return true for elements which have not been
added. The accuracy can be estimated using the
`expectedFalsePositiveProbability` getter.

Put together, here is the full example.

```dart
import 'package:bloom_filter/bloom_filter.dart';

main() {
  double falsePositiveProbability = 0.1;
  int expectedSize = 100;

  BloomFilter<String> bloomFilter =
      new BloomFilter<String>(falsePositiveProbability, expectedSize);

  bloomFilter.add("foo");

  if (bloomFilter.contains("foo")) {
    // Always returns true
    print("BloomFilter contains foo!");
    print(
        "Probability of a false positive: ${bloomFilter.expectedFalsePositiveProbability}");
  }

  if (bloomFilter.contains("bar")) {
    // Should return false, but could return true
    print("There was a false positive.");
  }
}
```

