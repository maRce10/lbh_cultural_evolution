#!/bin/bash

#Run g1 model with beta prior and broad root prior for 3 days max in a node with 8 cores
#SBATCH --partition=nu-long
#SBATCH --job-name=ML.NoFoss.R1
#send an email when it's done
#SBATCH --mail-user=beatriz.willink@ucr.ac.cr --mail-type=END,FAIL
#load modules: compiler, open mpi and RevBayes
module load revbayes/1.1.0   
module load gcc/9.3.0
module load mpich/3.3.2-gcc-9.3.0

start=$SECONDS

#list of leks
leks=("BR1" "SUR" "TR1")

#list of alignments
align=("all.equal" "optimal" "prank")

#list of molecular clocks
clocks=("_Uexp")

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
    rb_command="source(\"./source/no_fossils"$j"_"$k"_no.fossils.full_process_"$o".Rev\");"
    ML_out="./output/revbayes/ML/"$j"_"$k"_no.fossils.full_process_"$o".txt"
    echo $rb_command | mpiexec -np 16 rb-mpi | tee $ML_out
    cat $ML_out | tail -1 >> ./output/revbayes/stdout/PathSampler.txt
    cat $ML_out | tail -2 | head -1 >> ./output/revbayes/stdout/SteppingStone.txt
    echo ML approximated \for $lekinfo
    done
  done
done



end=$SECONDS
duration=$(( end - start ))

echo Time to ML $duration
