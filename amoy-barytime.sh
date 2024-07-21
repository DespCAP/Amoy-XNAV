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

mapfile -t < $CODESFOLDER/obsids.txt # get list of ObsIDs as array


for i in "${MAPFILE[@]}"
do
	cd $DATAFOLDER
    export CWD=$DATAFOLDER/$i # Current Working Directory
    export CURAUX=$CWD/auxil # Current auxil Directory
    export CURXTI=$CWD/xti # Current xti Directory
 
	echo
    echo "--------------------------------------------------------"
    echo "*******Looping ... Currently processing ObsID $i*******"
    echo "--------------------------------------------------------"	
	echo
		
	LOAD_CL=$(find "$CURXTI/event_cl" -type f -name "*_cl.evt")
    CL_FILE=$(find "$CURXTI/event_cl" -type f -name "*_cl.evt" -exec basename {} \; | tr '\n' ' ')
   	ORB_FILE=$(find "$CURAUX" -type f -name "*.orb" )

    if [[ -f "$LOAD_CL" ]]; then
    	cd $CURXTI/event_cl
    	chmod +rwx $CL_FILE
    	OUTFILE="${i}_bary.evt"
        barycorr infile=$CL_FILE outfile=$OUTFILE orbitfiles=$ORB_FILE ra=38.560210 dec=59.14166 barytime=yes
    else
        echo "File *_cl.evt not found for ObsID $i"
    fi
done