library neo4j_dart.warehouse.warehouse.mocks.matchers;

import 'package:neo4j_dart/src/wh_pack/adapters/base.dart';
import 'package:neo4j_dart/src/wh_pack/warehouse.dart';

var _lg = new LookingGlass();

convert(value) {
  var converter = _lg.convertedTypes[value.runtimeType];
  if (converter != null) {
    value = converter.toDatabase(value);
  }
  return value;
}

matches(Map where) => (entity) {
  if (where == null) return true;
  var il = _lg.lookOnObject(entity);
  try {
    where.forEach((property, expected) {
      var actual =  il.properties[property];
      if (expected is Matcher) {
        if (!visitMatcher(actual, expected)) {
          throw 'match error';
        }
      } else {
        if (actual != expected) throw 'match error';
      }
    });
  } catch (e) {
    if (e == 'match error') return false;
    rethrow;
  }
  return true;
};

bool visitMatcher(actual, Matcher matcher) {
  if (matcher is ExistMatcher) {
    return actual != null;
  } else if (matcher is NotMatcher) {
    return !visitMatcher(actual, matcher.invertedMatcher);
  } else if (matcher is ListContainsMatcher) {
    return actual.contains(matcher.expected);
  } else if (matcher is StringContainMatcher) {
    return actual.contains(matcher.expected);
  } else if (matcher is InListMatcher) {
    return matcher.list.contains(actual);
  } else if (matcher is EqualsMatcher) {
    return actual == convert(matcher.expected);
  } else if (matcher is LessThanMatcher) {
    return actual < convert(matcher.expected);
  } else if (matcher is LessThanOrEqualToMatcher) {
    return actual <= convert(matcher.expected);
  } else if (matcher is GreaterThanMatcher) {
    return actual > convert(matcher.expected);
  } else if (matcher is GreaterThanOrEqualToMatcher) {
    return actual >= convert(matcher.expected);
  } else if (matcher is InRangeMatcher) {
    return actual >= matcher.min && actual <= matcher.max;
  } else if (matcher is RegexpMatcher) {
    return new RegExp(matcher.regexp).hasMatch(actual);
  } else {
    throw 'Unsuported matcher ${matcher.runtimeType}';
  }
}
