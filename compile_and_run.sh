#!/bin/bash

# node Kha/make --debug --compile --graphics metal && open ./build/osx-build/build/Debug/Crafty.app --args  ../../../../assets/games/snake/snake.cosy 2>&1 output.txt
node Kha/make --debug --compile --graphics metal && run.sh
# node Kha/make --debug --compile --graphics metal && ./build/osx-build/build/Debug/Crafty.app/Contents/MacOS/Crafty assets/games/snake/snake.cosy
