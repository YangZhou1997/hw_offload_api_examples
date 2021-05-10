# !/bin/bash

echo 20000 | sudo tee /sys/devices/system/node/node0/hugepages/hugepages-2048kB/nr_hugepages

make clean &> /dev/null
make &> /dev/null
for k in 3 8; do
    all_res=""
    for pagesize in 512 1024 2048 4096 8192 16384 32768 65536 131072 262144 524288 1048576 2097152; do
        output=`LD_LIBRARY_PATH=./install/lib taskset -c 0 ./ibv_ec_perf_async -r 16 -f 0 -i mlx5_3 -k $k -m 2 -w 8 -s $pagesize -d`
        echo $output
        number=`echo $output | grep m_bw | awk '{ print $1; }'`
        all_res="$all_res $number"
    done
    echo "without hugepage RS($k, 2): " $all_res
done

make clean &> /dev/null
make CFLAGS="-DUSING_HG" &> /dev/null
for k in 3 8; do
    all_res=""
    for pagesize in 512 1024 2048 4096 8192 16384 32768 65536 131072 262144 524288 1048576 2097152; do
        output=`LD_LIBRARY_PATH=./install/lib taskset -c 0 ./ibv_ec_perf_async -r 16 -f 0 -i mlx5_3 -k $k -m 2 -w 8 -s $pagesize -d`
        echo $output
        number=`echo $output | grep m_bw | awk '{ print $1; }'`
        all_res="$all_res $number"
    done
    echo "with hugepage RS($k, 2): " $all_res
done

echo 0 | sudo tee /sys/devices/system/node/node0/hugepages/hugepages-2048kB/nr_hugepages

