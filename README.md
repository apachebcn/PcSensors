# PcSensors

Codificado por Pedro Reina Rojas (apachebcn@gmail.com)

El montaje consta de 2 partes.
- Arduino
  - En la carpeta 'arduino', código en lenguaje "processing" para cualquier arduino que disponga de comunicación Serial y un display i2c de 16x4. (opcionalmente se pueden usar 3 sondas digitales Dallas ds18b20)
- Linux
  - En la carpeta 'linux_script' código en bash scripting, dispone de 2 ficheros:
     -  `list_sensors.sh`: Lista todos los sensores de temperaturas de la placa, cpu, gpu, etc.. y la lista de todos los ventiladores detectados. (de los datos extraidos aquí serán usados para updatar el `fichero config.txt`)
     -  `run_pc_sensors.sh`: Ejecuta en bucle la lectura de sensores y envío al arduino.

# Configuración

## Seleccionamos los sensores que queremos usar
Ejecutamos 'sensors' para ver si linux nos está listando todos los sensores que queremos usar. (si no aparecen, leemos la sección "sensors no está listando todos los sensores")<br>
La ejecución de sensors solo nos sirve para ver si todos nuestros sensores están siendo detectados, pero no nos sirve como referencia en la configuración.<br>
Ejecutamos 'list_sensors.sh' para escoger los nombres de los dispositivos para realizar la configuración.<br>
Un ejemplo de ello:<br>
<pre>
--- LISTA DE SENSORES ---
Formato: ETIQUETA_SENSOR: CONTROLADOR_TEMPERATURA [temp] >>> CONTROLADOR_VENTILADOR [rpm]
AUXTIN1: /sys/devices/platform/nct6775.656/hwmon/hwmon6/temp4_input [temp: 39ºC]
PCH_CHIP_CPU_MAX_TEMP: /sys/devices/platform/nct6775.656/hwmon/hwmon6/temp8_input [temp: 0ºC]
SYSTIN: /sys/devices/platform/nct6775.656/hwmon/hwmon6/temp1_input [temp: 39ºC] >>> /sys/devices/platform/nct6775.656/hwmon/hwmon6/fan1_input [rpm: 872]
AUXTIN2: /sys/devices/platform/nct6775.656/hwmon/hwmon6/temp5_input [temp: 30ºC] >>> /sys/devices/platform/nct6775.656/hwmon/hwmon6/fan5_input [rpm: 0]
PCH_CHIP_TEMP: /sys/devices/platform/nct6775.656/hwmon/hwmon6/temp9_input [temp: 0ºC]
CPUTIN: /sys/devices/platform/nct6775.656/hwmon/hwmon6/temp2_input [temp: 38ºC] >>> /sys/devices/platform/nct6775.656/hwmon/hwmon6/fan2_input [rpm: 539]
AUXTIN3: /sys/devices/platform/nct6775.656/hwmon/hwmon6/temp6_input [temp: 73ºC]
AUXTIN0: /sys/devices/platform/nct6775.656/hwmon/hwmon6/temp3_input [temp: 66ºC]
PCH_CPU_TEMP: /sys/devices/platform/nct6775.656/hwmon/hwmon6/temp10_input [temp: 0ºC]
PECI Agent 0 Calibration: /sys/devices/platform/nct6775.656/hwmon/hwmon6/temp7_input [temp: 38ºC] >>> /sys/devices/platform/nct6775.656/hwmon/hwmon6/fan7_input [rpm: 0]
edge: /sys/devices/pci0000:00/0000:00:03.1/0000:0a:00.0/hwmon/hwmon5/temp1_input [temp: 43ºC] >>> /sys/devices/pci0000:00/0000:00:03.1/0000:0a:00.0/hwmon/hwmon5/fan1_input [rpm: 1166]
Tccd2: /sys/devices/pci0000:00/0000:00:18.3/hwmon/hwmon2/temp4_input [temp: 39ºC]
Tctl: /sys/devices/pci0000:00/0000:00:18.3/hwmon/hwmon2/temp1_input [temp: 40ºC]
Tdie: /sys/devices/pci0000:00/0000:00:18.3/hwmon/hwmon2/temp2_input [temp: 40ºC]
Tccd1: /sys/devices/pci0000:00/0000:00:18.3/hwmon/hwmon2/temp3_input [temp: 40ºC]
Composite: /sys/devices/pci0000:00/0000:00:01.2/0000:02:00.0/0000:03:01.0/0000:04:00.0/hwmon/hwmon1/temp1_input [temp: 49ºC]
Composite: /sys/devices/pci0000:00/0000:00:01.1/0000:01:00.0/hwmon/hwmon0/temp1_input [temp: 44ºC]

--- LISTA DE TODOS LOS VENTILADORES ---
/sys/devices/platform/nct6775.656/hwmon/hwmon6/fan7_input: 0RPM
/sys/devices/platform/nct6775.656/hwmon/hwmon6/fan1_input: 872RPM
/sys/devices/platform/nct6775.656/hwmon/hwmon6/fan5_input: 0RPM
/sys/devices/platform/nct6775.656/hwmon/hwmon6/fan2_input: 539RPM
/sys/devices/pci0000:00/0000:00:03.1/0000:0a:00.0/hwmon/hwmon5/fan1_input: 1169RPM
</pre>

Escogemos las etiquetas de los sensores que queremos usar, y las guardamos en el fichero `config.txt`<br>
Para los ventiladores, usamos también la etiqueta del sensor.<br>
<br>
*Nota:*<br>
*Nunca debemos usar el nombre real de un dispositivo dentro del script, porque estos nombres en muchas ocasiones cambian en algunos reinicios o actualización del sistema*<br>
<br>
<br>
## Prueba de datos
Ejecutamos el script `run_pc_sensors.sh --force`.<br>
Esto ejecutará el script sin buscar la conexión del arduino, y veremos algo como esto: (simulación de envío)<br>
<pre>
Arduino no encontrado, los datos de envio serían -> data: |TP39|TC38|TG41|FP854|FC537|FG947
</pre>
**TP:** Temperatura Placa base<br>
**TC:** Temperatura Cpu<br>
**TG:** Temperatura Gpu<br>
**FP:** Ventilador Placabase<br>
**FC:** Ventilador Cpu<br>
**FG:** Ventilador Gpu<br>
<br>
# Ejecución
Arrancamos el arduino, y lo conectamos a cualquier un puerto USB del ordenador.<br>
Ejecutamos `run_pc_sensors.sh --force`.<br>
Si todo va bien, el arduino nos mostrará todos los datos por pantalla. (El intervalo de envío lo define el fichero `config.txt`)<br>
La pantalla del arduino está programada para que se apague a los 10 segundos de no recibir datos.<br>
Si queremos el montaje permanente, y que se ejecute todo al encender el pc, pondremos como script de inicio el fichero `run_pc_sensors.sh`<br>

# Problemas conocidos
## sensors no está listando todos los sensores.
Probaremos a arrancar el grub con `acpi_enforce_resources=lax`, y ejecutar el `sensors-detect`<br>
Si conseguimos visualizar los sensores con este parámetro, editaremos el fichero `/etc/default/grub, y insertamos el parametro dentro de GRUB_CMDLINE_LINUX_DEFAULT, ejemplo:<br>
**GRUB_CMDLINE_LINUX_DEFAULT**="quiet apparmor=1 security=apparmor udev.log_priority=3 **acpi_enforce_resources=lax**"<br>
<br>