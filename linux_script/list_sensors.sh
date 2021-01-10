echo "list_sensors:"
sensors_labels=$(find /sys/devices/ -name temp*label)
for sensor_label_file in $sensors_labels
do
    label=$(cat $sensor_label_file)
    sensor_temp_file=$(echo "$sensor_label_file" | sed "s/label/input/g")
    value=$(cat $sensor_temp_file)
    value=$(($value/1000))
    echo "$label: $sensor_temp_file => $valueºC"
done

echo ""
echo "list_fans:"
sensors_labels=$(find /sys/devices/ -name fan*input)
for sensor_label_file in $sensors_labels
do
    rpm="RPM"
    label=$(cat $sensor_label_file)
    echo "$sensor_label_file: $label$rpm"
done
