#!/usr/bin/sh

NAME="sandbox-debug"
./build_debug.sh && gdb ./bin/$NAME
