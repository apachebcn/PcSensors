#!/usr/bin/env bash

sleep_seconds=1
cpu_temp_label="Package id 0"
gpu_temp_label="Core 4"
pcb_temp_label="Core 2"
cpu_fan_label=""
gpu_fan_label=""
pcb_fan_label=""


# Sensores de temperatura
cpu_temp_sensor_file=""
gpu_temp_sensor_file=""
pcb_temp_sensor_file=""
cpu_fan_sensor_file=""
gpu_fan_sensor_file=""
pcb_fan_sensor_file=""
sensors_labels=$(find /sys/devices/platform -name temp*label)
sensors_count=0
for sensor_label_file in $sensors_labels
do
    sensor_temp_file=$(echo "$sensor_label_file" | sed "s/label/input/g")
    if [ "$sensor_temp_file" ]; then

        sensor_label_value=$(cat $sensor_label_file)

        if [ "$sensor_label_value" = "$cpu_temp_label" ]; then
            cpu_temp_sensor_file=$sensor_temp_file
            echo "$sensor_label_value * CAPTURADO COMO CPU TEMP *"
            ((sensors_count=sensors_count+1))
        fi
        if [ "$sensor_label_value" = "$gpu_temp_label" ]; then
            gpu_temp_sensor_file=$sensor_temp_file
            echo "$sensor_label_value * CAPTURADO COMO GPU TEMP *"
            ((sensors_count=sensors_count+1))
        fi
        if [ "$sensor_label_value" = "$pcb_temp_label" ]; then
            pcb_temp_sensor_file=$sensor_temp_file
            echo "$sensor_label_value * CAPTURADO COMO PCB TEMP *"
            ((sensors_count=sensors_count+1))
        fi
        if [ "$sensor_label_value" = "$cpu_fan_label" ]; then
            cpu_fan_sensor_file=$sensor_fan_file
            echo "$sensor_label_value * CAPTURADO COMO CPU FAN *"
            ((sensors_count=sensors_count+1))
        fi
        if [ "$sensor_label_value" = "$gpu_fan_label" ]; then
            gpu_fan_sensor_file=$sensor_fan_file
            echo "$sensor_label_value * CAPTURADO COMO GPU FAN *"
            ((sensors_count=sensors_count+1))
        fi
        if [ "$sensor_label_value" = "$pcb_fan_label" ]; then
            pcb_fan_sensor_file=$sensor_fan_file
            echo "$sensor_label_value * CAPTURADO COMO PCB FAN *"
            ((sensors_count=sensors_count+1))
        fi

    fi
done

echo ""
echo "sensors count $sensors_count"
echo "cpu temp =>  $cpu_temp_sensor_file"
echo "gpu temp =>  $gpu_temp_sensor_file"
echo "pcb temp =>  $pcb_temp_sensor_file"
echo "cpu fan =>  $cpu_fan_sensor_file"
echo "gpu fan =>  $gpu_fan_sensor_file"
echo "pcb fan =>  $pcb_fan_sensor_file"

if [ $sensors_count = 0 ]; then
    echo "no sensors found"
    exit
fi


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

        # Temperatura CPU
        if [ $cpu_temp_sensor_file ] ; then
            value=$(cat $cpu_temp_sensor_file)
            value=$(echo "$value" | sed "s/000//g")
            data="$data|TC$value"
        fi

        # Temperatura GPU
        if [ $gpu_temp_sensor_file ]; then
            value=$(cat $gpu_temp_sensor_file)
            value=$(echo "$value" | sed "s/000//g")
            data="$data|TG$value"
        fi

        # Temperatura PCB
        if [ $pcb_temp_sensor_file ]; then
            value=$(cat $pcb_temp_sensor_file)
            value=$(echo "$value" | sed "s/000//g")
            data="$data|TP$value"
        fi

        # Fan CPU
        if [ $cpu_fan_sensor_file ] ; then
            value=$(cat $cpu_fan_sensor_file)
            data="$data|FC$value"
        fi

        # Fan GPU
        if [ $gpu_fan_sensor_file ]; then
            value=$(cat $gpu_fan_sensor_file)
            data="$data|FG$value"
        fi

        # Fan PCB
        if [ $pcb_fan_sensor_file ]; then
            value=$(cat $pcb_fan_sensor_file)
            data="$data|FP$value"
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