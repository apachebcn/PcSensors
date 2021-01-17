test_sensor() {
    sensor_temp_file=$1
    test_sensor_result=0
    value=$(cat $sensor_temp_file 2> /dev/null)
    test_number $value
    if [ $test_result == 1 ]; then
        test_sensor_result=1
    fi
}

test_number() {
    test_result=0
    check=`echo "$1" | grep -E ^\-?[0-9]+$`
    if [ $check ]; then
        test_result=1
    fi
}

echo "--- LISTA DE SENSORES ---"
echo "Formato: ETIQUETA_SENSOR: CONTROLADOR_TEMPERATURA [temp] >>> CONTROLADOR_VENTILADOR [rpm]"
sensors_labels=$(find /sys/devices/ -name temp*label)
for sensor_label_file in $sensors_labels
do
    label=$(cat $sensor_label_file)
    sensor_temp_file=$(echo "$sensor_label_file" | sed "s/label/input/g")
    test_sensor $sensor_temp_file
    if [ $test_sensor_result == 1 ]; then    
        msg="$label: $sensor_temp_file"
        value=$(cat $sensor_temp_file)
        if [ $value ]; then
            value=$(($value/1000))
            msg="$msg [temp: $valueºC]"
        fi
        sensor_fan_file=$(echo "$sensor_temp_file" | sed "s/temp/fan/g")
        value=$(cat $sensor_fan_file 2> /dev/null)
        test_sensor $sensor_fan_file
        if [ $test_sensor_result == 1 ]; then
            msg="$msg >>> $sensor_fan_file"
            value=$(cat $sensor_fan_file)
            if [ $value ]; then
                msg="$msg [rpm: $value]"
            fi
        fi
        echo $msg
    fi
done

echo ""
echo "--- LISTA DE TODOS LOS VENTILADORES ---"
sensors_labels=$(find /sys/devices/ -name fan*input)
for sensor_label_file in $sensors_labels
do
    rpm="RPM"
    label=$(cat $sensor_label_file)
    echo "$sensor_label_file: $label$rpm"
done

