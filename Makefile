PG_CONFIG    = pg_config
PKG_CONFIG   = pkg-config

EXTENSION    = wiki
EXT_VERSION  = 0.1
VTESTS       = $(shell bin/tests ${VERSION})

DATA_built   = wiki--$(EXT_VERSION).sql

#REGRESS      = init manifest misc ${VTESTS}
REGRESS      = init manifest misc
#REGRESS      = ($shell bin/tests)
REGRESS_OPTS = --inputdir=test

PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)

$(DATA_built): wiki.sql
	@echo "Building extension version" $(EXT_VERSION) "for Postgres version" $(VERSION)
	VERSION=${VERSION} ./bin/pgsqlpp $^ >$@
