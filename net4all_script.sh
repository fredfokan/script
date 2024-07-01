#!/bin/bash
# author: Frederic Fokan
# date: 05.06.2024
# last update: 14.06.2024

display_header_and_menu () {
    clear
    echo ""
    echo ""
    echo "                                             .                                                      "
    echo "                                           ';;                                                      "
    echo "                                         .;;;.                                                      "
    echo "     ,;.     .;'                       .,;;;'   .         ..      ''    :.                          "
    echo "     KMWl    ;M0             kK.      .,,,,'   .;,       .cc.     ;,   .l.                          "
    echo "     KMNMO.  ;M0  .:looo:. ,oWMdo,   '::;;.    ,,,.      c'.c     ;,   .l.                          "
    echo "     KMclWX' ;M0 .NWl;;oMX ,lMWl:.  .lllc'    .:;;'     ;;  ,:    ;,   .l.                          "
    echo "     KM: ,NW::M0 :MK;;;oMW. .MW.    clll:''''';lll:    'c.  .c'   ;,   .l.                          "
    echo "     KM:  .KMXM0 :MXllll:.  .MW.   .clllllllllllll:   .l;,,,,,l.  ;,   .l.                          "
    echo "     KM:    dMM0 .NWo:::c:   KMx;.    ....'''';lll;   c,      ,c  'c.   c,                          "
    echo "     ;c.     ,c;  .:lllc:'    ;cc.            .lll'  .'        '.  ..'.  .'.                        "
    echo "                                               ;lc.                                                 "
    echo "                                               .c,                                                  "
    echo ""
    echo ""
    echo "###################################################################################################"
    echo "#                                                                                                 #"
    echo "# RebootProof scripts for Linux Servers (must be run as root)                                     #"
    echo "#                                                                                                 #"
    echo "###################################################################################################"
    echo "#                                                                                                 #"
    echo "# Please select any of the following activities :                                                 #"
    echo "#                                                                                                 #"
    echo "#                                                                                                 #"
    echo "# [B] before reboot (will perform a full backup of /etc & save of eventual configs in memory)     #"
    echo "#                                                                                                 #"
    echo "# [P] post reboot  (!!! reapplying that part will remove any previous post reboot data's)         #"
    echo "#                                                                                                 #"
    echo "# [C] compare discrepency between configs before & after reboot !                                 #"
    echo "#                                                                                                 #"
    echo "#                                                                                                 #"
    echo "###################################################################################################"
    echo -e "\n"
}

Green='\033[0;32m'
Red='\033[0;31m'
White='\033[0;37m'
display_message () {
    color=
    [ "$1" = "ok" ] && color="${Green}[ OK] " || color="${Red}[NOK] "
    echo -e "$color$2$White"
}

mkdir_and_rename_if_exists () {
    find /root/ -maxdepth 1 -type d -name "*$1-reboot-data" -exec mv {} {}-backup \;
    if mkdir "/root/$(date +%Y%m%d_%H%M%S)-$1"-reboot-data && cd "$_"; then
        display_message "ok" "Reboot directory creation"
    else
        display_message "nok" "Fail to create reboot directory"
        exit 1;
    fi
}

is_command_exists () {
    if command -v "$1" &> /dev/null; then
        return 0
    else
        display_message "nok" "$1 command not found on this server"
        return 1;
    fi
}

#$1 : If not empty, check if given parameter is a bash command that exists
#$2 : Bash command to execute
#$3 : Message to display
save_data_if_command_exists () {
    if [ -z "$1" ] || is_command_exists "$1"; then
        if eval "$2"; then
            display_message "ok" "$3"
        else
            display_message "nok" "$3"
        fi
    fi
}

save_data () {
    save_data_if_command_exists "uname" "uname -a > system_information;" "Save hostname (uname -a)"
    save_data_if_command_exists "df" "df -H > disk_space_used;" "Save disk space usage"
    save_data_if_command_exists "mount" "mount | sort > mount_information;" "Save mount filesystems"
    save_data_if_command_exists "tar" "tar -czf etc_directory.tar.gz /etc 2>/dev/null;" "Backup /etc directory"
    save_data_if_command_exists "" "cat /etc/hostname > etc_hostname;" "Save file /etc/hostname"
    save_data_if_command_exists "" "cat /etc/resolv.conf > resolv.conf;" "Save file /etc/resolv.conf"
    save_data_if_command_exists "ip" "ip addr > ip_addr;" "Save ip addr"
    save_data_if_command_exists "" "ip route > ip_route;" "Save ip route"
    save_data_if_command_exists "iptables-save" "iptables-save > iptables-save_v4 2>/dev/null;" "Save iptables v4"
    save_data_if_command_exists "ip6tables-save" "ip6tables-save > iptables-save_v6;" "Save iptables v6"
    save_data_if_command_exists "ps" "ps -efww > running_procs;" "Save running processus (ps -efww)"
    save_data_if_command_exists "awk" "ps -ef --no-headers | awk '{print \$8}' | sort | uniq > running_procs_min;" "Save running processus (ps -ef --no-headers) for diff"
    save_data_if_command_exists "netstat" "netstat -tunlp > netstat_tunlp;" "Save netstat (tunlp)"
    save_data_if_command_exists "timedatectl" "timedatectl | grep 'Time zone' > timezone;" "Save timezone"
    save_data_if_command_exists "mysql" "mysql --execute 'SHOW variables;' > mysql_variables" "Save MySQL variables"
    save_data_if_command_exists "psql" "sudo --login --user=postgres psql -c 'show all;' > psql_runtime_vars" "Save PostgreSQL variables"
}

pre_reboot_directory=
post_reboot_directory=
find_directories_to_diff () {
    pre_reboot_directory=$(find /root -maxdepth 1 -type d -name "*pre-reboot-data" | sort -nr | head -1)
    post_reboot_directory=$(find /root -maxdepth 1 -type d -name "*post-reboot-data" | sort -nr | head -1)
}

display_diff () {
    label="Making diff of $1"
    echo "$label"
    printf "%${#label}s\n" | tr " " "-"
    if [ ! -f "$pre_reboot_directory/$2" ]; then
        display_message "nok" "Cannot find pre-reboot file $pre_reboot_directory/$2"
    elif [ ! -f "$post_reboot_directory/$2" ]; then
        display_message "nok" "Cannot find post-reboot file $post_reboot_directory/$2"
    else
        diff --side-by-side --suppress-common-lines "$pre_reboot_directory/$2" "$post_reboot_directory/$2"
    fi
    echo -e "                                                              |                                                                   \n"
}


display_header_and_menu
read -r opt;
case $opt in
     [Bb]* )
        clear
        mkdir_and_rename_if_exists "pre"
        save_data
        echo
        while true; do
            read -rp "Do you wish to restart this server now ? " yn
            case $yn in
            [Y]* ) /usr/sbin/shutdown -r now;;
            [Nn]* ) exit;;
            * ) echo "Please answer Yes or no (Y/n)";;
            esac
        done
        exit;;

     [Pp]* )
        clear
        mkdir_and_rename_if_exists "post"
        save_data
        exit;;

     [Cc]* ) 
        clear
        echo -e "\n\nDoing diff between before reboot & post reboot for hostname: $(uname -n)\n\n"
        echo -e "###################################################################################################################################"
        echo -e "#                                                                                                                                 #"
        echo -e "# Before reboot                                              < >                                                      Post Reboot #"
        echo -e "#                                                                                                                                 #"
        echo -e "###################################################################################################################################\n\n"
        find_directories_to_diff
        display_diff "System Information (Output of uname -a)" "system_information"
        display_diff "disk space" "disk_space_used"
        display_diff "mount information" "mount_information"
        display_diff "host name" "etc_hostname"
        display_diff "resolv.conf" "resolv.conf"
        display_diff "ip address" "ip_addr"
        display_diff "ip route" "ip_route"
        display_diff "iptables V4 rules" "iptables-save_v4"
        display_diff "iptables V6 rules" "iptables-save_v6"
        display_diff "running process" "running_procs_min"
        #display_diff "netstat" "netstat_tunlp" TODO: Find a way to sort netstat output for the diff
        display_diff "Timezone" "timezone"
        display_diff "MySQL variables" "mysql_variables"
        display_diff "PostgreSQL variables" "psql_runtime_vars"
        exit;;
esac

exit 0;