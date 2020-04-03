#!/bin/bash

start=$SECONDS

#Leks with 8 or more songs
leks=("BR1" "CCE" "CCL" "HC1" "HC2" "LOC" "SAT" "SJA" "SUR" "TR1" "TR2")
for j in ${leks[@]};
do
   #Align with text matrix with equal HIGH costs for all substitutions (0.5)
   mafft --localpair --maxiterate 10000 --textmatrix ./CostMatrix_equal_high.txt ./SongSeqs_$j.fa > SongSeqs_$j.aligned_equal_high.fa 2> Mafft_output.txt
   #Align with text matrix with equal LOW costs for all substitutions (1)
   mafft --localpair --maxiterate 10000 --textmatrix ./CostMatrix_equal_low.txt ./SongSeqs_$j.fa > SongSeqs_$j.aligned_equal_low.fa 2>> Mafft_output.txt
   #Align with text matrix with costs depending on song type (1 vs 0.5)
   mafft --localpair --maxiterate 10000 --textmatrix ./CostMatrix_by_type.txt ./SongSeqs_$j.fa > SongSeqs_$j.aligned_by_type.fa 2>> Mafft_output.txt
    #Align with text matrix with costs depending on song type (1 vs -0.5)
   mafft --localpair --maxiterate 10000 --textmatrix ./CostMatrix_by_type_2.txt ./SongSeqs_$j.fa > SongSeqs_$j.aligned_by_type_2.fa 2>> Mafft_output.txt
done

end=$SECONDS
duration=$(( end - start ))

echo "mafft alingments took $duration seconds to complete"
