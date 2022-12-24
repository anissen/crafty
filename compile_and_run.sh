#!/bin/bash

node Kha/make --debug --compile --graphics metal --quiet && open ./build/osx-build/build/Debug/Crafty.app --args  ../../../../assets/games/breakout/breakout.cosy
