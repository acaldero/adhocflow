#!/bin/bash
#set -x


#
#  Copyright 2019-2023 Saul Alonso Monsalve, Felix Garcia Carballeira, Jose Rivadeneira Lopez-Bravo, Alejandro Calderon Mateos,
#
#  This file is part of DaLoFlow.
#
#  DaLoFlow is free software: you can redistribute it and/or modify
#  it under the terms of the GNU Lesser General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  DaLoFlow is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU Lesser General Public License for more details.
#
#  You should have received a copy of the GNU Lesser General Public License
#  along with DaLoFlow.  If not, see <http://www.gnu.org/licenses/>.
#


#
# Params
#

SIZES="32 128"
N_IMG_TRAIN="1000000"
N_IMG_TEST="1000"

N_NODES=4
N_PROCESS="1 2 4 8"
N_CONVS="1 10 50"


#
# Main
#

# build datasets...
echo ": : Building dataset..."
for S in $SIZES; do

    DIR_NAME="dataset"$S"x"$S
    if [ ! -d $DIR_NAME ]; then
         echo ": Dataset for "$N_IMG_TRAIN" images of "$S"x"$S" pixels..."
         echo "  python3 mk_dataset.py --height $S --width $S --ntrain $N_IMG_TRAIN --ntest $N_IMG_TEST"
    fi

done

# build datasets...
echo ": : Work session..."
echo ./daloflow.sh swarm-start $N_NODES

for CONVS in $N_CONVS; do
for NP in $N_PROCESS; do
for S in $SIZES; do

    DIR_NAME="dataset"$S"x"$S
    let IPART=$NP*$CONVS
    let ITERS=52000/$IPART

    echo ": Testing dataset $DIR_NAME with $NP processes on $N_NODES nodes..."
    echo "  ./daloflow.sh mpirun $NP \"python3 ./do_tf2kp_mnist.py --height $S --width $S --path $DIR_NAME --iters $ITERS --convs $CONVS\" |& grep -v \"Read -1\""

done
done
done

echo ./daloflow.sh swarm-stop


