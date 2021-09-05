# To make changes in JSON files, as an example - Elastic Search config, we can use jq package

# Change replicas to 0, set 1 shards and patterns name to keep ES green
docker exec -i runner bash -c "cd /go/src && jq '.settings.number_of_replicas = 0 | .settings.number_of_shards = 1 | .index_patterns = [\"*users*\"] ' testing/testdata/corpus/index_template.json > testing/testdata/corpus/index_template_tmp.json && mv testing/testdata/corpus/index_template_tmp.json testing/testdata/corpus/index_template.json"