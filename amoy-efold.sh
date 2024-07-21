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
		
	LOAD_LC=$(find "$CURXTI/event_cl" -type f -name "*_sr.lc")
	LC_FILE=$(find "$CURXTI/event_cl" -type f -name "*_sr.lc" -exec basename {} \; | tr '\n' ' ')
	if [[ -f "$LOAD_LC" ]]; then
		cd $CURXTI/event_cl
		efold nser=1 cfile1="$LC_FILE" window="-" sepoch=INDEF dper=1.5577081E-3 nphase=10 nbin=3194 nintfm=INDEF plot=yes plotdev="/xw" plotdnum=1 outfile="-" <<EOF 
line step
color 5 on 2
error off
cpd folded_$i.gif/gif
p
quit
EOF
	else
		echo "File *_sr.lc not found for ObsID $i"
    fi
done