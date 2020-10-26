#!/bin/bash
debug=0

# load Revbayes through spack
cd ~/Applications/spack/
source share/spack/setup-env.sh
spack load revbayes

# go to wd
cd /media/bwillink/HD710 PRO/Investigacion/lbh_cultural_evolution

filelist=$@

# make rb command
rb_command="source(\"scripts/coen.g1.beta.Seth.Rev\");"

g1Beta_out="output/coen.g1.beta.Seth.R3.stdout.txt"
echo $rb_command | rb | tee $g1Beta_out

