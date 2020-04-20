part of neo4j_dart.warehouse.warehouse;

enum OperationType {
  create, delete, update
}

class DbOperation<T> {
  var id;
  OperationType type;
  T entity;
}
