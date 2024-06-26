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

is_command_exists () {
    if command -v "$1" &> /dev/null; then
        return 0
    else
        display_message "nok" "$1 command not found on this server"
        return 1;
    fi
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

save_uname_a () {
    if uname -a > system_information; then
        display_message "ok" "Hostname saved"
    else
        display_message "nok" "Fail to save hostname"
    fi
}

save_disk_space () {
    if df -H > disk_space_used; then
        display_message "ok" "Disk space usage saved"
    else
        display_message "nok" "Fail to save disk space usage"
    fi
}

save_mount_fs () {
    if mount | sort > mount_information; then
        display_message "ok" "Mount filesystems saved"
    else
        display_message "nok" "Fail to save mount filesystems"
    fi
}

save_etc_directory () {
    if is_command_exists "tar"; then
        if tar -czf etc_directory.tar.gz /etc 2>/dev/null; then
            display_message "ok" "/etc directory backuped"
        else
            display_message "nok" "Fail to backup /etc directory"
        fi
    fi
}

save_hostname () {
    if cat /etc/hostname > etc_hostname; then
        display_message "ok" "/etc/hostname saved"
    else
        display_message "nok" "Fail to save /etc/hostname"
    fi
}

save_resolv_conf () {
    if cat /etc/resolv.conf > resolv.conf; then
        display_message "ok" "File resolv.conf saved"
    else
        display_message "nok" "Fail to save file resolv.conf"
    fi
}

save_ip_addr () {
    if ip addr > ip_addr; then
        display_message "ok" "Ip addr saved"
    else
        display_message "nok" "Fail to save ip addr"
    fi
}

save_ip_route () {
    if ip route > ip_route; then
        display_message "ok" "Ip route saved"
    else
        display_message "nok" "Fail to save ip route"
    fi
}

save_iptables_v4 () {
    if is_command_exists "iptables-save"; then
        if iptables-save > iptables-save_v4 2>/dev/null; then
            display_message "ok" "Iptables v4 saved"
        else
            display_message "nok" "Fail to save iptables v4"
        fi
    fi
}

save_iptables_v6 () {
    if is_command_exists "ip6tables-save"; then
        if ip6tables-save > iptables-save_v6; then
            display_message "ok" "Iptables v6 saved"
        else
            display_message "nok" "Fail to save iptables v6"
        fi
    fi
}

save_running_procs () {
    if ps -efww > running_procs; then
        display_message "ok" "Running processus (ps -efww) saved"
    else
        display_message "nok" "Fail to save running processus (ps -efww)"
    fi
    if ps -ef --no-headers | awk '{print $8}' | sort | uniq > running_procs_min; then
        display_message "ok" "Running processus (ps -ef --no-headers) saved"
    else
        display_message "nok" "Fail to save running processus (ps -ef --no-headers)"
    fi
}

save_netstat () {
    if is_command_exists "netstat"; then
        if netstat -tunlp > netstat_tunlp; then
            display_message "ok" "Netstat (tunlp) saved"
        else
            display_message "nok" "Fail to save netstat (tunlp)"
        fi
    fi
}

save_mysql_vars () {
    if is_command_exists "mysql"; then
        if mysql --execute "SHOW variables;" > "mysql_variables"; then
            display_message "ok" "MySQL variables saved"
        else
            display_message "nok" "Fail to save MySQL variables"
        fi
    fi
}

save_data () {
    save_uname_a
    save_disk_space
    save_mount_fs
    save_etc_directory
    save_hostname
    save_resolv_conf
    save_ip_addr
    save_ip_route
    save_iptables_v4
    save_iptables_v6
    save_running_procs
    save_netstat
    save_mysql_vars
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
        display_diff "MySQL variables" "mysql_variables"
        exit;;
esac

exit 0;