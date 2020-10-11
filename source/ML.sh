#!/bin/bash
cd ~/Applications/spack/
source share/spack/setup-env.sh
spack load revbayes
cd ~/Dropbox/Cultural_Evolution/ML/

start=$SECONDS

#list of leks
leks=("BR1" "CCE" "HC1" "SUR" "CCE")

#list of alignments
align=("all.equal" "optimal" "prank")

#list of fossils
fossils=("new" "old")

#list of fossil times
times=("all" "early")

#list of molecular clocks
clocks=("" "_global")

for j in ${leks[@]};
do
  for k in ${align[@]};
  do
    for m in ${fossils[@]};
    do
      for n in ${times[@]};
      do
        for o in ${clocks[@]};
        do
          echo starting dataset
          lekinfo="${j}"."${k}"."${m}"."${n}"."${o}"
          echo $lekinfo
          echo $lekinfo >> ./output/revbayes/stdout/dataset.txt
          rb_command="source(\"./source/"$j"_"$k"_"$m"_"$n""$o".Rev\");"
          ML_out="./output/revbayes/ML/"$j"_"$k"_"$m"_"$n""$o".txt"
          echo $rb_command | mpirun -np 2 rb | tee $ML_out
          cat $ML_out | tail -1 >> ./output/revbayes/stdout/PathSampler.txt
          cat $ML_out | tail -2 | head -1 >> ./output/revbayes/stdout/SteppingStone.txt
          echo ML approximated \for $lekinfo
        done
      done
    done
  done
done



end=$SECONDS
duration=$(( end - start ))

#echo "conversion to nexus took $duration seconds to complete"
