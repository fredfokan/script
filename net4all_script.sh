#!/bin/bash
# author: Frederic Fokan
# date: 05.06.2024
# last update: 14.06.2024
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
echo "# [B]efore reboot (will perform a full backup of /etc & save of eventual configs in memory)       #"
echo "#                                                                                                 #"
echo "# [P]ost reboot  (!!! reapplying that part will erase any previous post reboot data's)            #"
echo "#                                                                                                 #"
echo "# [C]compare discrepency between configs before & after reboot !                                  #"
echo "#                                                                                                 #"
echo "#                                                                                                 #"
echo "###################################################################################################"
read opt;
case $opt in
     [Bb]* )
         clear
         type tar >/dev/null 2>&1 || { echo >&2 "tar but is not installed.  Aborting."; exit 1; }
         type pstree >/dev/null 2>&1 || { echo >&2 "pstree is not installed.  Aborting."; exit 1; }
         mkdir /root/net4all-BR-$(date +%Y%m%d_%H%M%S) && cd "$_";
         uname -a > System_Information ;
         tar -czvf etc.tar.gz /etc ;
         cat /etc/hostname > hostname_$(uname -n) ;
         cat /etc/resolv.conf > resolv.conf ;
         ip addr > ip_addr_before_reboot ;
         ip route > ip_route_before_reboot ;
         if [ -x /usr/sbin/iptables-save ]; then
             /usr/sbin/iptables-save -f iptables-save_V4_before_reboot
         else
             echo "Your system does not have iptables-save"
         fi
         if [ -x /usr/sbin/ip6tables-save ]; then
             /usr/sbin/ip6tables-save -f iptables-save_V6_before_reboot
         else
             echo "Your system does not have ip6tables-save"
         fi
         ps -efww > Process_running_before_reboot ;
         clear ;
         while true; do
		 read -p "Do you wish to restart this server now (Y/N) ? " yn
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
        mkdir /root/net4all-PR-$(date +%Y%m%d_%H%M%S) && cd "$_" ;
        uname -a > System_Information ;
        cat /etc/hostname > hostname_$(uname -n) ;
        cat /etc/resolv.conf > resolv.conf ;
        ip addr > ip_addr_post_reboot ;
        ip route > ip_route_post_reboot ;
        /usr/sbin/iptables-save  > iptables-save_V4_post_reboot ;
        /usr/sbin/ip6tables-save  > ip6tables-save_V6_post_reboot ;
        ps -efww > Process_running_post_reboot ;
        exit ;;
     [Cc]* ) 
        clear
        echo ""
        echo "###################################################################################################"
        echo "#                                                                                                 #"
        echo "# Before                                                     < >  After                           #"
        echo "#                                                                                                 #"
        echo "###################################################################################################"
        echo ""
        echo "Making diff of System Information (Output of uname -a)"
        diff --side-by-side --suppress-common-lines /root/net4all-BR-*/System_Information /root/net4all-PR-*/System_Information 2>/dev/null
        echo ""
        echo "Making diff of host name"
        diff --side-by-side --suppress-common-lines /root/net4all-BR-*/hostname_* /root/net4all-PR-*/hostname_* 2>/dev/null
        echo ""       
        echo "making diff of resolv.conf"
        diff --side-by-side --suppress-common-lines /root/net4all-BR-*/resolv.conf /root/net4all-PR-*/resolv.conf 2>/dev/null
        echo ""
        echo "Making diff of ip address"
        diff --side-by-side --suppress-common-lines /root/net4all-BR-*/ip_addr_before_reboot /root/net4all-PR-*/ip_addr_post_reboot 2>/dev/null
        echo ""
        echo "Making diff of ip route"
        diff --side-by-side --suppress-common-lines /root/net4all-BR-*/ip_route_before_reboot /root/net4all-PR-*/ip_route_post_reboot 2>/dev/null
        echo ""
        echo "Making diff of iptables V4 rules"
        diff --side-by-side --suppress-common-lines /root/net4all-BR-*/iptables-save_V4_before_reboot /root/net4all-PR-*/iptables-save_V4_post_reboot 2>/dev/null
        echo ""
        echo "Making diff of iptables V6 rules"
        diff --side-by-side --suppress-common-lines /root/net4all-BR-*/iptables-save_V6_before_reboot /root/net4all-PR-*/iptables-save_V6_post_reboot 2>/dev/null
        echo ""
        echo "Making diff of running process"
        diff --side-by-side --suppress-common-lines /root/net4all-BR-*/Process_running_before_reboot /root/net4all-PR-*/Process_running_post_reboot 2>/dev/null
        exit;;
   esac
done
