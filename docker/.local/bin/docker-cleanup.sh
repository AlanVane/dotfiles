#!/usr/bin/env bash
# Docker cleanup unused things
# USE WITH CAUTION

# remove all exited containers
docker rm $(docker ps -a -f status=exited -f status=created -q) 

# remove dangling volumes
docker volume rm $(docker volume ls -f dangling=true -q)

# remove all unused images
docker image prune

# remove dangling images only
docker rmi $(docker images -f dangling=true -q)
