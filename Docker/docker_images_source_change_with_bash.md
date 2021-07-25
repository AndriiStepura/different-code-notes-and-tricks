# Docker compose update with other images source

If you need sometimes update your docker-compose file with another image for particular job, as an example to run component tests with stable image (QA/staging) by "latest" tag.

---

## I part - docker-compose file (docker-compose.component.yml)

```bash
version: "3"
services:
  content-service-name:
    # Just for local component tests run
    # image: "artifactory.repo.com/docker-group-qa/content-service-name:latest"
    # CI Pipeline configuration
    image: "artifactory.repo.com/docker-group-${DEV_OR_QA}/content-service-name:${TAG:-${EDGE_OR_LATEST}"
```


---
## II part - Bash helper

helper.sh
```bash
#!/bin/sh

# Clean local images for container-name-1, solr, elasticsearch, runner to assure lack of cached old images for local run
function cleanContainersCash() {
  docker stop $(docker ps -a -q -f "name=container-name-1" -f "name=solr" -f "name=elasticsearch" -f "name=runner")
  docker container kill $(docker ps -a -q -f "name=container-name-1" -f "name=solr" -f "name=elasticsearch" -f "name=runner")
  docker container rm $(docker ps -a -q -f "name=container-name-1" -f "name=solr" -f "name=elasticsearch" -f "name=runner")
  docker rmi -f $(docker images -a -q "*/docker-group*/*")
}

# Set container-name-1 image version tags to simulate pipeline as for QA image from master
function setLatestImagesTags() {
  sed -i '' '/latest/s/^    #/   /g' docker-compose.component.yml
  sed -i '' '/EDGE_OR_LATEST/s/^    /    # /g' docker-compose.component.yml
}

# Revert container-name-1 image version tags to EDGE_OR_LATEST
function revertLatestImagesTags() {
  sed -i '' '/latest/s/^    /    # /g' docker-compose.component.yml
  sed -i '' '/EDGE_OR_LATEST/s/^    #/   /g' docker-compose.component.yml
}


if [ "$1" == "cleanContainersCash" ]
then
  echo "Run cleanContainersCash helper function"
  cleanContainersCash
fi

if [ "$1" == "setLatestImagesTags" ]
then
  echo "Run setLatestImagesTags helper function"
  setLatestImagesTags
fi

if [ "$1" == "revertLatestImagesTags" ]
then
  echo "Run revertLatestImagesTags helper function"
  revertLatestImagesTags
fi
```