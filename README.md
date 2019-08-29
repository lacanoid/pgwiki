SQL wiki functions
==================

A wiki inside PostgreSQL.

Installation
------------

To build and install this module:

    make
    make install
    make install installcheck

or selecting a specific PostgreSQL installation:

    make PG_CONFIG=/some/where/bin/pg_config
    make PG_CONFIG=/some/where/bin/pg_config install
    make PG_CONFIG=/some/where/bin/pg_config installcheck
    make PGPORT=5432 PG_CONFIG=/usr/lib/postgresql/10/bin/pg_config clean install installcheck

Make sure you set the connection parameters like PGPORT right for testing.

And finally inside the database:

    CREATE EXTENSION wiki;

This requires superuser privileges.

Using
-----

The API provides public user functions:

- `wiki.page_set(page_title text, content text)`
- `wiki.page_set(page_title text, content xml)`
- `wiki.page_set(page_title text, content json)`

- `wiki.page_get(page_title text)`
- `wiki.page_get_data(page_title text)`

See also [full list of functions](test/expected/manifest.out).

