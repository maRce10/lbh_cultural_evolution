#!/bin/bash
debug=0

# load Revbayes through spack
cd ~/Applications/spack/
source share/spack/setup-env.sh
spack load revbayes

# go to wd
cd /media/bwillink/HD710\ PRO/Investigacion/lbh_cultural_evolution

filelist=`ls ./source/P3/ | grep -E *no.fossils`

# make rb command
for file in $filelist; do
    echo "Running model \"$file\""
        rb_command="source(\"source/P3/$file\");"
        echo $rb_command | rb 
done
echo "...done!"

