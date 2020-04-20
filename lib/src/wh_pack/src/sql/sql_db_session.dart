part of neo4j_dart.warehouse.warehouse.sql;

abstract class SqlDbSession<T extends SqlDb> implements DbSession<T> {
  factory SqlDbSession(SqlDb db) => new SqlDbSessionImplementation(db);
}
