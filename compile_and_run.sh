#!/bin/bash

node Kha/make --debug --compile --graphics metal && open ./build/osx-build/build/Debug/Crafty.app --args  ../../../../assets/games/breakout/breakout-ecs.cosy
