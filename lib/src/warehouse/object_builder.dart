library neo4j_dart.warehouse.instantiate;

import 'dart:collection';
import 'package:neo4j_dart/src/wh_pack/adapters/base.dart';
import 'package:neo4j_dart/src/wh_pack/adapters/graph.dart';

class ObjectBuilder {
  final GraphDbSessionBase session;
  final LookingGlass lg;

  ObjectBuilder(this.session, this.lg);

  void buildNode(Map instances, Map properties, int id) {
    if (!instances.containsKey(id)) {
      var il = new InstanceLens.deserialize(properties, lg);

      session.attach(il.instance, id);
      instances[id] = il;
    }
  }

  buildGraph(Map<int, InstanceLens> instances, List<int> createdEdges, List<Map> nodes, List<Map> edges) {
    for (var node in nodes) {
      buildNode(instances, node['properties'], int.parse(node['id']));
    }

    for (var edge in edges) {
      var startId = int.parse(edge['startNode']);
      var edgeId = int.parse(edge['id']);
      var endId = int.parse(edge['endNode']);

      if (createdEdges.contains(edgeId)) {
        continue;
      } else {
        createdEdges.add(edgeId);
      }

      var edgeName = edge['type'];

      var start = instances[startId];
      var end = instances[endId];

      var edgeType = getEdgeType(edgeName, start.cl);

      if (edgeType == null) {
        start.setRelation(edgeName, end);
      } else {
        start.setRelation(edgeName, end, edgeType, edge['properties']);
      }

      session.attachEdge(start.instance, edgeName, edgeId, endId);
    }
  }

  build(Map<String, List<Map<String, List>>> dbResult) {
    Map<int, InstanceLens> instances = new HashMap();
    List<int> edges = [];
    var hasRow = false;

    for (var row in dbResult['data']) {
      if (row.containsKey('row')) {
        hasRow = true;
      }

      var row_tmp;
      if (row.containsKey('graph')) {
        row_tmp = row['graph'];
        buildGraph(instances, edges, row['nodes'], row['relationships']);
      } else if (row.containsKey('row')) {
        row_tmp = row['row'];
        buildNode(instances, row_tmp[1], row_tmp[0]);
      } else {
        throw 'Result must contain graph or row data';
      }
    }

    if (hasRow) {
      return dbResult['data']
        .where((row) => row.containsKey('row') && instances.containsKey(row['row'][0]))
        .map((row) => instances[row['row'][0]].instance)
        .toList();
    }

    return instances.values.map((il) => il.instance).toList();
  }
}
