part of neo4j_dart.warehouse.warehouse.sql;

class Table {
  final String name;
  final bool storeType;
  final Map<String, String> columns;

  Table(this.name, this.storeType, this.columns);
}
