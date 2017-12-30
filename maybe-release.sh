#!/bin/bash
set -ev
if [ "$TRAVIS_BRANCH" == "master" ] && [ "$TRAVIS_PULL_REQUEST" == "false" ] && [ "$TRAVIS_REPO_SLUG" == "swisspush/vertx-rest-mirror" ]
then
    git reset --hard
    git clean -fd
    git checkout master
    echo 'Master checked out'
    groovy staging.groovy drop
    rc=$?
    if [ $rc -ne 0 ]
    then
      echo 'problem when try to drop, will continue..'
    fi
    mvn -B -Prelease jgitflow:release-start jgitflow:release-finish --settings settings.xml
    rc=$?
    if [ $rc -eq 0 ]
    then
        groovy staging.groovy close
        groovy staging.groovy promote
        rc=$?
        if [ $rc -ne 0 ]
        then
          echo 'Release failed: can not promote stage'
          exit rc
        fi
        echo 'Release done, will push'
        git tag
        git push --tags
        git checkout develop
        git push origin develop
      exit 0
    fi
    echo 'Release failed'
    exit rc
else
    echo 'Release skipped'
    exit 0
fi