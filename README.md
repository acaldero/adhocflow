<html>
 <h1 align="center">adhocflow: <br>AD-HOC storage for tensorFLOW</h1>
 <br>
</html>

## Ad-Hoc Flow

Ad-Hoc Flow is an evolution of the [DAta LOcality on tensorFLOW](https://github.com/saulam/daloflow) project.
Daloflow uses HDFS as back-end storage solution but *Ad-Hoc Flow* extends to more storage solutions.


## Getting daloflow and initial setup:
1. Clone from github and initialize for cpu (gpu option is also available):
```bash
 git clone https://github.com/saulam/daloflow.git
 cd daloflow
 chmod +x ./daloflow.sh
 ./daloflow.sh init cpu
``` 
2. IF docker + docker-compose is not installed THEN please install pre-requisites:
```bash
 ./daloflow.sh prerequisites
```
3. Build the docker image:
```bash
 ./daloflow.sh build
```
  
## Typical daloflow work session:
<html>
 <table>
  <tr>
  <td>
</html>

A new single node work session:
```bash
./daloflow.sh start 4
./daloflow.sh mpirun 2 "python3 ./do_task.py"
: ...
./daloflow.sh stop
```

For example, with "./daloflow.sh start" four container are spin-up in one node, the current one (NC=4).
Then, do_task.py was executed with 2 process (NP=2, only two containers are used).

<html>
  </td>
  <td>
</html>

A new work session using several nodes:
```bash
./daloflow.sh swarm-start 4
./daloflow.sh mpirun 2 "python3 ./do_task.py"
: ...
./daloflow.sh stop
```

For example, with "./daloflow.sh swarm-start" containers are spin-up in four nodes (NC=4, one container per node).
Then, do_task.py was executed with 2 process (NP=2) on the first two nodes.

<html>
  </td>
  </tr>
 </table>
</html>


## Some additional options for debugging:
1. Build a random dataset for 1000000 images of 32x32 pixels:
```bash
python3 mk_dataset.py --height 32 --width 32 --ntrain 1000000 --ntest 1000
```
2. To get the status of the running containers:
```bash
 ./daloflow.sh status
```
3. To execute a bash in a container:
```bash
 ./daloflow.sh bash <container id: from 1 up to NC>
```


## Authors
* :technologist: Saúl Alonso Monsalve
* :technologist: Félix García-Carballeira
* :technologist: Alejandro Calderón Mateos
* :technologist: José Rivadeneira López-Bravo 
* :technologist: Diego Camarmas Alonso 
* :technologist: Elias del Pozo Puñal

