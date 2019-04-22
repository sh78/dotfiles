#!/bin/sh

svn up
installed-check || npm install
