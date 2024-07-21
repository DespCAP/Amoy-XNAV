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
	
	nicerl2 indir=$i clobber=YES
	nicerl3-spect indir=$i clobber=YES
	echo
	
	# Find the _load.xcm file
    LOAD_XCM=$(find "$CURXTI/event_cl" -type f -name "*_load.xcm")

    if [[ -f "$LOAD_XCM" ]]; then
        xspec <<EOF
@$LOAD_XCM
cd $i
cpd spect-$i/ps
setplot energy
setplot rebin 1 2
plot ldata
cpd none
exit
EOF
    else
        echo "File *_load.xcm not found for ObsID $i"
    fi
	
done