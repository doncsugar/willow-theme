#!/usr/bin/env bash

rm -r "output"
mkdir "output"

cp -a "WillowDark" "output/willow-dark-plasma"
cp -a "WillowLight" "output/willow-light-plasma"

cp -a src/* "output/willow-dark-plasma"
cp -a src/* "output/willow-light-plasma"

cp -a "output/willow-dark-plasma" "output/willow-dark-plasma-small-icons"
cp -a "output/willow-light-plasma" "output/willow-light-plasma-small-icons"

cp -a WillowDark-Small/* "output/willow-dark-plasma-small-icons"
cp -a WillowLight-Small/* "output/willow-light-plasma-small-icons"
