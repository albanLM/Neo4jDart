library cypher_spec;

import '../helpers.dart';

main() {
  var db = setUp();

  describe('cypher', () {
    beforeEach(setUpTestData);
    afterEach(cleanUpTestData);

    it('should be able to write to the database', () {
      var query = db.cypher('''
        Match (dart:Language {name:"Dart"}),
              (neo4j:Database {name:"Neo4j"})
        Create (dart)-[:ConnectsTo]->(neo4j)
      ''');

      return expect(query).toHaveWritten(
        '(a:Language {name:"Dart"})-[b:ConnectsTo]->(c:Database {name:"Neo4j"})'
      );
    });

    it('should support parameterized queries', () async {
      var query = db.cypher('''
        Create (js:Language {js})
        Return js
      ''', {'js': {'name': 'JavaScript'}});

      await expect(query).toReturnNodes([{
        'js': { 'data': [{'name': 'JavaScript'}]}
      }]);

      await expect(query).toHaveWritten('(a:Language {name: "JavaScript"})');
    });

    it('should be able to query the database for a table result', () {
      var query = db.cypher('Match (m:Movie) Return m.name, m.year');

      return expect(query).toReturnTable(
        ['m.name', 'm.year'],
        [
          ['Fury', 2014],
          ['The Green Mile', 1999],
          ['Avatar', 2009],
          ['Bad Boys', 1995],
          ['Bad Boys II', 2003],
          ['Bad Boys 3', null],
        ]
      );
    });

    it('should be able to query the database for a node result', () {
      var query = db.cypher('Match (m:Movie) Return m');

      return expect(query).toReturnNodes([{
        'm': {
          'data': [
            {'name':'Fury', 'year':2014},
            {'name':'The Green Mile', 'year':1999},
            {'name':'Avatar', 'year':2009},
            {'name':'Bad Boys', 'year':1995},
            {'name':'Bad Boys II', 'year':2003},
            {'name':'Bad Boys 3'},
          ]
        }
      }]);
    });

    it('should throw on errors', () =>
      db.cypher('Create (dart:Language {name:"Dart"})')
        .catchError(expectAsync((result) {
          expect(result['errors'][0]['code']).toEqual('Neo.ClientError.Schema.ConstraintViolation');
        })));
  });
}
