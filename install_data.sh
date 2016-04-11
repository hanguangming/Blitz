#!/bin/bash

if test "$1aaa" == "aaa"; then
    echo "empty dist dir"
    exit 1
fi

if test "$1" == "/usr/local"; then
    echo "bad dist dir"
    exit 1
fi

if test "$1" == "/usr"; then
    echo "bad dist dir"
    exit 1
fi

if [ ! -d "$1/log" ]; then
    mkdir "$1/log"
fi

if [ ! -d "$1/var" ]; then
    mkdir "$1/var"
fi

rm -rf "$1/script"
cp -arf script "$1"

rm -rf "$1/etc"
cp -arf etc "$1"

rm -rf "$1/web"
cp -arf web "$1"

rm -rf "$1/web"
cp -arf sql "$1"

