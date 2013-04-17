#!/usr/bin/env bash

rm -rf stowers_collaboration
rm -rf stowers_collaboration.zip
mkdir -p stowers_collaboration
cp -r js img data css index.html stowers_collaboration/
zip -r stowers_collaboration stowers_collaboration/*
rm -rf stowers_collaboration
