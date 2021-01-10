#!/usr/bin/env bash

source config.txt

while true; 
do

    data=""
    arduino_dev=""
    arduino_devs="/dev/ttyUSB0 /dev/ttyUSB1 /dev/ttyUSB2 /dev/ttyUSB3 /dev/ttyS1 "
    for name_dev in $arduino_devs:
    do
        if [ -c "$name_dev" ]; then
            arduino_dev=$name_dev
            break
        fi
    done

    if [ $arduino_dev ]; then

        # Temperatura PCB
        if [ $pcb_temp_input ]; then
            value=$(cat $pcb_temp_input)
            value=$(($value/1000))
            data="$data|TP$value"
        fi

        # Temperatura CPU
        if [ $cpu_temp_input ] ; then
            value=$(cat $cpu_temp_input)
            value=$(($value/1000))
            data="$data|TC$value"
        fi

        # Temperatura GPU
        if [ $gpu_temp_input ]; then
            value=$(cat $gpu_temp_input)
            value=$(($value/1000))
            data="$data|TG$value"
        fi

        # Fan PCB
        if [ $pcb_fan_sensor_input ]; then
            value=$(cat $pcb_fan_sensor_input)
            data="$data|FP$value"
        fi

        # Fan CPU
        if [ $cpu_fan_sensor_input ] ; then
            value=$(cat $cpu_fan_sensor_input)
            data="$data|FC$value"
        fi

        # Fan GPU
        if [ $gpu_fan_sensor_input ]; then
            value=$(cat $gpu_fan_sensor_input)
            data="$data|FG$value"
        fi

        if [ "$data" ]; then
            data="$data|"
            sudo chmod 777 $arduino_dev
            # stty -F $arduino_dev -hupcl
            stty -F /dev/ttyUSB0 115200 cs8 -cstopb -parenb
            echo "Sending to $arduino_dev -> data: $data"
            echo $data > $arduino_dev
        fi

    else

        echo "Arduino Serial DEV: not found"

    fi

    sleep $sleep_seconds

done