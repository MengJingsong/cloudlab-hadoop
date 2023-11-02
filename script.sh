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
        hdfs_dir=$4

        i=$start
        while [ $i -lt $end ]
        do
                j=$i
                ps=()
                start_time=$(date +%s%N)
                while [[ $j -lt $end ]] && [[ $j -lt $((i+step)) ]]
                do
                        hdfs dfs -put xs-files/file-$j $hdfs_dir &
                        p=$!
                        ps+=($!)
                        ((j += 1))
                done
                for p in ${ps[*]}; do
                        wait $p
                done
                end_time=$(date +%s%N)
                ms=$(($((end_time - start_time)) / 1000000))
                echo "put [$i - $((i+step))] have done, time duration: $ms ms"
                ((i += $step))
        done
}

parallel_rm() {
        start=$1
        end=$2
        step=$3
        hdfs_dir=$4

        i=$start
        while [ $i -lt $end ]
        do
                j=$i
                ps=()
                start_time=$(date +%s%N)
                while [[ $j -lt $end ]] && [[ $j -lt $((i+step)) ]]
                do
                        hdfs dfs -rm $hdfs_dir/file-$j &
                        p=$!
                        ps+=($!)
                        ((j += 1))
                done
                for p in ${ps[*]}; do
                        wait $p
                done
                end_time=$(date +%s%N)
                ms=$(($((end_time - start_time)) / 1000000))
                echo "rm [$i - $((i+step))] have done, time duration: $ms ms"
                ((i += $step))
        done
}

start_time=$(date +%s%N)
case $1 in
        "put")
                parallel_put $2 $3 $4 $5
                ;;
        "rm")
                parallel_rm $2 $3 $4 $5
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
echo "total time duration: $ms ms"
