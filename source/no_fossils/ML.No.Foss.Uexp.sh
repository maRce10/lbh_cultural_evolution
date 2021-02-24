#!/bin/bash

cd ~/Applications/spack/
source share/spack/setup-env.sh
spack load revbayes
cd /media/bwillink/HD710\ PRO/Investigacion/lbh_cultural_evolution/

start=$SECONDS

#list of leks
#leks=("BR1")
leks=("BR1" "SUR" "TR1")

#list of alignments
#align=("all.equal")
align=("all.equal" "optimal" "prank")


#list of molecular clocks
clocks=("Uexp")

for j in ${leks[@]};
do
  for k in ${align[@]};
  do
    for o in ${clocks[@]};
    do
    echo starting dataset
    lekinfo="${j}"."${k}".no.fossils."${o}"
    echo $lekinfo
    echo $lekinfo >> ./output/revbayes/stdout/dataset.txt
    rb_command="source(\"./source/no_fossils/"$j"_"$k"_no.fossils_full.process_"$o".Rev\");"
    ML_out="./output/revbayes/ML/"$j"_"$k"_no.fossils_full.process_"$o".txt"
    echo $rb_command | mpirun -np 4 rb | tee $ML_out
    cat $ML_out | tail -1 >> ./output/revbayes/stdout/PathSampler.txt
    cat $ML_out | tail -2 | head -1 >> ./output/revbayes/stdout/SteppingStone.txt
    echo ML approximated \for $lekinfo
    done
  done
done


