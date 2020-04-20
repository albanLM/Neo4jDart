/// Mock implementations of [DbSession] and [Repository] for tests.
///
/// An implementation using an in-memory [Map], useful in tests.
library neo4j_dart.warehouse.warehouse.mocks;

import 'dart:async';
import 'package:neo4j_dart/src/wh_pack/adapters/base.dart';
import 'package:neo4j_dart/src/wh_pack/warehouse.dart';
import 'package:neo4j_dart/src/wh_pack/src/mocks/mock_matchers.dart';

part 'src/mocks/mock_repository.dart';
part 'src/mocks/mock_session.dart';
