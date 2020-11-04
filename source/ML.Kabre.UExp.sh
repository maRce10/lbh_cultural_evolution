#!/bin/bash

#Run g1 model with beta prior and broad root prior for 3 days max in a node with 8 cores
#SBATCH --partition=nu-long
#SBATCH --job-name=ML.Approx.R1-long

#send an email when it's done
#SBATCH --mail-user=beatriz.willink@ucr.ac.cr --mail-type=END,FAIL
#load modules: compiler, open mpi and RevBayes
module load revbayes/1.1.0   
module load gcc/9.3.0
module load mpich/3.3.2-gcc-9.3.0

start=$SECONDS

#list of leks
leks=("BR1" "CCE" "HC1" "SUR" "TR1")

#list of alignments
align=("all.equal" "optimal" "prank")

#list of fossils
fossils=("new" "old")

#list of fossil times
times=("all" "early")

#list of molecular clocks
clocks=("_Uexp")

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
          lekinfo="${j}"."${k}"."${m}"."${n}"
          echo $lekinfo
          echo $lekinfo >> ../output/revbayes/stdout/dataset.txt
          rb_command="source(\"./"$j"_"$k"_"$m"_"$n".Rev\");"
          ML_out="./output/revbayes/ML/"$j"_"$k"_"$m"_"$n".txt"
          echo $rb_command | mpiexec -np 32 rb-mpi | tee $ML_out
          cat $ML_out | tail -1 >> ../output/revbayes/stdout/PathSampler.txt
          cat $ML_out | tail -2 | head -1 >> ../output/revbayes/stdout/SteppingStone.txt
          echo ML approximated \for $lekinfo
        done
      done
    done
  done
done



end=$SECONDS
duration=$(( end - start ))

echo Time to ML $duration
