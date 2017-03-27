#!/bin/bash
cd /Users/fabienflorek/Projects/dwd/char-rnn
source ~/torch/install/bin/torch-activate
a=$(echo "$1" | rev | cut -c 1- | rev)
th sample.lua "cv/$2" -primetext "$a " -length 500 -temperature 0.5