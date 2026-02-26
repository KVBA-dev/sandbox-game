#!/usr/bin/sh

odin run src \
	-debug \
	-o:none \
	-sanitize:address \
	-warnings-as-errors \
	-disallow-do \
	-vet-packages:main \
	-vet-unused-procedures \
	-vet-unused-variables
