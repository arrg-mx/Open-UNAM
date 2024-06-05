clc; % Limpia la ventana de comandos.
clear all; % Limpia todas las variables del espacio de trabajo.

lib_name = ''; % Inicializa la variable lib_name como una cadena vacía.

% Dependiendo del sistema operativo, se asigna el nombre de la biblioteca correspondiente a lib_name.
if strcmp(computer, 'PCWIN')
  lib_name = 'dxl_x86_c';
elseif strcmp(computer, 'PCWIN64')
  lib_name = 'dxl_x64_c';
elseif strcmp(computer, 'GLNX86')
  lib_name = 'libdxl_x86_c';
elseif strcmp(computer, 'GLNXA64')
  lib_name = 'libdxl_x64_c';
elseif strcmp(computer, 'MACI64')
  lib_name = 'libdxl_mac_c';
end

% Carga las bibliotecas si no están ya cargadas.
if ~libisloaded(lib_name)
    [notfound, warnings] = loadlibrary(lib_name, 'dynamixel_sdk.h', 'addheader', 'port_handler.h', 'addheader', 'packet_handler.h');
end

% Versión del protocolo
PROTOCOL_VERSION = 2.0; % Establece la versión del protocolo a usar en el Dynamixel.

% Configuración predeterminada
BAUDRATE = 57600; % Establece la tasa de baudios.
DEVICENAME = 'COM1'; % Establece el nombre del dispositivo (puerto COM).

MAX_ID = 252; % Valor máximo de ID para los dispositivos.
COMM_SUCCESS = 0; % Valor que indica éxito en la comunicación.
COMM_TX_FAIL = -1001; % Valor que indica fallo en la transmisión de comunicación.

% IDs de los motores
DXL1_ID = 1; % ID del primer motor
DXL2_ID = 2; % ID del segundo motor

% Inicializa las estructuras PortHandler.
% Establece la ruta del puerto.
% Obtiene métodos y miembros de PortHandlerLinux o PortHandlerWindows.
port_num = portHandler(DEVICENAME);

% Inicializa las estructuras PacketHandler.
packetHandler();

dxl_comm_result = COMM_TX_FAIL; % Inicializa la variable de resultado de comunicación con fallo.

% Abre el puerto.
if (openPort(port_num))
    fprintf('Succeeded to open the port!\n'); % Muestra un mensaje si el puerto se abre con éxito.
else
    unloadlibrary(lib_name); % Descarga la biblioteca si no se puede abrir el puerto.
    fprintf('Failed to open the port!\n'); % Muestra un mensaje si falla al abrir el puerto.
    input('Press any key to terminate...\n'); % Espera una entrada del usuario para terminar.
    return;
end

% Establece la tasa de baudios del puerto.
if (setBaudRate(port_num, BAUDRATE))
    fprintf('Succeeded to change the baudrate!\n'); % Muestra un mensaje si se cambia la tasa de baudios con éxito.
else
    unloadlibrary(lib_name); % Descarga la biblioteca si no se puede cambiar la tasa de baudios.
    fprintf('Failed to change the baudrate!\n'); % Muestra un mensaje si falla al cambiar la tasa de baudios.
    input('Press any key to terminate...\n'); % Espera una entrada del usuario para terminar.
    return;
end

% Intenta hacer un ping a los dos motores.
for dxl_id = [DXL1_ID, DXL2_ID]
    ping(port_num, PROTOCOL_VERSION, dxl_id);
    dxl_comm_result = getLastTxRxResult(port_num, PROTOCOL_VERSION);
    if dxl_comm_result ~= COMM_SUCCESS
        fprintf('Motor ID %d: %s\n', dxl_id, getTxRxResult(PROTOCOL_VERSION, dxl_comm_result));
    else
        fprintf('Motor ID %d ping succeeded.\n', dxl_id);
    end
end

% Intenta hacer un ping de difusión al Dynamixel.
broadcastPing(port_num, PROTOCOL_VERSION);
dxl_comm_result = getLastTxRxResult(port_num, PROTOCOL_VERSION);
if dxl_comm_result ~= COMM_SUCCESS
    fprintf('%s\n', getTxRxResult(PROTOCOL_VERSION, dxl_comm_result)); % Muestra el resultado del ping si falla.
end

fprintf('Detected Dynamixel : \n'); % Muestra un mensaje indicando que se han detectado Dynamixel.
for id = 0 : MAX_ID
  if getBroadcastPingResult(port_num, PROTOCOL_VERSION, id)
    fprintf('[ID:%03d]\n', id); % Muestra el ID de los Dynamixel detectados.
  end
end

% Cierra el puerto.
closePort(port_num);

% Descarga la biblioteca.
unloadlibrary(lib_name);

close all; % Cierra todas las figuras.
clear all; % Limpia todas las variables del espacio de trabajo.
He añadido las siguientes líneas clave para trabajar con dos motores:

IDs de los motores:

matlab
Copiar código
DXL1_ID = 1; % ID del primer motor
DXL2_ID = 2; % ID del segundo motor