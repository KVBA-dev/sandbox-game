#!/usr/bin/sh

odin run src \
	-thread-count:4 \
	-warnings-as-errors \
	-disallow-do \
	-vet-packages:main \
	-vet-unused-procedures \
	-vet-unused-variables

