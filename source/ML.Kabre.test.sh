#!/bin/bash

#Run g1 model with beta prior and broad root prior for 3 days max in a node with 8 cores
#SBATCH --partition=andalan
#SBATCH --time 3-0:00:00 --job-name=G1BetaR1

#send an email when it's done
#SBATCH --mail-user=beatriz.willink@ucr.ac.cr --mail-type=END,FAIL
#load modules: compiler, open mpi and RevBayes
module load revbayes/1.1.0   
module load gcc/9.3.0
module load mpich/3.3.2-gcc-9.3.0

start=$SECONDS

rb_command="source(\"./source/BR1_prank_new_all.Rev\");"
ML_out="./output/revbayes/ML/BR1_prank_new_all.txt"
echo $rb_command | mpiexec -np 64 rb-mpi | tee $ML_out
cat $ML_out | tail -1 >> ./output/revbayes/stdout/PathSampler.txt
cat $ML_out | tail -2 | head -1 >> ./output/revbayes/stdout/SteppingStone.txt
echo ML approximated \for $lekinfo

end=$SECONDS
duration=$(( end - start ))

echo $duration
