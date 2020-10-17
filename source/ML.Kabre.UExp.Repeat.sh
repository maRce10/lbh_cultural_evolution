#!/bin/bash

#Run g1 model with beta prior and broad root prior for 3 days max in a node with 8 cores
#SBATCH --partition=nu-long
#SBATCH --job-name=ML.Approx.Uexp-repeat

#send an email when it's done
#SBATCH --mail-user=beatriz.willink@ucr.ac.cr --mail-type=END,FAIL
#load modules: compiler, open mpi and RevBayes
module load revbayes/1.1.0   
module load gcc/9.3.0
module load mpich/3.3.2-gcc-9.3.0

start=$SECONDS

#list of model
models=("CCE_optimal_old_all" "CCE_prank_old_all")

for j in ${models[@]};
do
  echo starting dataset
  lekinfo="${j}"
  echo $lekinfo
  echo $lekinfo >> ../output/revbayes/stdout/datasetRepeats.txt
  rb_command="source(\"./source/"$j".Rev\");"
  ML_out="./output/revbayes/ML/"$j".Repeat.txt"
  echo $rb_command | mpiexec -np 16 rb-mpi | tee $ML_out
  cat $ML_out | tail -1 >> ../output/revbayes/stdout/PathSamplerRepeat.txt
  cat $ML_out | tail -2 | head -1 >> ../output/revbayes/stdout/SteppingStoneRepeat.txt
  echo ML approximated \for $lekinfo
done

end=$SECONDS
duration=$(( end - start ))

echo Time to ML $duration

