#!/bin/bash
# author: Frederic Fokan
# date: 05.06.2024
# last update: 14.06.2024
Green='\033[0;32m'
Red='\033[0;31m'
White='\033[0;37m'

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


get-mysql-vars () {
    if command -v mysql &> /dev/null; then
        mysql --execute "SHOW variables;" > "mysql_variables" && echo -e "$White Save of MySQL variables --> $Green Complete" || echo -e "$Red Failed to save MySQL variables";
    else
        echo -e "$White No mysql command found on this server"
    fi
}

#display-diff <label> <filename>
display-diff () {
        label="Making diff of $1"
        label_length=$(echo "$label" | wc -c)
        echo "$label"
        printf "%${label_length}s" | tr " " "-"
        echo
        diff --side-by-side --suppress-common-lines /root/net4all-BR-*/"$2" /root/net4all-PR-*/"$2" 2>/dev/null
        echo -e "                                                              |                                                                   "
        echo -e "                                                              |                                                                   \n"
}

read -r opt;
case $opt in
     [Bb]* )
         clear
         mkdir /root/net4all-BR-$(date +%Y%m%d_%H%M%S) && cd "$_" && echo -e "$White Before reboot directory creation --> $Green Complete";
         uname -a > system_Information && echo -e "$White Hostname save --> $Green Complete";
         mount | sort > mount_information && echo -e "$White Mount save --> $Green Complete";
         df -H > disk_space_used && echo -e "$White Disk space usage --> $Green Complete";
         tar -czf $(uname -n)_etc.tar.gz /etc 2>/dev/null && echo -e "$White Backup of entire /etc --> $Green Complete" || echo -e "$Red This server does not have Tar installed";
         cat /etc/hostname > hostname_$(uname -n) && echo -e "$White Save of Hostname --> $Green Complete";
         cat /etc/resolv.conf > resolv.conf && echo -e "$White Save of resolv.conf --> $Green Complete";
         ip addr > ip_addr && echo -e "$White Save of IP config --> $Green Complete";
         ip route > ip_route && echo -e "$White Save of IP route config --> $Green Complete";
         iptables-save -f iptables-save_V4 && echo -e "$White Backup of Iptables v4 Rules --> $Green Complete" || echo -e "$Red This server does not have iptables-save";
         ip6tables-save -f iptables-save_V6 && echo -e "$White Backup of Iptables v6 Rules --> $Green Complete" || echo -e "$Red Your system does not have ip6tables-save";
         ps -efww > process_running_before_reboot && echo -e "$White Save of running process before reboot --> $Green Complete";
         ps -ef --no-headers | awk '{print $8}' | sort | uniq > process_running_min && echo -e "$White Save of minimalist list of running process before reboot --> $Green Complete";
         get-mysql-vars
         echo -e "$White\n"
         while true; do
             read -p "Do you wish to restart this server now ? " yn
             case $yn in
             [Yy]* ) /usr/sbin/shutdown -r now;;
             [Nn]* ) exit;;
             * ) echo "Please answer yes or no.";;
             esac
         done
         exit;;

     [Pp]* )
        clear
        rm -Rf /root/net4all-PR-*/
        mkdir /root/net4all-PR-$(date +%Y%m%d_%H%M%S) && cd "$_" && echo -e "$White Post reboot directory creation --> $Green Complete";
        uname -a > system_Information && echo -e "$White Hostname save --> $Green Complete";
        df -H > disk_space_used && echo -e "$White Disk space usage --> $Green Complete";
        mount | sort > mount_information && echo -e "$White Mount save --> $Green Complete";
        cat /etc/hostname > hostname_$(uname -n) && echo -e "$White Save of Hostname --> $Green Complete";
        cat /etc/resolv.conf > resolv.conf && echo -e "$White Save of resolv.conf --> $Green Complete";
        ip addr > ip_addr && echo -e "$White Save of IP config --> $Green Complete";
        ip route > ip_route && echo -e "$White Save of IP route config --> $Green Complete";
        iptables-save -f iptables-save_V4 && echo -e "$White Backup of Iptables v4 Rules --> $Green Complete" || echo -e "$Red This server does not have iptables-save";
        ip6tables-save -f iptables-save_V6 && echo -e "$White Backup of Iptables v6 Rules --> $Green Complete" || echo -e "$Red Your system does not have ip6tables-save";
        ps -efww > process_running_post_reboot && echo -e "$White Save of running process post reboot --> $Green Complete";
        ps -ef --no-headers | awk '{print $8}' | sort | uniq > process_running_min && echo -e "$White Save of minimalist list of running process after reboot --> $Green Complete";
        get-mysql-vars
        exit;;

     [Cc]* ) 
        clear
        echo -e "\n\nDoing diff between before reboot & post reboot for hostname: $(uname -n)\n\n"
        echo -e "###################################################################################################################################"
        echo -e "#                                                                                                                                 #"
        echo -e "# Before reboot                                              < >                                                      Post Reboot #"
        echo -e "#                                                                                                                                 #"
        echo -e "###################################################################################################################################\n\n"
        display-diff "System Information (Output of uname -a)" "system_Information"
        display-diff "mount information" "mount_information"
        display-diff "disk space" "disk_space_used"
        display-diff "host name" "hostname_*"
        display-diff "resolv.conf" "resolv.conf"
        display-diff "ip address" "ip_addr"
        display-diff "ip route" "ip_route"
        display-diff "iptables V4 rules" "iptables-save_V4"
        display-diff "iptables V6 rules" "iptables-save_V6"
        display-diff "running process" "process_running_min"
        display-diff "MySQL variables" "mysql_variables"
        exit;;
esac

exit 0;