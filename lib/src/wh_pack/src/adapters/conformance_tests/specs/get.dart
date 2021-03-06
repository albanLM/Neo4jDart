library neo4j_dart.warehouse.warehouse.test.conformance.get;

import 'package:guinness/guinness.dart';
import 'package:warehouse/warehouse.dart';
import 'package:warehouse/src/adapters/conformance_tests/factories.dart';
import '../domain.dart';

runGetTests(SessionFactory sessionFactory, RepositoryFactory repositoryFactory) {
  describe('', () {
    DbSession session;
    Repository repository;
    Movie avatar, pulpFiction;

    beforeEach(() async {
      session = sessionFactory();
      repository = repositoryFactory(session, Movie);

      var tarantino = new Person()
        ..name = 'Quentin Tarantino';

      avatar = new Movie()
        ..title = 'Avatar'
        ..releaseDate = new DateTime.utc(2009, 12, 18);

      pulpFiction = new Movie()
        ..title = 'Pulp Fiction'
        ..releaseDate = new DateTime.utc(1994, 12, 25)
        ..director = tarantino;

      session.store(tarantino);
      session.store(avatar);
      session.store(pulpFiction);

      await session.saveChanges();
    });

    describe('get', () {
      it('should be able to get an entity by id', () async {
        var entity = await repository.get(session.entityId(avatar));

        expect(entity).toHaveSameProps(avatar);
      });

      it('should get directly connected entities', () async {
        // Depending on the database model this may be a relation, join or embedded.
        // All models should default to include at least the directly connected entities when
        // getting a single entity. How deeper connections are handled depends on the model.

        var entity = await repository.get(session.entityId(pulpFiction));

        expect(entity.title).toEqual('Pulp Fiction');
        expect(entity.releaseDate).toEqual(new DateTime.utc(1994, 12, 25));
        expect(entity.director).toBeA(Person);
        expect(entity.director.name).toEqual('Quentin Tarantino');
      });

      it('should be able to handle a string representation of the id', () async {
        var entity = await repository.get(session.entityId(avatar).toString());

        expect(entity).toHaveSameProps(avatar);
      });
    });

    describe('getAll', () {
      it('should be able to get multiple entities by id', () async {
        var entities = await repository.getAll([session.entityId(avatar), session.entityId(pulpFiction)]);

        expect(entities.length).toEqual(2);
        expect(entities[0]).toHaveSameProps(avatar);
        expect(entities[1].title).toEqual('Pulp Fiction');
        expect(entities[1].releaseDate).toEqual(new DateTime.utc(1994, 12, 25));
      });

      it('should be able to handle a string representation of the ids', () async {
        var entities = await repository.getAll([
          session.entityId(avatar).toString(),
          session.entityId(pulpFiction).toString(),
        ]);

        expect(entities.length).toEqual(2);
        expect(entities[0]).toHaveSameProps(avatar);
        expect(entities[1].title).toEqual('Pulp Fiction');
        expect(entities[1].releaseDate).toEqual(new DateTime.utc(1994, 12, 25));
      });

      it('should be able to handle all iterables', () async {
        var entities = await repository.getAll([
          session.entityId(avatar),
          session.entityId(pulpFiction),
        ].toSet());

        expect(entities.length).toEqual(2);
        expect(entities[0]).toHaveSameProps(avatar);
        expect(entities[1].title).toEqual('Pulp Fiction');
        expect(entities[1].releaseDate).toEqual(new DateTime.utc(1994, 12, 25));
      });

      it('should return the entities in the same order as requested', () async {
        var entities = await repository.getAll([
          session.entityId(pulpFiction),
          session.entityId(avatar),
        ]);

        expect(entities.length).toEqual(2);
        expect(entities[0].title).toEqual('Pulp Fiction');
        expect(entities[0].releaseDate).toEqual(new DateTime.utc(1994, 12, 25));
        expect(entities[1]).toHaveSameProps(avatar);
      });
    });
  });
}
