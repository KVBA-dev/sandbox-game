#!/usr/bin/sh

NAME="sandbox"

odin build src \
	-out:bin/$NAME \
	-o:speed \
	-warnings-as-errors \
	-disallow-do \
	-vet-packages:main \
	-vet-unused-procedures \
	-vet-unused-variables \
	-thread-count:4
if [[ $? -ne 0 ]]; then
	exit 1
fi

rsync --recursive --delete ./res ./bin/
chmod +x ./bin/$NAME
