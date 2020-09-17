SHELL:=/bin/bash

DB_FILE=sqlite-olt.db

install-environment:
	conda env create --force -f environment.yml

db:
	sqlite3 ${DB_FILE} < schema.sql


KEYWORDS_LIST=sqlite mongodb postgres oracle elasticsearch cassandra redis spark couchdb couchbase mysql sqlserver mariadb sap sql python java matlab julia cpp R
.PHONY: sqlite-olt.db

export TABLE = search_results  # Available for all targets

pre-sqlite-olt.db:
	sqlite3 $@ < ./schema.sql
	for term in ${KEYWORDS_LIST}; do \
		echo $$term; \
		search_url=http://hn.algolia.com/api/v1/search\?tags=comment\&query\=$$term\&hitsPerPage\=1000; \
		curl -Ls $$search_url | \
		jq -rc |\
		./pipe_to_sqlite.py; \
	done
		#sqlite3 $@ ".import /dev/stdin search_results";\
	#done

	while read term; do \
			echo $$term; \
  		echo http://hn.algolia.com/api/v1/search\?tags=comment\&query\=$$term\&hitsPerPage\=1000; \
		curl -Ls http://hn.algolia.com/api/v1/search\?tags=story\&query\=$$term\&hitsPerPage\=1000 | \
		jq -rc |\
		./pipe_to_sqlite.py; \
	done <./data/keywords.csv

.PHONY:data/hn_dump.json.gz
data/hn_dump.json.gz: data/hn_dump.json
	gzip -ck9 data/hn_dump.json > $@

.PHONY:data/hn_dump.json
data/hn_dump.json:
	python hn_dump.py > $@

.PHONY:data/hn_dump.mini.json
data/hn_dump.mini.json: data/hn_dump.json.gz
	gzip -cd data/hn_dump.json.gz | jq '.[10:15]' > $@

.PHONY: sqlite-olt.db.sql.gz
pre-sqlite-olt.db.sql.gz:
	sqlite3 pre-sqlite-olt.db .dump | gzip -c9 - > $@
	echo $@ "created"
	du -h $@

.PHONY: data/hn_items_export.csv.gz
data/hn_items_export.csv.gz:
	sqlite3 pre-sqlite-olt.db < ./schema.sql
	sqlite3 pre-sqlite-olt.db "select created_at, objectID, author, points, comment_text_length, story_text_length, story_id, story_title, story_url from hn_items_export" |\
	sort -u | gzip -ck9 - > $@

	gzip -dk $@ | head > data/hn_items_export.csv