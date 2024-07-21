#!/bin/bash
#-----------------------------------------------
#-----------------------------------------------
### Define user-paths for convenience

export DATAFOLDER=/home/amoy/xnav/nicer-data/B1937+21
export CODESFOLDER=/home/amoy/xnav/codes

#-----------------------------------------------
#-----------------------------------------------
### Loop over the ObsIds in the data set,
### and merge the various files required for
### making the pulse profile

ls $DATAFOLDER > $CODESFOLDER/obsids.txt
mapfile -t < $CODESFOLDER/obsids.txt # get list of ObsIDs as array


for i in "${MAPFILE[@]}"
do
	cd "$DATAFOLDER" || exit
    export CWD=$DATAFOLDER/$i # Current Working Directory
    export CURAUX=$CWD/auxil # Current auxil Directory
    export CURXTI=$CWD/xti # Current xti Directory
    
	echo
    echo "--------------------------------------------------------"
    echo "*******Looping ... Currently processing ObsID $i*******"
    echo "--------------------------------------------------------"
	
	echo
	nicerl3-lc indir=$i pirange=300-1500 timebin=1E-4 clobber=YES
	
done