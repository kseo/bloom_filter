// Copyright (c) 2016, kseo. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:bloom_filter/bloom_filter.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

void main() {
  group('BloomFilter', () {
    final uuid = new Uuid();

    test('add', () {
      BloomFilter b = new BloomFilter(0.01, 100);

      for (var i = 0; i < 100; i++) {
        String val = uuid.v4().toString();
        b.add(val);
        expect(b.mightContain(val), isTrue);
      }
    });

    test('contains', () {
      BloomFilter b = new BloomFilter(0.01, 100);

      for (var i = 0; i < 10; i++) {
        b.add(i.toRadixString(2));
        expect(b.mightContain(i.toRadixString(2)), isTrue);
      }

      expect(b.mightContain(uuid.v4()), isFalse);
    });
  });
}

