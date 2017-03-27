#!/bin/bash
cd Projects/dwd/char-rnn
source ~/torch/install/bin/torch-activate
echo $1
th sample.lua "cv/$2" -gpuid -1 -length 500 -temperature 0.5 -primetext "$1 "