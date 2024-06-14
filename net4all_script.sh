#!/bin/bash
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
# last update: 14.01.2020
/usr/bin/clear
/usr/bin/echo "###################################################################################################"
/usr/bin/echo "# Bash Script for performing backups of sensible configs for RebootProof of Net4all Linux Servers #"
/usr/bin/echo "###################################################################################################"
/usr/bin/echo "#                                                                                                 #"
/usr/bin/echo "# Please select any of the activities below :                                                     #"
/usr/bin/echo "#                                                                                                 #"
/usr/bin/echo "# [b]efore reboot (will perform a backup of config in memory and the entire /etc )                #"
/usr/bin/echo "# [p]ost reboot  (note that reapplying that part will erase any previous post reboot data's)      #"
/usr/bin/echo "# [c]compare discrepency between configs before & after reboot                                    #"
/usr/bin/echo "#                                                                                                 #"
/usr/bin/echo "###################################################################################################"
read opt;
case $opt in
     [Bb]* )
         /usr/bin/clear
         /usr/bin/mkdir /root/net4all-BR-$(date +%Y%m%d_%H%M%S) && cd "$_";
         /usr/bin/uname -a > System_Information ;
         /usr/bin/tar -czvf etc.tar.gz /etc ;
         /usr/bin/cat /etc/hostname > hostname_$(uname -n) ;
         /usr/bin/cat /etc/resolv.conf > resolv.conf ;
         /usr/bin/ip addr > ip_addr_before_reboot ;
         /usr/bin/ip route > ip_route_before_reboot ;
         /usr/sbin/iptables-save  > iptables-save_V4_before_reboot ;
         /usr/sbin/ip6tables-save  > ip6tables-save_V6_before_reboot ;
         /usr/bin/ps ax -o pid,comm > Process_running_before_reboot ;
         /usr/bin/clear ;
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
        /usr/bin/ps ax -o pid,comm > Process_running_post_reboot ;
        exit ;;
     [Cc]* ) 
        /usr/bin/clear
        /usr/bin/echo ""
        /usr/bin/echo "###################################################################################################"
        /usr/bin/echo "# Before                                                     < >  After                           #"
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