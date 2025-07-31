#!/bin/bash
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}El siguiente script, va a realizar los siguientes cambios:

    - Actualizo el sistema y paquetes actuales
    - Instalación de paquetes de ciberseguridad (opcional).
    - Configuro paquete sensors.
    - Configuro el hostname (opcional).
    - Configuro en archivo de ~/.bashrc
    - Agrego mis propios comandos [scanvuln y pingtime].
    - Configuro sistema de logs.
    - Configuro Idioma.
    - Configuro .vimrc.
    - Configuro dibujo con ASCII y mensaje de monitorización de bienvenida en /etc/bash.bashrc
    - Configuro SNMP.
    - Configuro NTP (elección de configuración según necesidades).
    - Habilito sar.
    - Modifico las interfaces de red y cambio nombre por eth0.
    - Especifíco editor de texto vim por defecto.
    - Deshabilito IPv6.
    - Genero un archivo SWAP de memoría a medida (opcional).
    ${NC}"

echo -e "¿Quieres continuar con la instalación? (s/n):"
read -r respuesta

if [[ ! "$respuesta" =~ ^[Ss]$ ]]; then
    echo "Instalación cancelada."
    exit 0
fi

# Si responde sí, el script sigue ejecutándose...

# Instalación de paquetes iniciales
echo "Instalando paquetes..."
apt-get update && apt-get upgrade -y

## Paquetes de ciberseguridad:
# Preguntar al usuario si quiere instalar paquetes de ciberseguridad
# -------------------------------------------------------------------
echo -e "${YELLOW}Paquetes de red-hat: ${NC}"
read -p "¿Deseas instalar paquetes de ciberseguridad como sqlmap john hydra...? (s/n): " respuestaCyber

if [[ "$respuestaCyber" == "s" || "$respuestaCyber" == "S" ]]; then
    apt install -y nmap john hydra sqlmap whatweb tshark exiftool
    echo "Paquetes de ciberseguridad instalados:"
    echo "nmap, john, hydra, sqlmap, whatweb, tshark, exiftool."
else
    echo "Continuando con la instalación sin paquetes de instalación."
fi
# ------------------------------------------------------------------- 

# instalaciones general 
apt-get install -y \
    nmap tcpdump\
    iputils-ping lm-sensors iproute2 sudo vim net-tools curl btop iftop lsof \
    lsb-release wget sysstat snmp snmpd tcpdump \
    ngrep iptraf-ng mlocate tar gzip tree ca-certificates \
    screen man-db mailutils dnsutils rsyslog  

# Configuración de sensores
echo "Configurando sensores:"
sensors-detect --auto
systemctl restart lm-sensors

## modificar hostname:
# Preguntar al usuario si desea cambiar el hostname
# -------------------------------------------------------------------
echo -e "${YELLOW}Cambiar hostname: ${NC}"
read -p "¿Deseas agregar un nuevo hostname? (s/n): " respuestaHost

if [[ "$respuestaHost" =~ ^[sS]$ ]]; then
    read -p "Introduce el nuevo hostname (isaac.laboratory-00): " new_hostname

    # Actualizar /etc/hostname
    echo "$new_hostname" | sudo tee /etc/hostname > /dev/null

    # Actualizar /etc/hosts
    sudo tee /etc/hosts > /dev/null <<EOF
127.0.0.1   localhost
127.0.1.1   $new_hostname

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
EOF

    # Actualizar hostname en tiempo real y en systemd
    sudo hostnamectl set-hostname "$new_hostname"

    echo "El hostname se ha cambiado a: $new_hostname"
else
    echo "Continuando con la instalación sin cambiar el hostname."
fi

# -------------------------------------------------------------------

## Configuro bashrc
# Preguntar al usuario el estilo
while true; do
    echo -e "${YELLOW}Selecciona el estilo: ${NC}"
    echo "1) Estilo cyberpunk                        # diferencial y profesional (rosa y verde)"
    echo "2) Estilo personal                         # alternativo e informal (gris y amarillo)"    
    read -rp "Opción (1 o 2): " opcion

    case "$opcion" in
        1)
            echo "Has elegido el estilo cyberpunk"
# Configuro .bashrc (estilo cyberpunk)
# **************************************
cat <<EOF > ~/.bashrc
## alias del servidor
alias ls='ls -ha --color=auto --group-directories-first'
alias la='ls $LS_OPTION -lhai --group-directories-first'
alias _liberarespacioram='sudo sync; echo 1 | sudo tee /proc/sys/vm/drop_caches | echo "petición realizada correctamente." && echo "" && free -h'
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias grep='grep --color=auto'
alias df='df --exclude-type=tmpfs'
alias lsblk='lsblk -e7 -o NAME,MAJ:MIN,RM,SIZE,RO,TYPE,MOUNTPOINT,FSTYPE,MODEL,MODE,STATE,VENDOR,UUID'
alias find='find ./ -name'
alias df='df -hTi'

## Cambiar diseño del prompt (estilo cyberpunk)
# -------------------------------------------------------------------
# color (estilo cyberpunk)
# PS1='\[\e[0;90m\]\u箱\e[38;5;196m[\H]\e[0m \w\[\e[0;37m\] $: '
PS1='\[\e[0;90m\]\u箱\e[38;5;196m[\H]\e[38;5;196m\e[1;32m \w\e[0;37m $: '

## cambiar colores para ls (estilo cyberpunk)
# -------------------------------------------------------------------
# opcion (cyverpunk)
export LS_COLORS="di=1;32:fi=0;37:ln=1;35:so=0;38;5;208:pi=0;34:bd=0;33:cd=0;33:or=0;31:mi=0;31:ex=1;31"
#     di — directorios en verde brillante (bold green).
#     fi — archivos normales en gris claro (normal white/gray).
#     ln — enlaces simbólicos en magenta brillante (bold magenta).
#     so — sockets en naranja quemado (color 208 en la paleta 256).
#     pi — tuberías (pipes) en azul normal (normal blue).
#     bd — dispositivos de bloque en amarillo normal.
#     cd — dispositivos de carácter en amarillo normal.
#     or — archivos rotos en rojo normal (normal red).
#     mi — archivos inexistentes en rojo normal (normal red).
#     ex — ejecutables en rojo brillante (bold red).
EOF

# Configuro vimrc (estilo cyberpunk)
# -------------------------------------------------------------------
cat <<EOF > ~/.vimrc
" configuración archivo .vimrc
" Configuración del archivo .vimrc
set number                                              " Muestra los números de línea en el margen izquierdo.
set cursorline                                          " Resalta la línea donde se encuentra el cursor.
set scrolloff=8                                         " Mantiene 8 líneas visibles por encima y por debajo del cursor al desplazarse.
set incsearch                                           " Realiza la búsqueda de manera incremental, mostrando resultados a medida que se escribe.
set hlsearch                                            " Resalta todas las coincidencias de la búsqueda.
set ignorecase                                          " Ignora mayúsculas y minúsculas en las búsquedas.
set smartcase                                           " Si se usa una mayúscula en la búsqueda, se activa la distinción entre mayúsculas y minúsculas.
set expandtab                                           " Convierte las tabulaciones en espacios.
set tabstop=4                                           " Establece el ancho de una tabulación a 4 espacios.
set shiftwidth=4                                        " Establece el ancho de sangría a 4 espacios.
set wildmenu                                            " Mejora la interfaz de autocompletado en la línea de comandos.
set foldmethod=indent                                   " Usa la indentación para determinar los pliegues de código.
set foldlevel=99                                        " Establece el nivel de pliegue inicial a 99, mostrando todo el código.
syntax on                                               " Activa el resaltado de sintaxis.
set background=dark                                     " Establece el fondo oscuro para el resaltado de sintaxis.
colorscheme industry                                    " Aplica el esquema de colores 'industry'.
highlight Comment ctermfg=Green guifg=#00FF00           " Resalta los comentarios en verde.
highlight LineNr ctermfg=Magenta                        " Resalta los números de línea en magenta.
highlight CursorLineNr ctermfg=DarkMagenta              " Resalta el número de línea del cursor en magenta oscuro.
highlight Normal ctermfg=White ctermbg=DarkGray         " Establece el color normal del texto a blanco sobre fondo gris oscuro.
highlight Keyword ctermfg=LightGray                     " Resalta las palabras clave en gris claro.
highlight Function ctermfg=Yellow                       " Resalta las funciones en amarillo.
highlight Type ctermfg=Magenta                          " Resalta los tipos de datos en magenta.
highlight Constant ctermfg=Magenta                      " Resalta las constantes en magenta.
highlight Identifier ctermfg=White                      " Resalta los identificadores en blanco.
highlight Statement ctermfg=Yellow                      " Resalta las declaraciones en amarillo.
highlight Error ctermfg=White ctermbg=Red               " Resalta los errores en blanco sobre fondo rojo.
highlight Search ctermfg=Black ctermbg=Yellow           " Resalta la búsqueda en negro sobre fondo amarillo.
highlight Visual ctermbg=Grey                           " Resalta la selección visual en gris.
highlight StatusLine ctermfg=Blue ctermbg=White         " Establece el color de la línea de estado en azul sobre fondo blanco.
highlight StatusLineNC ctermfg=Blue ctermbg=DarkGray    " Establece el color de la línea de estado no activa en azul sobre fondo gris oscuro.
highlight Special ctermfg=Blue                          " Resalta los elementos especiales en azul.
highlight PreProc ctermfg=Grey                          " Resalta las preprocesadores en gris.
highlight Todo ctermfg=Black ctermbg=Yellow             " Resalta las tareas pendientes en negro sobre fondo amarillo.
highlight Underlined ctermfg=White                      " Resalta el texto subrayado en blanco.
highlight Pmenu ctermbg=DarkGray                        " Establece el fondo del menú de completado en gris oscuro.
highlight PmenuSel ctermbg=Blue ctermfg=White           " Establece el fondo del menú de selección en azul y el texto en blanco.
highlight DiffAdd ctermbg=Green                         " Resalta las adiciones en el diff en verde.
highlight DiffChange ctermbg=Yellow                     " Resalta los cambios en el diff en amarillo.
highlight DiffDelete ctermbg=Red                        " Resalta las eliminaciones en el diff en rojo.
highlight Folded ctermfg=White ctermbg=DarkBlue         " Resalta los pliegues en blanco sobre fondo azul oscuro.
set laststatus=2                                        " Siempre muestra la línea de estado.
set noerrorbells                                        " Desactiva los sonidos de error.
set history=1000                                        " Establece el tamaño del historial de comandos a 1000 entradas.
set clipboard=unnamedplus                               " Usa el portapapeles del sistema para copiar y pegar.
EOF
        
            break
            ;;
        2)
            echo "Has elegido el estilo técnica/grisácea"
# Configuro .bashrc (técnica/grisácea)
# -------------------------------------------------------------------
cat <<EOF > ~/.bashrc
## alias del servidor
alias ls='ls -ha --color=auto --group-directories-first'
alias la='ls $LS_OPTION -lhai --group-directories-first'
alias _liberarespacioram='sudo sync; echo 1 | sudo tee /proc/sys/vm/drop_caches | echo "petición realizada correctamente." && echo "" && free -h'
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias grep='grep --color=auto'
alias df='df --exclude-type=tmpfs'
alias lsblk='lsblk -e7 -o NAME,MAJ:MIN,RM,SIZE,RO,TYPE,MOUNTPOINT,FSTYPE,MODEL,MODE,STATE,VENDOR,UUID'
alias find='find ./ -name'
alias df='df -hTi'

## Cambiar diseño del prompt (estilo cyberpunk)
# -------------------------------------------------------------------
# color (técnica/grisácea)
PS1='\[\e[0;90m\]\u ୧༼ಠ益ಠ╭∩╮༽\[\e[0;33m\][\H]\[\e[0m\] \[\e[1;37;48;5;1m\] \w \[\e[0m\]$: '

# Opción técnica/grisácea
export LS_COLORS="di=1;30:fi=0;37:ln=1;33:so=1;35:pi=1;33:bd=1;30:cd=1;30:or=1;31:mi=1;31:ex=1;31"
#     di — directorios en gris oscuro técnico (bold black)
#     fi — archivos normales en gris medio
#     ln — enlaces simbólicos en amarillo (bold yellow)
#     so — sockets en púrpura oscuro (bold magenta)
#     pi — pipes (tuberías) en amarillo (bold yellow)
#     bd — dispositivos de bloque en gris carbón (bold black)
#     cd — dispositivos de carácter en gris plomo (bold black)
#     or — archivos rotos en rojo sangre oscuro (bold red)
#     mi — archivos inexistentes en rojo sangre oscuro (bold red)
#     ex — ejecutables en rojo brillante (bold red)
EOF

# Configuro vimrc (técnica/grisácea)
# -------------------------------------------------------------------
cat <<EOF > ~/.vimrc
set number                                    " Muestra números de línea
set cursorline                                " Resalta línea actual
set scrolloff=5                               " Mantiene 5 líneas arriba/abajo
set incsearch                                 " Búsqueda incremental
set hlsearch                                  " Resalta resultados búsqueda
set ignorecase                                " Ignora mayúsculas/minúsculas
set smartcase                                 " Caso sensible si hay mayúsculas
set expandtab                                 " Usa espacios en lugar de tabs
set tabstop=4                                 " Número de espacios que representa un tabulador
set shiftwidth=4                              " Número de espacios para indentación automática
set wildmenu                                  " Mejor autocompletado en la línea de comandos
syntax on                                     " Activa el resaltado de sintaxis
set background=dark                           " Tema oscuro para el fondo

" Colores personalizados básicos para consola
highlight Normal ctermfg=248 ctermbg=236      " Texto gris medio / fondo gris carbón
highlight LineNr ctermfg=240                  " Números gris oscuro
highlight CursorLine ctermbg=238              " Fondo línea cursor gris plomo
highlight Keyword ctermfg=61                  " Palabras clave azul cobalto apagado
highlight Function ctermfg=94                 " Funciones púrpura oscuro
highlight Statement ctermfg=124               " Sentencias rojo sangre oscuro
highlight Visual ctermbg=240                  " Selección gris oscuro
highlight Comment ctermfg=3                   " Comentarios en amarillo

set laststatus=2                              " Siempre mostrar línea de estado
set noerrorbells                              " Sin sonidos de error
set clipboard=unnamedplus                     " Usa portapapeles del sistema
EOF

            break
            ;;
            
        *)
            echo "Opción de diseño no válida. Intenta de nuevo."
            ;;
    esac
done

# Agrego mis propios comandos:

# comando : scanvuln
# escanea rapidamente las vulnerabilidades de la IP asignada
# -------------------------------------------------------------------
echo -e "${YELLOW}Mis propios comandos: ${NC}"
echo "¿Quieres instalar mi comando scanvuln? (s/n):"
read -r resscanvuln

if [[ "$resscanvuln" =~ ^[Ss]$ ]]; then
cat <<'EOF' | sudo tee /usr/bin/scanvuln > /dev/null
#!/bin/bash

# Comprobación de Nmap
if ! command -v nmap &>/dev/null; then
  read -rp "[!] Nmap no está instalado. ¿Quieres instalarlo? (s/n): " respuesta
  if [[ "$respuesta" =~ ^[Ss]$ ]]; then
    echo "[*] Instalando nmap..."
    sudo apt-get update && sudo apt-get install -y nmap
    if [[ $? -ne 0 ]]; then
      echo "[!] Error al instalar nmap."
      exit 1
    fi
  else
    echo "[!] Nmap es necesario para realizar el escaneo."
    exit 1
  fi
fi

# Verificar parámetro
if [[ -z "$1" ]]; then
  echo "================================================================================"
  echo "Uso: scanvuln <IP>"        # escaneo de servicios y vulnerabilidades usando Nmap        
  echo " "
  exit 1
fi

ip="$1"
echo "[*] Escaneando la IP $ip con Nmap + scripts de vulnerabilidades..."
sudo nmap -sV --script vuln "$ip"
EOF

chmod 770 /usr/bin/scanvuln
echo "✅ Comando scanvuln habilitado"
fi

# - 

# comando : pingtime
# hace un ping registrando la fecha y tiempo exacto y de manera opcional guarda cada peticion en la ruta /var/log/ping/
# -------------------------------------------------------------------
echo "¿Quieres instalar mi comando pingtime? (s/n):"
read -r respingtime

if [[ "$respingtime" =~ ^[Ss]$ ]]; then
cat <<'EOF' | sudo tee /usr/bin/pingtime > /dev/null
#!/bin/bash
log_dir="/var/log/ping"

# Si el primer argumento es -r, cambiar al directorio de logs
if [[ "$1" == "-r" ]]; then
  cd "$log_dir" 2>/dev/null || { echo "No se pudo acceder a $log_dir posiblemente porque no existe ningún log."; exit 1; }
  echo "Ubicación actual: $(pwd)"
  ls -l --color=auto
  exit 0
fi

if [[ -z "$1" ]]; then
  echo "================================================================================"
  echo "Uso: pingtime <IP|host>                                     # monitorizar ping"
  echo "Uso: pingtime -r                                            # ver logs"
  echo " "
  exit 1
fi

host="$1"
read -rp "¿Quieres guardar el registro? (s/n): " respuesta

timestamp=$(date +"%Y%m%d_%H%M%S")
log_dir="/var/log/ping"
log_file="$log_dir/ping_${host}_$timestamp.log"
ping_cmd="ping -i 1"

if [[ "$respuesta" =~ ^[Ss]$ ]]; then
  mkdir -p "$log_dir"

  {
    echo -e "================================================================================\n"
    echo "Información inicial para $host"
    echo "Fecha: $(date)"
    ip neigh show "$host" 2>/dev/null || echo "No se pudo obtener información ARP"
    nslookup "$host" 2>/dev/null || echo "No se pudo obtener información DNS"
    echo -e "================================================================================\n"
  } >> "$log_file"

  read -rp "¿Registrar todos los logs (a) o solo cambios de estado (c)? [a/c]: " modo

  last_state=""
  $ping_cmd "$host" | while IFS= read -r line; do
    date_str="[$(date '+%Y-%m-%d %H:%M:%S')]"

    if [[ "$modo" =~ ^[Aa]$ ]]; then
      echo "$date_str $line" | tee -a "$log_file"
    else
      if echo "$line" | grep -q "bytes from"; then
        current_state="up"
      else
        current_state="down"
      fi

      if [[ "$current_state" != "$last_state" ]]; then
        echo "$date_str $line" | tee -a "$log_file"
        last_state="$current_state"
      fi
    fi
  done

  echo "Registro guardado en $log_file"

else
  $ping_cmd "$host" | while IFS= read -r line; do
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $line"
  done
fi
EOF
    
    chmod 770 /usr/bin/pingtime
    echo "✅ Comando pingtime habilitado"
fi

# - 

# comando : ayuda
# muestra un texto de buenas prácticas con comandos
# -------------------------------------------------------------------
echo "¿Quieres instalar mi comando ayuda? (s/n):"
read -r resayuda

if [[ "$resayuda" =~ ^[Ss]$ ]]; then
    cat <<'EOF' | sudo tee /usr/bin/ayuda > /dev/null
#!/bin/bash
YELLOW="\e[33m"
RESET="\e[0m"

printf "%b\n" "\
${YELLOW}chattr +i /ruta/origen/documento.txt${RESET}                                           - Establece atributo inmutable (impide modificar/borrar el archivo, -i para revertirlo).
${YELLOW}snmpwalk -v2c -c <COMMUNITY-SNMP> -Oneq <IP-SNMP> .1 > dc1-kvm1.snmpwalk${RESET}       - Exporta árbol SNMP completo al archivo dc1-kvm1.snmpwalk.
${YELLOW}rsync -avzc --progress /ruta/origen/ usuario@host:/ruta/destino/${RESET}               - Copia eficiente de Linux a Linux, mantiene permisos y metadatos (usuarios, hard-links...).
${YELLOW}scp -r /ruta/origen/ usuario@host:/ruta/destino/${RESET}                               - Copia directa pero más lenta, ideal usando Windows, si Windows no tiene rsync.
${YELLOW}tar -czvf prueba.tar.gz comprimir/${RESET}                                             - Comprime carpeta con gzip.
${YELLOW}tar -xzvf prueba.tar.gz${RESET}                                                        - Extrae contenido si fue comprimido con gzip.
${YELLOW}smbstatus | grep \"nombre_del_archivo.xls\"${RESET}                                      - Verifica si un archivo está abierto por Samba (lo detengo con kill -9).
${YELLOW}smbstatus -L${RESET}                                                                   - Lista todos los archivos abiertos vía Samba con usuarios y PIDs.
${YELLOW}nmap -p- --open -T5 -v -n [Ip Víctima] -oG [Nombre del archivo de guardado.]${RESET}   - nmap: escanea todos los puertos de la victima y lo guarda con -oG en el archivo índicado.
${YELLOW}curl ifconfig.es${RESET}                                                               - curl: muestra la ip pública (también existe ifconfig.me).
${YELLOW}tcpdump -i eth0 -nn host [Ip Host]${RESET}                                             - tcpdump: captura en eth0 todo el tráfico IP hacia o desde 192.168.1.1, con -nn cambia el nombre puertos y servicio por números (https por 443).
"
EOF

    chmod 770 /usr/bin/ayuda
    echo "✅ Comando ayuda habilitado"
fi


## Configuración mínima de logs
# **************************************
# Logrotate estandar para cualquier servidor (configuracion minima):
# Configura la rotación mensual, mantiene 12 meses rotados, agrega fechas a los nombres, comprime los logs antiguos, elimina archivos de dos años y permite configuraciones adicionales desde /etc/logrotate.d.
cat  <<EOF > /etc/logrotate.conf
# logrotate.conf - Elliot 2025
weekly
rotate 52          # 52 semanas = 1 año
dateext
compress
notifempty
maxage 730         # elimina logs > 730 días (2 años)
create 640 root adm
include /etc/logrotate.d
EOF
systemctl enable rsyslog
systemctl restart rsyslog

# Idioma
# **************************************
#localectl
localectl set-locale LANG=en_US.UTF-8
localectl

# Información en inicio de sesión
echo '# información inicio de sesión' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMMMMMMMMMMMMMMMMWWXKOkxddooooooddxkO0KNWWMMMMMMMMMMMMMMMMMMMMMMMMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMMMMMMMMMMMMMWX0kolc::;;;::;;;;;;;;::cloxOKNWMMMMMMMMMMMMMMMMMMMMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMMMMMMMMMMWN0dl:;:;;:;;;;;;;;;;;;;;;;;;;;:clxOXWWMMMMMMMMMMMMMMMMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMMMMMMMMWXko::;;;;;;;;;;;;;;;;;;;;;;;;;;;;:;;:cdOXWMMMMMMMMMMMMMMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMMMMMMWNOl:;;;;;;;;;;;;;;;;;;;;;;;;;;;;;:;;::;;;:lkKWMMMMMMMMMMMMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMMMMMWKd:;:;;;;;::;:;;;;;;;;;;;;;;;;;;;;;;;::;;;:;:lkXWMMMMMMMMMMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMMMMW0o:;;;;;;;;:;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;:;;;:lONMMMMMMMMMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMMMWKo:;;;::;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;cxXWMMMMMMMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMMMXd:;:;;::;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;:dXWMMMMMMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMMWOc::;:;;;;;;;;;;;;:;;;:;;;;;;;;;;;;;;;;;;;;:;;:;;;;;;:xNMMMMMMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMMNd:;;;;;;;;;;;;;;;::;;;;;:;;:;;;::;;;;;;;;;;;;;;;;;;:;:l0WMMMMMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMWKo;;;;;;;;;:;::;;;:;::;;;::cllllc::;;;;;;;;;;;;;;;;;;;:cdKNMMMMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMWKo;;;;;;;;;;;:cc:;;;;;;:looollccc::;;;;;;;;;;;;;;;;;:;:::cxXMMMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMMXo:;:;;;;;;;;::ll:;;;;cdxl::;:lol:;::;;;;;;;;;;;;;;;:cdkoccxNMMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMMNx:;;;;::;;;::;col::;:xkl::lokXNKd::;;;;;;;;;;;;;;;;:xXXxc:oKMMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMMW0l:;;;;;;;;;:;:loc:cxKx:;cOXWMMWOc;:;;;;;;;;;;;;;;;l0WNx::oKWMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMMMNkc;;::;;;;;;;::oxk0K0o:;oXWWMMNx:;;;;;;;;;;;;:;;;;l0WXd::dXMMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMMMMNkc;;::;;;:;;:;:clllol;:dXWMMW0l:;:;;;;;;;;;::::;;cONKo;:kNMMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMMMMMNkc:::;;;;;:::;;;;:c:;:oKWWMNx::;;;;;;;;;;::;:;::ckN0l;cOWMMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMMMMMMW0dc::::;;cl:;;:::::;:l0WWMXd;;;;;;;;;;;;;:;;;::ckN0l;l0WMMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMMMMMMMMN0o:;;;;col:::;::::;lKWWMXo;;;;;;;;;;;;:cl::;:cON0l;l0WMMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMMMMMMMMMWNOoc:;:lxo:;;:c:;;oKWWWKo:;:;;:;;;;;:lOkc:;;lONOc;lKWMMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMMMMMMMMMMMWN0occ:dOxl:ll:::xNWWWOl:;;;;:;;;:::dXKo:;;:dOdc:dXMMMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMMMMMMMMMMMMMNkodlcxXX00d:;:kNWWWOl:;;:;;:;;::dKWNkc;::ccccdKWMMMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMMMMMMMMMMMMMWNOoc:oXWWNk:;:oOKK0xl:::::;;;::dKNXN0l;cxkxx0NWMMMMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMMMMMMMMMMMMMMMNkc:xNMMWKd::::ccccoxO0Oxl::;:xKOkKOl:lKWWMMMMMMMMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMMMMMMMMMMMMMMMNx:l0WMMMWN0xddddk0NWMWNxlc::::cc:cl::lKMMMMMMMMMMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMMMMMMMMMMMMMMW0lcONMMMMMMMWWWWWMMMMMWKo:;:c:;:::;cl:oKMMMMMMMMMMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMMMMMMMMMMMMMMWOcl0WMMMMMMMMMMMMMMMMMWkc;;coc;:ll:odoONMMMMMMMMMMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMMMMMMMMMMMMMMWKocxXWMMMMMMMMMMMMMMMMW0dlokdc:oxod0XNWMMMMMMMMMMMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMMMMMMMMMMMMMMMMMWKdlok0KNWWMMMMMMMMMMMMWNXNWX0KNNNWWMMMMMMMMMMMMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMMMMMMMMMMMMMMMMMWKOdollokKKO0KXWWWWNX0dkXWMMMMMMMMMMMMMMMMMMMMMMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWNKOdlll::cdxdkOdodloKWMMMMMMMMMMMMMMMMMMMMMMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWWKxc:::cc:clccdkKWMMMMMMMMMMMMMMMMMMMMMMMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNkc;;;;;:::dKWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMN0dooodoldKWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWWWWWNXWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM"' >> /etc/bash.bashrc
      echo 'echo "MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM"' >> /etc/bash.bashrc

echo 'echo "Información del sistema:"' >> /etc/bash.bashrc
echo 'echo "CPU: $(grep -m1 '\''model name'\'' /proc/cpuinfo | cut -d ":" -f2 | sed '\''s/^ //'\'' )"' >> /etc/bash.bashrc
echo 'echo "Memoria libre: $(free -h | awk '\''/^Mem:/ {print $7}'\'')"' >> /etc/bash.bashrc
echo 'echo "Espacio en disco: $(df -h / | awk '\''$NF=="/"{print $4}'\'')"' >> /etc/bash.bashrc
echo 'echo "Memoria escrita: $(awk '\''{sum += $10} END {gb = sum * 512 / (1024*1024*1024); if (gb >= 1024) printf "%.2f TB", gb/1024; else printf "%.2f GB", gb}'\'' /proc/diskstats)"' >> /etc/bash.bashrc
echo 'echo "Encendido permanente: $(awk '\''{ print int($1/86400) " days, " int(($1%86400)/3600) " hours, " int(($1%3600)/60) " minutes" }'\'' /proc/uptime)"' >> /etc/bash.bashrc
echo 'sensors 2>/dev/null || echo "No se detectaron sensores."' >> /etc/bash.bashrc
echo 'lsb_release -sd 2>/dev/null || echo "No LSB modules available."' >> /etc/bash.bashrc
echo 'uname -srm' >> /etc/bash.bashrc

# recargo el archivo bash.bashrc
source /etc/bash.bashrc

# servidor de SNMP
# **************************************
cp /etc/snmp/snmpd.conf /etc/snmp/snmpd.conf.ori
cat <<EOF > /etc/snmp/snmpd.conf
## SNMPD Configuration | Isaac (v5) - 07/2025
## puerto por defecto de escucha para SNMP
agentAddress udp:161

# =====[DEFINO-RED-SNMP]============================================================================================
## permite que equipos de esa red consulten SNMP con esa comunidad
# **rocommunity**	: Read-Only
# **rwcommunity**	: Read-Write
rocommunity HandShake_25 localhost
rocommunity HandShake_25 39.1.0.0/16
rocommunity HandShake_25 192.168.1.0/24

# =====[SOBREESCRIBIR-VALORES]======================================================================================
## sobreescribo o fuerzo OIDs existentes
syslocation "🤖 CPD"
syscontact "🤖 Informatica <informatica@aptelliot.es>"

# =====[DOCUMENTACIÓN-OIDS]=========================================================================================
## OIDs importantes definidos por defecto:
# sysObjectID: .1.3.6.1.2.1.1.2                  # Identificador único del objeto del sistema (por ejemplo, el tipo de dispositivo)
# sysDescr: .1.3.6.1.2.1.1.1                     # Descripción del sistema (por ejemplo, el modelo y la versión del firmware)
# sysUpTime: .1.3.6.1.2.1.1.3                    # Tiempo que el sistema ha estado funcionando desde el último reinicio
# sysContact: .1.3.6.1.2.1.1.4                   # Información de contacto del administrador del sistema
# sysName: .1.3.6.1.2.1.1.5                      # Nombre del sistema
# sysLocation: .1.3.6.1.2.1.1.6                  # Ubicación física del sistema
# sysServices: .1.3.6.1.2.1.1.7                  # Servicios disponibles en el sistema (por ejemplo, SNMP, HTTP, FTP)

# =====[PERSONALIZACIÓN-RAMAS]======================================================================================
## agrego OIDs personalizados que ejecutan comandos del sistema y exponen su salida vía SNMP
#extend test1 /bin/echo "Hello world"            # método actual: crea un identificador SNMP llamado test1 que al consultarlo devolverá "Hello world".
#exec 1.3.6.1.4.1.2021.8 /bin/echo "Hello world" # método antiguo: asocia directamente ese OID con el comando y devuelve su salida por SNMP

# =====[ACCESOS-RESTRICTIVOS]=======================================================================================
## restringe el acceso solo a esos OIDs específicos del sistema
view systemonly included .1.3.6.1.2.1.1.1        # Descripción del sistema (sysDescr)
view systemonly included .1.3.6.1.2.1.1.2        # Identificador único del objeto del sistema (sysObjectID)
view systemonly included .1.3.6.1.2.1.1.6        # Ubicación física del sistema (sysLocation)

# =====[PERMISOS-VISTAS]============================================================================================
## Restringe todo el árbol MIB y limita la información expuesta, permitiendo únicamente el acceso a los OIDs definidos explícitamente en la vista (ACCESOS-RESTRICTIVOS)
# Permitir acceso de lectura para la vista definida
access readonly "" any noauth exact systemonly none none

# Permitir acceso de lectura y escritura para la vista definida
#access rwcommunity "" any noauth exact systemonly none none

# Permitir acceso de lectura y escritura con autenticación y cifrado para la vista definida
#access rwcommunity "" any authPriv exact all none none
EOF

systemctl start snmpd
systemctl enable snmpd

echo "✅ Configurado e instalado snmp a través de snmpd como servidor consultado, ahora falta instalar desde el servidor cliente snmpwalk (consulta todo el subárbol de OIDs) y snmpget (consulta un OID en concreto)."
echo ""

# Hora
# **************************************
timedatectl set-timezone Europe/Madrid
echo -e "${YELLOW}Selecciona el método que deseas configurar para la configuración ntp: ${NC}"
echo -e "${YELLOW}Opción 1 (Cron + ntpdate, actualización puntual) => para equipos de bajo rendimiento: Ejecuta ntpdate una vez al día mediante cron, sincronizando ntp. ${NC}"
echo -e "${YELLOW}Opción 2 (Servicio NTP - ntpd, actualización continua) => para servidores: Mantiene la hora siempre sincronizada con servidores NTP públicos. ${NC}"
echo ""
read -rp "Selecciona una opción (1 o 2): " opcion

case "$opcion" in
  1)
    echo ""
    echo "Configurando sincronización puntual (cron + ntpdate)..."
    apt-get install -y ntpdate
    ntpdate hora.roa.es
    echo "00 6 * * * /usr/sbin/ntpdate -s hora.roa.es" | crontab -l 2>/dev/null | grep -v 'ntpdate -s hora.roa.es' | { cat; echo "00 6 * * * /usr/sbin/ntpdate -s hora.roa.es"; } | crontab -
    echo "✅ Configuración completada con método puntual (cron + ntpdate)."
    ;;
  2)
    echo ""
    echo "Configurando sincronización continua (ntpd)..."
    apt install ntp -y
    systemctl stop ntp
    mv /etc/ntpsec/ntp.conf /etc/ntpsec/ntp.old.conf 2>/dev/null
    cat <<EOF > /etc/ntp.conf
# /etc/ntpsec/ntp.conf, configuration for ntpd; see ntp.conf(5) for help
driftfile /var/lib/ntpsec/ntp.drift
leapfile /usr/share/zoneinfo/leap-seconds.list

# This should be maxclock 7, but the pool entries count towards maxclock.
tos maxclock 11

# Comment this out if you have a refclock and want it to be able to discipline
# the clock by itself (e.g. if the system is not connected to the network).
tos minclock 4 minsane 3

# pool.ntp.org maps to about 1000 low-stratum NTP servers.  Your server will
# pick a different set every time it starts up.  Please consider joining the
# pool: <https://www.pool.ntp.org/join.html>
server 0.es.pool.ntp.org iburst
server 1.es.pool.ntp.org iburst
server 2.es.pool.ntp.org iburst
server 3.es.pool.ntp.org iburst

# By default, exchange time with everybody, but don't allow configuration.
restrict default kod nomodify nopeer noquery limited
EOF
    systemctl restart ntp
    echo "✅ Configuración completada con método continuo (ntpd)."
    ;;
  *)
    echo "❌ Opción no válida. Abortando."
    exit 1
    ;;
esac

# SAR Habilitamos monitorizacion
# **************************************
sed -i 's/ENABLED="false"/ENABLED="true"/g' /etc/default/sysstat
systemctl enable sysstat
systemctl start sysstat

# Cambiar nombre tarjeta de red
# **************************************
# Comprobamos que tarjeta de red vamos a renombrar
# dmesg | grep -i eth

# Deshabilitamos el renombrado de interfaces en /etc/default/grub
sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="net.ifnames=0 biosdevname=0"/g' /etc/default/grub

# Regeneramos el archivo de grub
grub-mkconfig -o /boot/grub/grub.cfg

# Modificamos el archivo /etc/network/interfaces reemplazando ens33 por eth0
# auto eth0
mv /etc/network/interfaces /etc/network/_interfaces.ori
touch /etc/network/interfaces
cat <<EOF > /etc/network/interfaces
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
allow-hotplug eth0
iface eth0  inet dhcp
EOF

# editor de texto por defecto
# **************************************
# modifico el editor por defecto del sistema para muchas aplicaciones (como crontab)
# Detectar si el usuario es root
if [ "$EUID" -eq 0 ]; then
    BASHRC="/root/.bashrc"
else
    BASHRC="$HOME/.bashrc"
fi

# Añadir VISUAL si no existe
grep -qxF 'export VISUAL=vim' "$BASHRC" || echo 'export VISUAL=vim' >> "$BASHRC"

# Añadir EDITOR si no existe
grep -qxF 'export EDITOR=vim' "$BASHRC" || echo 'export EDITOR=vim' >> "$BASHRC"

# Deshabilitar IPv6
# **************************************
echo -e "# Deshabilitamos IPv6\nnet.ipv6.conf.all.disable_ipv6 = 1\nnet.ipv6.conf.default.disable_ipv6 = 1\nnet.ipv6.conf.lo.disable_ipv6 = 1" >> /etc/sysctl.conf
sysctl -p

# Archivo SWAP
# **************************************
# Preguntar al usuario si desea crear un archivo swap
# -------------------------------------------------------------------
echo -e "${YELLOW}Archivo SWAP: ${NC}"
read -p "¿Deseas agregar el archivo /swapfile? (s/n): " respuestaswap

if [[ "$respuestaswap" == "s" || "$respuestaswap" == "S" ]]; then
    read -p "Introduce en GB el total de memoria (ej: 2G, 4G, 8G): " new_swap
    # crear archivo swap de XGB
    sudo fallocate -l "$new_swap" /swapfile
    
    # dar permisos correctos
    sudo chmod 600 /swapfile
    
    # formatear como swap
    mkswap /swapfile
    
    # activar swap
    sudo swapon /swapfile
    
    # verificar que está activo
    swapon --show
    free -h
    
    # para que el swapfile se active en cada arranque, añade esta línea a /etc/fstab
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

    echo "✅ Configuración completada con archivo swap: /swapfile - "$respuestaswap"B."
EOF

else
    echo "Continuando con la instalación sin crear el archivo /swapfile."
fi
# -------------------------------------------------------------------

# Archivo iptables
# **************************************
apt install iptables iptables-persistent -y
systemctl enable netfilter-persistent

# iptables V4
# -------------------------------------------------------------------
cat <<EOF > /etc/iptables/rules.v4
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
-A INPUT -p icmp -j ACCEPT
-A INPUT -i lo -j ACCEPT
# SSH
-A INPUT -m state --state NEW -m tcp -p tcp --dport 22 -j ACCEPT
# Permitir HTTP (puerto 80) y HTTPS (puerto 443) si es necesario un panel web
-A INPUT -m state --state NEW -m tcp -p tcp --dport 80 -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 443 -j ACCEPT
# Permitimos recibir respuestas DHCP para monitorizar servicios DHCP
#-A INPUT -p udp --sport 67 --dport 68 -j ACCEPT
#-A OUTPUT -p udp --sport 68 --dport 67 -j ACCEPT
# Cerramos resto
-A INPUT -j REJECT --reject-with icmp-host-prohibited
-A FORWARD -j REJECT --reject-with icmp-host-prohibited
COMMIT
EOF
# -------------------------------------------------------------------

systemctl start iptables
iptables -L -n

# iptables V6
# -------------------------------------------------------------------
cat <<EOF > /etc/iptables/rules.v6
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
-A INPUT -p ipv6-icmp -j ACCEPT
-A INPUT -i lo -j ACCEPT
# SSH
-A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT
# Cerramos el resto
-A INPUT -j REJECT --reject-with icmp6-adm-prohibited
-A FORWARD -j REJECT --reject-with icmp6-adm-prohibited
COMMIT
EOF
# -------------------------------------------------------------------

systemctl start ip6tables 
ip6tables -L -n

# Actualizar proyecto
systemctl restart iptables
# Comprobar IPtables
iptables -L -n -v -t filter

echo "Iptables configurado correctamente."

echo -e "${YELLOW}¡Listo! Los paquetes se instalaron y la configuración esta completa. ${NC}"
echo -e "${YELLOW}Abre una nueva sesión para trabajar sobre los cambios. ${NC}"
