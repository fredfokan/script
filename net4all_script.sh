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
read opt;
case $opt in
     [Bb]* )
         clear
         mkdir /root/net4all-BR-$(date +%Y%m%d_%H%M%S) && cd "$_" && echo -e "$White Before reboot directory creation --> $Green Complete";
         uname -a > System_Information && echo -e "$White Hostname save --> $Green Complete";
         mount > Mount_information && echo -e "$White Mount save --> $Green Complete";
         df -H > Disk_space_used && echo -e "$White Disk space usage --> $Green Complete";
	       tar -czf $(uname -n)_etc.tar.gz /etc 2>/dev/null && echo -e "$White Backup of entire /etc --> $Green Complete" || echo -e "$Red This server does not have Tar installed";
         cat /etc/hostname > hostname_$(uname -n) && echo -e "$White Save of Hostname --> $Green Complete";
         cat /etc/resolv.conf > resolv.conf && echo -e "$White Save of resolv.conf --> $Green Complete";
         ip addr > ip_addr_before_reboot && echo -e "$White Save of IP config --> $Green Complete";
         ip route > ip_route_before_reboot && echo -e "$White Save of IP route config --> $Green Complete";
         iptables-save -f iptables-save_V4_before_reboot && echo -e "$White Backup of Iptables v4 Rules --> $Green Complete" || echo -e "$Red This server does not have iptables-save";
         ip6tables-save -f iptables-save_V6_before_reboot && echo -e "$White Backup of Iptables v6 Rules --> $Green Complete" || echo -e "$Red Your system does not have ip6tables-save";
         ps -efww > Process_running_before_reboot && echo -e "$White Save of Running process before reboot --> $Green Complete" ;
         echo -e "$White"
         echo ""
         echo ""
	 while true; do
             read -p "Do you wish to restart this server now ? " yn
             case $yn in
             [Yy]* ) /usr/sbin/shutdown -r now;;
             [Nn]* ) exit && clear;;
             * ) echo "Please answer yes or no.";;
             esac
         done
         exit;;
     [Pp]* )
        clear
        rm -Rf /root/net4all-PR-*/
        mkdir /root/net4all-PR-$(date +%Y%m%d_%H%M%S) && cd "$_" && echo -e "$White Post reboot directory creation --> $Green Complete";
        uname -a > System_Information && echo -e "$White Hostname save --> $Green Complete";
        df -H > Disk_space_used && echo -e "$White Disk space usage --> $Green Complete";
        mount > Mount_information && echo -e "$White Mount save --> $Green Complete";
        cat /etc/hostname > hostname_$(uname -n) && echo -e "$White Save of Hostname --> $Green Complete";
        cat /etc/resolv.conf > resolv.conf && echo -e "$White Save of resolv.conf --> $Green Complete";
        ip addr > ip_addr_before_reboot && echo -e "$White Save of IP config --> $Green Complete";
        ip route > ip_route_before_reboot && echo -e "$White Save of IP route config --> $Green Complete";
        iptables-save -f iptables-save_V4_post_reboot && echo -e "$White Backup of Iptables v4 Rules --> $Green Complete" || echo -e "$Red This server does not have iptables-save";
        ip6tables-save -f iptables-save_V6_post_reboot && echo -e "$White Backup of Iptables v6 Rules --> $Green Complete" || echo -e "$Red Your system does not have ip6tables-save";
        ps -efww > Process_running_post_reboot && echo -e "$White Save of Running process post reboot --> $Green Complete" ;
        exit ;;
     [Cc]* ) 
        clear
        echo ""
        echo ""
        echo ""
        echo "Doing diff between before reboot & post reboot for hostname: $(uname -n) "
        echo ""
        echo ""
        echo ""
        echo "###################################################################################################################################"
        echo "#                                                                                                                                 #"
        echo "# Before reboot                                              < >                                                      Post Reboot #"
        echo "#                                                                                                                                 #"
        echo "###################################################################################################################################"
        echo ""
        echo "                                                              |                                                                   "
        echo "                                                              |                                                                   "
        echo "Making diff of System Information (Output of uname -a)"
        diff --side-by-side --suppress-common-lines /root/net4all-BR-*/System_Information /root/net4all-PR-*/System_Information 2>/dev/null
        echo "                                                              |                                                                   "
        echo "                                                              |                                                                   "
        echo ""
        echo "Making diff of Mount Information"
        diff --side-by-side --suppress-common-lines /root/net4all-BR-*/Mount_information /root/net4all-PR-*/Mount_information 2>/dev/null
        echo "                                                              |                                                                   "
        echo "                                                              |                                                                   "
        echo ""
        echo "Making diff of disk space before & after reboot" 
        diff --side-by-side --suppress-common-lines /root/net4all-BR-*/Disk_space_used /root/net4all-PR-*/Disk_space_used 2>/dev/null
        echo "                                                              |                                                                   "
        echo "                                                              |                                                                   "
        echo ""
        echo "Making diff of host name"
        diff --side-by-side --suppress-common-lines /root/net4all-BR-*/hostname_* /root/net4all-PR-*/hostname_* 2>/dev/null
        echo "                                                              |                                                                   "
        echo "                                                              |                                                                   "
        echo ""       
        echo "making diff of resolv.conf"
        diff --side-by-side --suppress-common-lines /root/net4all-BR-*/resolv.conf /root/net4all-PR-*/resolv.conf 2>/dev/null
        echo "                                                              |                                                                   "
        echo "                                                              |                                                                   "
        echo ""
        echo "Making diff of ip address"
        diff --side-by-side --suppress-common-lines /root/net4all-BR-*/ip_addr_before_reboot /root/net4all-PR-*/ip_addr_post_reboot 2>/dev/null
        echo "                                                              |                                                                   "
        echo "                                                              |                                                                   "
        echo ""
        echo "Making diff of ip route"
        diff --side-by-side --suppress-common-lines /root/net4all-BR-*/ip_route_before_reboot /root/net4all-PR-*/ip_route_post_reboot 2>/dev/null
        echo "                                                              |                                                                   "
        echo "                                                              |                                                                   "
        echo ""
        echo "Making diff of iptables V4 rules"
        diff --side-by-side --suppress-common-lines /root/net4all-BR-*/iptables-save_V4_before_reboot /root/net4all-PR-*/iptables-save_V4_post_reboot 2>/dev/null
        echo "                                                              |                                                                   "
        echo "                                                              |                                                                   "
        echo ""
        echo "Making diff of iptables V6 rules"
        diff --side-by-side --suppress-common-lines /root/net4all-BR-*/iptables-save_V6_before_reboot /root/net4all-PR-*/iptables-save_V6_post_reboot 2>/dev/null
        echo "                                                              |                                                                   "
        echo "                                                              |                                                                   "
        echo ""
        echo "Making diff of running process"
        diff --side-by-side --suppress-common-lines /root/net4all-BR-*/Process_running_before_reboot /root/net4all-PR-*/Process_running_post_reboot 2>/dev/null
        echo "                                                              |                                                                   "
        echo "                                                              |                                                                   "
        echo ""
        exit;;
   esac
done
