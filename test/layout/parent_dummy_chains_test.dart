library graphlib.test.layout.parent_dummy_chains_test;

import 'package:unittest/unittest.dart';
import 'package:graphlib/graphlib.dart' show Graph;
import 'package:graphlib/src/layout/parent_dummy_chains.dart' show parentDummyChains;

parentDummyChainsTest() {
  group("parentDummyChains", () {
    Graph g;

    setUp(() {
      g = new Graph(compound: true)..setGraph({});
    });

    test("does not set a parent if both the tail and head have no parent", () {
      g.setNode("a");
      g.setNode("b");
      g.setNode("d1", { "edgeObj": { "v": "a", "w": "b" } });
      g.graph().dummyChains = ["d1"];
      g.setPath(["a", "d1", "b"]);

      parentDummyChains(g);
      expect(g.parent("d1"), isNull);
    });

    test("uses the tail's parent for the first node if it is not the root", () {
      g.setParent("a", "sg1");
      g.setNode("sg1", { "minRank": 0, "maxRank": 2 });
      g.setNode("d1", { "edgeObj": { "v": "a", "w": "b" }, "rank": 2 });
      g.graph().dummyChains = ["d1"];
      g.setPath(["a", "d1", "b"]);

      parentDummyChains(g);
      expect(g.parent("d1"), equals("sg1"));
    });

    test("uses the heads's parent for the first node if tail's is root", () {
      g.setParent("b", "sg1");
      g.setNode("sg1", { "minRank": 1, "maxRank": 3 });
      g.setNode("d1", { "edgeObj": { "v": "a", "w": "b" }, "rank": 1 });
      g.graph().dummyChains = ["d1"];
      g.setPath(["a", "d1", "b"]);

      parentDummyChains(g);
      expect(g.parent("d1"), equals("sg1"));
    });

    test("handles a long chain starting in a subgraph", () {
      g.setParent("a", "sg1");
      g.setNode("sg1", { "minRank": 0, "maxRank": 2 });
      g.setNode("d1", { "edgeObj": { "v": "a", "w": "b" }, "rank": 2 });
      g.setNode("d2", { "rank": 3 });
      g.setNode("d3", { "rank": 4 });
      g.graph().dummyChains = ["d1"];
      g.setPath(["a", "d1", "d2", "d3", "b"]);

      parentDummyChains(g);
      expect(g.parent("d1"), equals("sg1"));
      expect(g.parent("d2"), isNull);
      expect(g.parent("d3"), isNull);
    });

    test("handles a long chain ending in a subgraph", () {
      g.setParent("b", "sg1");
      g.setNode("sg1", { "minRank": 3, "maxRank": 5 });
      g.setNode("d1", { "edgeObj": { "v": "a", "w": "b" }, "rank": 1 });
      g.setNode("d2", { "rank": 2 });
      g.setNode("d3", { "rank": 3 });
      g.graph().dummyChains = ["d1"];
      g.setPath(["a", "d1", "d2", "d3", "b"]);

      parentDummyChains(g);
      expect(g.parent("d1"), isNull);
      expect(g.parent("d2"), isNull);
      expect(g.parent("d3"), equals("sg1"));
    });

    test("handles nested subgraphs", () {
      g.setParent("a", "sg2");
      g.setParent("sg2", "sg1");
      g.setNode("sg1", { "minRank": 0, "maxRank": 4 });
      g.setNode("sg2", { "minRank": 1, "maxRank": 3 });
      g.setParent("b", "sg4");
      g.setParent("sg4", "sg3");
      g.setNode("sg3", { "minRank": 6, "maxRank": 10 });
      g.setNode("sg4", { "minRank": 7, "maxRank":  9 });
      for (var i = 0; i < 5; ++i) {
        g.setNode("d${i + 1}", { "rank": i + 3  });
      }
      g.node("d1").edgeObj = { "v": "a", "w": "b" };
      g.graph().dummyChains = ["d1"];
      g.setPath(["a", "d1", "d2", "d3", "d4", "d5", "b"]);

      parentDummyChains(g);
      expect(g.parent("d1"), equals("sg2"));
      expect(g.parent("d2"), equals("sg1"));
      expect(g.parent("d3"), isNull);
      expect(g.parent("d4"), equals("sg3"));
      expect(g.parent("d5"), equals("sg4"));
    });

    test("handles overlapping rank ranges", () {
      g.setParent("a", "sg1");
      g.setNode("sg1", { "minRank": 0, "maxRank": 3 });
      g.setParent("b", "sg2");
      g.setNode("sg2", { "minRank": 2, "maxRank": 6 });
      g.setNode("d1", { "edgeObj": { "v": "a", "w": "b" }, "rank": 2 });
      g.setNode("d2", { "rank": 3 });
      g.setNode("d3", { "rank": 4 });
      g.graph().dummyChains = ["d1"];
      g.setPath(["a", "d1", "d2", "d3", "b"]);

      parentDummyChains(g);
      expect(g.parent("d1"), equals("sg1"));
      expect(g.parent("d2"), equals("sg1"));
      expect(g.parent("d3"), equals("sg2"));
    });

    test("handles an LCA that is not the root of the graph #1", () {
      g.setParent("a", "sg1");
      g.setParent("sg2", "sg1");
      g.setNode("sg1", { "minRank": 0, "maxRank": 6 });
      g.setParent("b", "sg2");
      g.setNode("sg2", { "minRank": 3, "maxRank": 5 });
      g.setNode("d1", { "edgeObj": { "v": "a", "w": "b" }, "rank": 2 });
      g.setNode("d2", { "rank": 3 });
      g.graph().dummyChains = ["d1"];
      g.setPath(["a", "d1", "d2", "b"]);

      parentDummyChains(g);
      expect(g.parent("d1"), equals("sg1"));
      expect(g.parent("d2"), equals("sg2"));
    });

    test("handles an LCA that is not the root of the graph #2", () {
      g.setParent("a", "sg2");
      g.setParent("sg2", "sg1");
      g.setNode("sg1", { "minRank": 0, "maxRank": 6 });
      g.setParent("b", "sg1");
      g.setNode("sg2", { "minRank": 1, "maxRank": 3 });
      g.setNode("d1", { "edgeObj": { "v": "a", "w": "b" }, "rank": 3 });
      g.setNode("d2", { "rank": 4 });
      g.graph().dummyChains = ["d1"];
      g.setPath(["a", "d1", "d2", "b"]);

      parentDummyChains(g);
      expect(g.parent("d1"), equals("sg2"));
      expect(g.parent("d2"), equals("sg1"));
    });
  });
}

main() {
  parentDummyChainsTest();
}
