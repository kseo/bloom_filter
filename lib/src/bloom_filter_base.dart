// Copyright (c) 2016, Kwang Yul Seo. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:math' show exp, log, pow;

import 'package:bit_vector/bit_vector.dart';
import 'package:crypto/crypto.dart';

/// A implementation of Bloom filter, as described by
/// https://en.wikipedia.org/wiki/Bloom_filter
class BloomFilter<E> {
  final BitVector _bitVector;
  final int _bitVectorSize;
  final int _expectedNumOfElements;
  int _numOfAddedElements;
  final int _k;

  /// The number of elements added to the Bloom filter after is was constructed
  /// or after clear() was called.
  int get length => _numOfAddedElements;

  /// The probability of a false positive given the expected number of inserted
  /// elements.
  double get expectedFalsePositiveProbability {
    // (1 - e^(-k * n / m)) ^ k
    return pow(1 - exp((-_k * _expectedNumOfElements / _bitVectorSize)), _k);
  }

  /// Constructs an empty Bloom filter with a given false positive probability.
  /// The number of bits per element and the number of hash functions is
  /// estimated to match the false positive probability.
  factory BloomFilter(
      double falsePositiveProbability, int expectedNumberOfElements) {
    final c = (-(log(falsePositiveProbability) / log(2))).ceil() /
        log(2); // c = k / ln(2)
    final k = ((-(log(falsePositiveProbability) / log(2))).ceil())
        .toInt(); // k = ceil(-log_2(false prob.))
    return new BloomFilter._internal(c, expectedNumberOfElements, k);
  }

  BloomFilter._internal(double c, int n, int k)
      : _expectedNumOfElements = n,
        _k = k,
        _bitVectorSize = (c * n).ceil(),
        _numOfAddedElements = 0,
        _bitVector = new BitVector((c * n).ceil());

  /// Adds an element to the Bloom filter. The output from the element's
  /// toString() method is used as input to the hash functions.
  void add(E element) {
    List<int> hashes = _createHashes(UTF8.encode(element.toString()), _k);
    for (int hash in hashes) {
      _bitVector.set((hash % _bitVectorSize).abs());
    }
    _numOfAddedElements++;
  }

  /// Adds all elements to the Bloom filter.
  void addAll(Iterable<E> elements) {
    for (E element in elements) {
      add(element);
    }
  }

  /// Returns true if the element could have been inserted into the Bloom
  /// filter.
  bool contains(E element) {
    List<int> hashes = _createHashes(UTF8.encode(element.toString()), _k);
    for (int hash in hashes) {
      if (!_bitVector.get((hash % _bitVectorSize).abs())) {
        return false;
      }
    }
    return true;
  }

  /// Returns true if all the elements could have been inserted into the Bloom
  /// filter.
  bool containsAll(Iterable<E> elements) {
    for (E element in elements) {
      if (!contains(element)) return false;
    }
    return true;
  }

  /// Set all bits to false in the Bloom filter.
  void clear() {
    _bitVector.clearAll();
    _numOfAddedElements = 0;
  }
}

List<int> _digest(List<int> data) => md5.convert(data).bytes;

List<int> _createHashes(List<int> data, int hashes) {
  List<int> result = new List<int>(hashes);

  int k = 0;
  while (k < hashes) {
    List<int> digest = _digest(data);

    for (var i = 0; i < digest.length / 4 && k < hashes; i++) {
      int h = 0;
      for (int j = (i * 4); j < (i * 4) + 4; j++) {
        h <<= 8;
        h |= digest[j] & 0xFF;
      }
      result[k] = h;
      k++;
    }
  }
  return result;
}
