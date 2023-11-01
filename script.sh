#!/bin/bash

# set -x

create_xs_files() {
        start=$1
        end=$2

        i=$start
        while [ $i -lt $end ]
        do
                echo $i > xs-files/file-$i
                echo "$i is done"
                ((i += 1))
        done
}

parallel_put() {
        start=$1
        end=$2
        step=$3

        i=$start
        while [ $i -lt $end ]
        do
                j=$i
                ps=()
                while [[ $j -lt $end ]] && [[ $j -lt $((i+step)) ]]
                do
                        hdfs dfs -put xs-files/file-$j xs-files &
                        p=$!
                        ps+=($!)
                        echo "$p has started"
                        ((j += 1))
                done
                ((i += $step))
                for p in ${ps[*]}; do
                        wait $p
                        echo "$p is done"
                done
        done
}

parallel_rm() {
        start=$1
        end=$2
        step=$3

        i=$start
        while [ $i -lt $end ]
        do
                j=$i
                ps=()
                while [[ $j -lt $end ]] && [[ $j -lt $((i+step)) ]]
                do
                        hdfs dfs -rm xs-files/file-$j &
                        p=$!
                        ps+=($!)
                        echo "$p has started"
                        ((j += 1))
                done
                ((i += $step))
                for p in ${ps[*]}; do
                        wait $p
                        echo "$p is done"
                done
        done
}

start_time=$(date +%s%N)
case $1 in
        "put")
                parallel_put $2 $3 $4
                ;;
        "rm")
                parallel_rm $2 $3 $4
                ;;
        "create")
                create_xs_files $2 $3
                ;;
        *)
                echo "invalid argument $1"
                ;;
esac
end_time=$(date +%s%N)
ms=$(($((end_time - start_time)) / 1000000))
echo "time duration: $ms ms"
