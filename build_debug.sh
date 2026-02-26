#!/usr/bin/sh

odin build src \
	-debug \
	-sanitize:address \
	-o:none \
	-out:bin/sandbox-debug \
	-warnings-as-errors \
	-disallow-do \
	-vet-packages:main \
	-vet-unused-procedures \
	-vet-unused-variables
