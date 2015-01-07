library graphlib.test.layout.order.sort;

import 'package:unittest/unittest.dart';
import 'package:graphlib/src/layout/order/sort.dart' show sort;

sortTest() {
  group("sort", () {
    test("sorts nodes by barycenter", () {
      var input = [
        { "vs": ["a"], "i": 0, "barycenter": 2, "weight": 3 },
        { "vs": ["b"], "i": 1, "barycenter": 1, "weight": 2 }
      ];
      expect(sort(input), equals({
        "vs": ["b", "a"],
        "barycenter": (2 * 3 + 1 * 2) / (3 + 2),
        "weight": 3 + 2 }));
    });

    test("can sort super-nodes", () {
      var input = [
        { "vs": ["a", "c", "d"], "i": 0, "barycenter": 2, "weight": 3 },
        { "vs": ["b"], "i": 1, "barycenter": 1, "weight": 2 }
      ];
      expect(sort(input), equals({
        "vs": ["b", "a", "c", "d"],
        "barycenter": (2 * 3 + 1 * 2) / (3 + 2),
        "weight": 3 + 2 }));
    });

    test("biases to the left by default", () {
      var input = [
        { "vs": ["a"], "i": 0, "barycenter": 1, "weight": 1 },
        { "vs": ["b"], "i": 1, "barycenter": 1, "weight": 1 }
      ];
      expect(sort(input), equals({
        "vs": ["a", "b"],
        "barycenter": 1,
        "weight": 2 }));
    });

    test("biases to the right if biasRight = true", () {
      var input = [
        { "vs": ["a"], "i": 0, "barycenter": 1, "weight": 1 },
        { "vs": ["b"], "i": 1, "barycenter": 1, "weight": 1 }
      ];
      expect(sort(input, true), equals({
        "vs": ["b", "a"],
        "barycenter": 1,
        "weight": 2 }));
    });

    test("can sort nodes without a barycenter", () {
      var input = [
        { "vs": ["a"], "i": 0, "barycenter": 2, "weight": 1 },
        { "vs": ["b"], "i": 1, "barycenter": 6, "weight": 1 },
        { "vs": ["c"], "i": 2 },
        { "vs": ["d"], "i": 3, "barycenter": 3, "weight": 1 }
      ];
      expect(sort(input), equals({
        "vs": ["a", "d", "c", "b"],
        "barycenter": (2 + 6 + 3) / 3,
        "weight": 3
      }));
    });

    test("can handle no barycenters for any nodes", () {
      var input = [
        { "vs": ["a"], "i": 0 },
        { "vs": ["b"], "i": 3 },
        { "vs": ["c"], "i": 2 },
        { "vs": ["d"], "i": 1 }
      ];
      expect(sort(input), equals({ "vs": ["a", "d", "c", "b"] }));
    });

    test("can handle a barycenter of 0", () {
      var input = [
        { "vs": ["a"], "i": 0, "barycenter": 0, "weight": 1 },
        { "vs": ["b"], "i": 3 },
        { "vs": ["c"], "i": 2 },
        { "vs": ["d"], "i": 1 }
      ];
      expect(sort(input), equals({
        "vs": ["a", "d", "c", "b"],
        "barycenter": 0,
        "weight": 1
      }));
    });
  });
}

main() {
  sortTest();
}
