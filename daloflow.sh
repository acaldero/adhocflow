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


daloflow_welcome ()
{
	echo ""
	echo "  daloflow 4.0"
	echo " --------------"
	echo ""
}

daloflow_help ()
{
	echo ": For first time deployment, please execute:"
	echo "  $0 init"
	echo "  $0 prerequisites"
	echo "  $0 build"
	echo ""
	echo ": For a typical single node work session (with 4 containers and 2 process), please execute:"
	echo "  $0 start 4"
	echo "  $0 mpirun 2 \"python3 ./do_tf2kp_mnist.py --height 32 --width 32 --path dataset32x32 --convs 1 --iters 2\""
	echo "  ..."
	echo "  $0 stop"
	echo ""
	echo ": For a typical multinode work session (with 4 containers and 2 process), please execute:"
	echo "  $0 swarm-start 4"
	echo "  $0 mpirun 2 \"python3 ./do_tf2kp_mnist.py --height 32 --width 32 --path dataset32x32 --convs 1 --iters 2\""
	echo "  ..."
	echo "  $0 stop"
	echo ""
	echo ": Available options for (single node) debugging:"
	echo "  $0 bash <id container, from 1 up to nc>"
	echo "  $0 docker_in_docker"
	echo "  $0 save | load | status | test"
	echo ""
	echo ": Please read the README.md file for more information (https://github.com/saulam/daloflow/)."
	echo ""
}


#
# Installation
#

daloflow_init ()
{
	# Setup number of containers
	PU=cpu
	if [ "$1" == "gpu" ]; then
	     PU=gpu
	fi

	echo "Building Dockerfile, Dockercompose.yml and Dockerstack.yml for $PU..."

	# SOURCE_DIRECTORY -> current working directory
	sed "s|SOURCE_DIRECTORY|$(pwd)|g" docker/Dockercompose.yml-model > Dockercompose.yml
	sed "s|SOURCE_DIRECTORY|$(pwd)|g" docker/Dockerstack.yml-model   > Dockerstack.yml
	cat                               docker/Dockerfile-$PU-daloflow > Dockerfile

	#echo "Downloading Source Code for OpenMPI 4.0.5, tensorflow 2.3.0, and Horovod 0.20.3..."

	## MPI
        #wget https://www.open-mpi.org/software/ompi/v4.0/downloads/openmpi-4.0.5.tar.gz
	#rm -fr openmpi
        #tar zxf openmpi-4.0.5.tar.gz
	#mv openmpi-4.0.5 openmpi

	## TENSORFLOW
	#wget https://github.com/tensorflow/tensorflow/archive/v2.3.0.tar.gz
	#rm -fr tensorflow
	#tar zxf v2.3.0.tar.gz
	#mv tensorflow-2.3.0 tensorflow

	## HOROVOD
	#wget https://github.com/horovod/horovod/archive/v0.20.3.tar.gz
	#rm -fr horovod
	#tar zxf v0.20.3.tar.gz
	#mv horovod-0.20.3 horovod
}

daloflow_prerequisites ()
{
	echo "Installing Docker, Docker-compose and Nvidia-container-runtime..."

	# To Install DOCKER
	sudo apt-get update
	sudo apt-get upgrade
	sudo apt-get install -y curl apt-transport-https ca-certificates software-properties-common
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
        curl https://bazel.build/bazel-release.pub.gpg | sudo apt-key add -
	sudo apt-get update
	sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
	sudo apt-get update
	sudo apt install -y docker-ce docker-ce-cli containerd.io

	# To Install DOCKER-COMPOSER
	pip3 install docker-compose

	# NVIDIA GPU: https://nvidia.github.io/nvidia-container-runtime/
	curl -s -L https://nvidia.github.io/nvidia-container-runtime/gpgkey | sudo apt-key add -
	distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
	curl -s -L https://nvidia.github.io/nvidia-container-runtime/$distribution/nvidia-container-runtime.list | \
		  sudo tee /etc/apt/sources.list.d/nvidia-container-runtime.list
	sudo apt-get update
	apt-get install -y nvidia-container-runtime
        #docker run -it --rm --gpus all ubuntu nvidia-smi
}


#
# Image
#

daloflow_build_base_image ()
{
	# Check params
        if [ ! -f Dockerfile ]; then
            echo ": The Dockerfile file is not found."
	    echo ": * Did you execute ./daloflow.sh init first?."
	    echo ": * Please see ./daloflow.sh help for more information."
	    echo ""
            exit
        fi

	echo "Building initial image..."
	docker image build -t daloflow:v2 .
}

daloflow_save ()
{
	echo "Saving daloflow:v2 image..."
	IMAGE_ID_LIST=$(docker image ls|grep daloflow|grep latest|awk '{print $3}')
	docker image save daloflow:v2 | gzip -5 > daloflow_v2.tgz 
}

daloflow_load ()
{
	# Check params
        if [ ! -f daloflow_v2.tgz ]; then
            echo ": The daloflow_v2.tgz file is not found."
	    echo ": * Please see ./daloflow.sh help for more information."
	    echo ""
            exit
        fi

	echo "Loading daloflow:v2 image..."
	cat daloflow_v2.tgz | gunzip - | docker image load
}


#
# Execution
#

daloflow_start ()
{
	# Setup number of containers
	NC=$1
	if [ $# -lt 1 ]; then
	     NC=1
	fi

	# Check params
        if [ -f .daloflow_worksession ]; then
            echo ": There is an already running daloflow container."
	    echo ": * Please stop first."
	    echo ": * Please see ./daloflow.sh help for more information."
	    echo ""
            exit
        fi

	# Make export directory
        mkdir -p export

	# Start container cluster (in single node)
	docker-compose -f Dockercompose.yml up -d --scale node=$NC
	if [ $? -gt 0 ]; then
            echo ": The docker-compose command failed to spin up containers."
	    echo ""
	    exit
	fi
	echo "wating $NC seconds..."
	sleep $NC

	# Container cluster (in single node) files...
	CONTAINER_ID_LIST=$(docker ps -f name=daloflow -q)
	docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $CONTAINER_ID_LIST > machines_mpi
	docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $CONTAINER_ID_LIST | sed 's/.*/& slots=1 max_slots=16/g' > machines_horovod

	if [ $(getent group daloflow) ]; then
	     chgrp daloflow machines_*
	fi

	# session mode
	echo "SINGLE_NODE" > .daloflow_worksession
}

daloflow_swarm_start ()
{
        # Setup number of containers
        NC=$1
        if [ $# -lt 1 ]; then
             NC=1
        fi

	# Check params
        if [ -f .daloflow_worksession ]; then
            echo ": There is an already running daloflow container."
	    echo ": * Please stop first."
	    echo ": * Please see ./daloflow.sh help for more information."
	    echo ""
            exit
        fi

	# Make export directory
        mkdir -p export

        # Start container cluster
        docker stack deploy --compose-file Dockerstack.yml daloflow
	if [ $? -gt 0 ]; then
            echo ": The docker stack deploy command failed to spin up containers."
	    echo ""
	    exit
	fi
        docker service scale daloflow_node=$NC

        # Container cluster files...
        CONTAINER_ID_LIST=$(docker service ps daloflow_node -f desired-state=running -q)
        docker inspect -f '{{range .NetworksAttachments}}{{.Addresses}}{{end}}' $CONTAINER_ID_LIST | sed "s/^\[//g" | awk 'BEGIN {FS="/"} ; {print $1}' > machines_mpi
        cat machines_mpi | sed 's/.*/& slots=1/g' > machines_horovod

	# session mode
	echo "MULTI_NODE" > .daloflow_worksession
}

daloflow_stop ()
{
	# get current session mode
	MODE=""
        if [ -f .daloflow_worksession ]; then
	     MODE=$(cat .daloflow_worksession)
        fi

	# Stop composition
        if [ "$MODE" == "SINGLE_NODE" ]; then
	     docker-compose -f Dockercompose.yml down
        fi
	# Stop service
        if [ "$MODE" == "MULTI_NODE" ]; then
	     docker service rm daloflow_node
        fi

        # Remove container cluster files...
	rm -fr machines_mpi
	rm -fr machines_horovod
	rm -fr .daloflow_worksession
}

daloflow_run ()
{
	# Get parameters
	NP=$1
	shift
	A=$@
	CNAME=$(docker ps -f name=daloflow -q | head -1)

	# Check parameters
	if [ "x$CNAME" == "x" ]; then
            echo ": There is not a running daloflow container."
	    echo ": * Please start/swarm-start first."
	    echo ": * Please see ./daloflow.sh help for more information."
	    echo ""
            exit
	fi
	if [ ! -f machines_horovod ]; then
            echo ": The machines_horovod file was not found."
	    echo ": * Please start/swarm-start first."
	    echo ": * Please see ./daloflow.sh help for more information."
	    echo ""
            exit
	fi

        # daloflow:v2
	docker container exec -it $CNAME     \
	       mpirun -np $NP -machinefile machines_horovod \
	              --oversubscribe \
		      -bind-to none -map-by slot -verbose --allow-run-as-root \
		       -x NCCL_DEBUG=INFO -x LD_LIBRARY_PATH -x PATH \
		       -x NCCL_SOCKET_IFNAME=^lo,docker0 \
		       -mca pml ob1 -mca btl ^openib \
		       -mca btl_tcp_if_exclude lo,docker0,eth1 \
		      $A
}

daloflow_bash_node ()
{
	# Get parameters
	CIP=$(head -$1 machines_mpi | tail -1)
	CNAME=$(docker ps -f name=daloflow -q | head -1)
	NN=$(wc -l machines_mpi  | awk '{print $1}')

	# Check parameters
	if [ ! -f machines_mpi ]; then
            echo ": The machines_mpi file was not found."
	    echo ": * Please start/swarm-start first."
	    echo ": * Please see ./daloflow.sh help for more information."
	    echo ""
            exit
	fi
	if [ "x$CIP" == "x" ]; then
	    echo ": The node ID $1 is out of range (1 up to $NN)."
	    echo ": * Please see ./daloflow.sh help for more information."
	    echo ""
            exit
	fi
	if [ "x$CNAME" == "x" ]; then
            echo ": There is not a running daloflow container."
	    echo ": * Please start/swarm-start first."
	    echo ": * Please see ./daloflow.sh help for more information."
	    echo ""
            exit
	fi

	docker container exec -it $CNAME /usr/bin/ssh $CIP
}


#
# Testing
#

daloflow_test ()
{
	# Install each node
	CONTAINER_ID_LIST=$(docker ps -f name=daloflow -q)
	for C in $CONTAINER_ID_LIST; do
		docker container exec -it $C ./daloflow.sh test_node 
	done
}

daloflow_test_node ()
{
	# MPICH
	# execute cpi
	cd /usr/src/daloflow/mpich/examples
	mpicc -o cpi cpi.c
	mpirun -np 2 -machinefile /usr/src/daloflow/machines_mpi $(pwd)/cpi

	# HOROVOD
	horovodrun --verbose -np 2 -hostfile machines_horovod  python3 ./horovod/examples/tensorflow2_mnist.py
}


#
# Main
#

# Usage
if [ $# -eq 0 ]; then
        daloflow_welcome
	daloflow_help $0
	exit
fi

# for each argument, try to execute it
while (( "$#" )); 
do
	case $1 in
	     # first execution
	     init|postclone)
		shift
		daloflow_init $@
	     ;;
	     prerequisites)
		daloflow_prerequisites
	     ;;

	     # image
	     build|image)
                daloflow_build_base_image
	     ;;
	     save)
                daloflow_save
	     ;;
	     load)
                daloflow_load
	     ;;

	     # single node
	     start)
		shift
		daloflow_start $@
	     ;;
	     stop)
                daloflow_stop
	     ;;

	     # multinode node
	     swarm-start)
		shift
		daloflow_swarm_start $@
	     ;;
	     swarm-stop)
                daloflow_stop
	     ;;

	     # mpirun + bash
	     mpirun|swarm-mpirun)
		shift
                daloflow_run $@
		shift
		shift
	     ;;
	     bash)
		shift
                daloflow_bash_node $@
	     ;;

	     # single node utilities
	     status|ps)
		docker ps
	     ;;
	     test)
		daloflow_test
	     ;;
	     test_node)
		daloflow_test_node
	     ;;
             docker_in_docker)
		docker run --network host -v $(pwd):/usr/src/daloflow -v "/var/run/docker.sock:/var/run/docker.sock" --runtime=nvidia -it ubuntu /bin/bash
	     ;;

	     # help
	     *)
                daloflow_welcome
		daloflow_help $0
	     ;;
	esac
	shift
done


