#!/bin/bash

pid=$(sudo ps -A| grep run_pc_sensors)
if [ $pid ]; then
    echo "El proceso ya está activo"
    exit
fi

this_dir=$(dirname $(readlink -f $0))
cd $this_dir

forzar_envio=0
if [ $1 == "--forzar" ]; then
    forzar_envio=1
fi

source "config.txt"

sensor_pcb_temp_file=''
sensor_pcb_fan_file=''
sensor_cpu_temp_file=''
sensor_cpu_fan_file=''
sensor_gpu_temp_file=''
sensor_gpu_fan_file=''

test_number() {
    test_result=0
    check=`echo "$1" | grep -E ^\-?[0-9]+$`
    if [ $check ]; then
        test_result=1
    fi
}

test_sensor() {
    type=$1
    sensor_label_file=$2
    sensor_temp_file=$3
    test_sensor_result=0
    label_value=$(sudo cat $sensor_label_file)
    echo "LABEL FOR $type: $label_value"
    if [ $label_value ]; then
        value=$(cat $sensor_temp_file 2> /dev/null)
        test_number $value
        if [ $test_result == 1 ]; then
            echo "TEMP FOUND IN: $sensor_temp_file => Value=$value"
            test_sensor_result=1
        else
            echo "TEMP NOT FOUND IN $sensor_temp_file"
        fi
    fi
}

# SENSORES DE TEMPERATURAS
sensors_labels=$(find /sys/devices/ -name temp*label)
for sensor_label_file in $sensors_labels
do
    sensor_temp_file=$(echo "$sensor_label_file" | sed "s/label/input/g")
    test_sensor TEMP $sensor_label_file $sensor_temp_file
    if [ $test_sensor_result == 1 ]; then
        if [ $label_value == $pcb_temp_label ]; then
            echo "*** MAPEADO PARA PCB ***"
            sensor_pcb_temp_file=$sensor_temp_file
        fi
        if [ $label_value == $cpu_temp_label ]; then
            echo "*** MAPEADO PARA CPU ***"
            sensor_cpu_temp_file=$sensor_temp_file
        fi
        if [ $label_value == $gpu_temp_label ]; then
            echo "*** MAPEADO PARA GPU ***"
            sensor_gpu_temp_file=$sensor_temp_file
        fi
    fi
    echo ""
done

# SENSORES DE VENTILADORES 
sensors_labels=$(find /sys/devices/ -name temp*label)
for sensor_label_file in $sensors_labels
do
    sensor_temp_file=$(echo "$sensor_label_file" | sed "s/label/input/g")
    sensor_temp_file=$(echo "$sensor_temp_file" | sed "s/temp/fan/g")
    test_sensor FAN $sensor_label_file $sensor_temp_file
    if [ $test_sensor_result == 1 ]; then
        if [ $label_value == $pcb_fan_label ]; then
            echo "*** MAPEADO PARA PCB ***"
            sensor_pcb_fan_file=$sensor_temp_file
        fi
        if [ $label_value == $cpu_fan_label ]; then
            echo "*** MAPEADO PARA CPU ***"
            sensor_cpu_fan_file=$sensor_temp_file
        fi
        if [ $label_value == $gpu_fan_label ]; then
            echo "*** MAPEADO PARA GPU ***"
            sensor_gpu_fan_file=$sensor_temp_file
        fi
    fi
    echo ""
done


while true; 
do

    data=""
    arduino_dev=""
    arduino_devs="/dev/ttyUSB0 /dev/ttyUSB1 /dev/ttyUSB2 /dev/ttyUSB3 "
    for name_dev in $arduino_devs:
    do
        if [ -c "$name_dev" ]; then
            arduino_dev=$name_dev
            break
        fi
    done

    if [ $arduino_dev ] | [ $forzar_envio ]; then

        # Temperatura PCB
        if [ $sensor_pcb_temp_file ]; then
            value=$(cat $sensor_pcb_temp_file)
            test_number $value
            if [ $test_result == 1 ]; then
                value=$(($value/1000))
                data="$data|TP$value"
            fi
        fi

        # Temperatura CPU
        if [ $sensor_cpu_temp_file ] ; then
            value=$(cat $sensor_cpu_temp_file)
            if [ $value ]; then
                value=$(($value/1000))
            fi
            data="$data|TC$value"
        fi

        # Temperatura GPU
        if [ $sensor_gpu_temp_file ]; then
            value=$(cat $sensor_gpu_temp_file)
            if [ $value ]; then
                value=$(($value/1000))
            fi
            data="$data|TG$value"
        fi

        # Fan PCB
        if [ $sensor_pcb_fan_file ]; then
            value=$(cat $sensor_pcb_fan_file)
            data="$data|FP$value"
        fi

        # Fan CPU
        if [ $sensor_cpu_fan_file ] ; then
            value=$(cat $sensor_cpu_fan_file)
            data="$data|FC$value"
        fi

        # Fan GPU
        if [ $sensor_gpu_fan_file ]; then
            value=$(cat $sensor_gpu_fan_file)
            data="$data|FG$value"
        fi

        if [ "$data" ]; then
            if [ $arduino_dev ]; then
                sudo chmod 777 $arduino_dev
                # stty -F $arduino_dev -hupcl
                stty -F /dev/ttyUSB0 115200 cs8 -cstopb -parenb
                arduino_dev_before=$arduino_dev
                data="$data|"
                echo "Enviando a $arduino_dev -> data: $data"
                echo $data > $arduino_dev
            else
                echo "Arduino no encontrado, los datos de envio serían -> data: $data"
            fi
        fi

    else

        echo "Arduino Serial DEV: not found"

    fi

    sleep $sleep_seconds

done

