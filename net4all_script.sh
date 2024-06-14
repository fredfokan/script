:#!/bin/bash
#    .clooolc
#    :ooooooo.                                                                                  .:c
#    .ooooooo                                                                               'cllool
#      .:c;.   .::cc::,.                                                                   .loooool
#             cccccccccc:;.                                                                .loooool
#            '::::::ccccccc:::,.                                                           .loooool
#            ':::::;',:::::ccccc:.                        ;ooooooo,            looooooooooooooooooooooooo,   'oooooooo:           ':::;;;
#             ::::::::  .':::::::::::;.                     ooooooo'         .ooooooooooooooooooooooooooooo.   loooooooc        ;:::::,
#              .:::::::     ;:::::::::::;,                  .ooooooo.       .looooooocccccccoooooooc:::::::c.   ;oooooooo.    .::::::;
#                .;:::::,       .;:::::::::::;               .ooooooo;      ooooooo:       .loooool               coooooool.    ,:::;
#                 .;;;;;;,         .,:::::::::::'             :ooooooo.    ,ooooooc        .loooool               .ooooooooo.    ::,
#                   ';;;;;;             .::::::::::.           .oooooo:   .oooooo.         .loooool                 'oooooool'
#                    ';;;;;.               ';;;:::::            'oooooo, .oooooo:          .loooool                   oooooooo:
#                    .,,,,,.                .,;;;;;;              looooooooooooo           .loooool                    ;oooooooo.
#                   .,,,,,,              .,;;;;;;;;'              ,oooooooooooo             coooooo                   ;oooooooooo.
#                  ',,,,,,.          ';,;;,;;;;;;,.                ,ooooooooo;              'oooooo;                ,looooooooooool.
#                 ',,,,,,.        ';,,,,,,,,,,'                     ;ooooooo:                :oooooo;              coooooooloooooooo,
#                '''''''.      .,',,,,,,,,,'.                        ;oooool                  cooooooo;           ;ooooooo' 'oooooooo.
#             .,''''''.   .',,''',,,,,,.                              ;oooo.                   'oooooooollc.    'ooooooo;     looooooo;
#            .'''''''. .,'''''''''''.                                  ooo'                     .loooooooc     cooooooo:       ;oooooooo.
#            .......'''''''''''.                                        c                           cooo.    .oooooooo;         .ooooooool
#            ................                                                                               .llllllll.           'clllllll;
#             ..........
#                .....
#
# author: Frédéric Fokan
# date: 05.06.2024
# last update: 12.06.2024
/usr/bin/clear
/usr/bin/echo "###################################################################################################"
/usr/bin/echo "#                                                                                                 #"
/usr/bin/echo "# RebootProof Net4all scripts for Linux Servers                                                   #"
/usr/bin/echo "#                                                                                                 #"
/usr/bin/echo "###################################################################################################"
/usr/bin/echo "#                                                                                                 #"
/usr/bin/echo "# Please select any of the following activities :                                                 #"
/usr/bin/echo "#                                                                                                 #"
/usr/bin/echo "#                                                                                                 #"
/usr/bin/echo "# [B]efore reboot (will perform a full backup of /etc & save of eventual config in memmory)       #"
/usr/bin/echo "#                                                                                                 #"
/usr/bin/echo "# [P]ost reboot  (!!! reapplying that part will erase any previous post reboot data's)            #"
/usr/bin/echo "#                                                                                                 #"
/usr/bin/echo "# [C]compare discrepency between configs before & after reboot !                                  #"
/usr/bin/echo "#                                                                                                 #"
/usr/bin/echo "#                                                                                                 #"
/usr/bin/echo "###################################################################################################"
read opt;
case $opt in
     [Bb]* )
         /usr/bin/clear
	 type tar >/dev/null 2>&1 || { echo >&2 "tar but is not installed.  Aborting."; exit 1; }
	 type pstree >/dev/null 2>&1 || { echo >&2 "pstree is not installed.  Aborting."; exit 1; }
         /usr/bin/mkdir /root/net4all-BR-$(date +%Y%m%d_%H%M%S) && cd "$_";
         /usr/bin/uname -a > System_Information ;
         /usr/bin/tar -czvf etc.tar.gz /etc ;
         /usr/bin/cat /etc/hostname > hostname_$(uname -n) ;
         /usr/bin/cat /etc/resolv.conf > resolv.conf ;
         /usr/bin/ip addr > ip_addr_before_reboot ;
         /usr/bin/ip route > ip_route_before_reboot ;
         if exists iptables-save; then
           /usr/sbin/iptables-save  > /root/net4all-BR-*/iptables-save_V4_before_reboot
         else
           echo 'Your system does not have iptables-save'
         fi
#         /usr/sbin/iptables-save  > iptables-save_V4_before_reboot ;
         if exists ip6tables-save; then
           /usr/sbin/ip6tables-save  > /root/net4all-BR-*/ip6tables-save_V6_before_reboot
         else
           echo 'Your system does not have ip6tables-save'
         fi
#         /usr/sbin/ip6tables-save  > ip6tables-save_V6_before_reboot ;
         /usr/bin/ps -efww > Process_running_before_reboot ;
         /usr/bin/clear ;
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
        /usr/bin/clear
        /usr/bin/rm -Rf /root/net4all-PR-*/
        /usr/bin/mkdir /root/net4all-PR-$(date +%Y%m%d_%H%M%S) && cd "$_" ;
        /usr/bin/uname -a > System_Information ;
        /usr/bin/cat /etc/hostname > hostname_$(uname -n) ;
        /usr/bin/cat /etc/resolv.conf > resolv.conf ;
        /usr/bin/ip addr > ip_addr_post_reboot ;
        /usr/bin/ip route > ip_route_post_reboot ;
        /usr/sbin/iptables-save  > iptables-save_V4_post_reboot ;
        /usr/sbin/ip6tables-save  > ip6tables-save_V6_post_reboot ;
        /usr/bin/ps -efww > Process_running_post_reboot ;
        exit ;;
     [Cc]* ) 
        /usr/bin/clear
        /usr/bin/echo ""
        /usr/bin/echo "###################################################################################################"
        /usr/bin/echo "#                                                                                                 #"
        /usr/bin/echo "# Before                                                     < >  After                           #"
        /usr/bin/echo "#                                                                                                 #"
        /usr/bin/echo "###################################################################################################"
        /usr/bin/echo ""
        /usr/bin/echo "Making diff of System Information (Output of uname -a)"
        /usr/bin/diff --side-by-side --suppress-common-lines /root/net4all-BR-*/System_Information /root/net4all-PR-*/System_Information 2>/dev/null
        /usr/bin/echo ""
        /usr/bin/echo "Making diff of host name"
        /usr/bin/diff --side-by-side --suppress-common-lines /root/net4all-BR-*/hostname_* /root/net4all-PR-*/hostname_* 2>/dev/null
        /usr/bin/echo ""       
        /usr/bin/echo "making diff of resolv.conf"
        /usr/bin/diff --side-by-side --suppress-common-lines /root/net4all-BR-*/resolv.conf /root/net4all-PR-*/resolv.conf 2>/dev/null
        /usr/bin/echo ""
        /usr/bin/echo "Making diff of ip address"
        /usr/bin/diff --side-by-side --suppress-common-lines /root/net4all-BR-*/ip_addr_before_reboot /root/net4all-PR-*/ip_addr_post_reboot 2>/dev/null
        /usr/bin/echo ""
        /usr/bin/echo "Making diff of ip route"
        /usr/bin/diff --side-by-side --suppress-common-lines /root/net4all-BR-*/ip_route_before_reboot /root/net4all-PR-*/ip_route_post_reboot 2>/dev/null
        /usr/bin/echo ""
        /usr/bin/echo "Making diff of iptables V4 rules"
        /usr/bin/diff --side-by-side --suppress-common-lines /root/net4all-BR-*/iptables-save_V4_before_reboot /root/net4all-PR-*/iptables-save_V4_post_reboot 2>/dev/null
        /usr/bin/echo ""
        /usr/bin/echo "Making diff of iptables V6 rules"
        /usr/bin/diff --side-by-side --suppress-common-lines /root/net4all-BR-*/iptables-save_V6_before_reboot /root/net4all-PR-*/iptables-save_V6_post_reboot 2>/dev/null
        /usr/bin/echo ""
        /usr/bin/echo "Making diff of running process"
        /usr/bin/diff --side-by-side --suppress-common-lines /root/net4all-BR-*/Process_running_before_reboot /root/net4all-PR-*/Process_running_post_reboot 2>/dev/null
        exit;;
   esac
done
