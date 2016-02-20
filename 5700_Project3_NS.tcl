#############################################################################
# Project: Performance Analysis of TCP Variants
# Author: @Yifan Zhang (zhang.yifan2@husky.neu.edu)
# 
#
# topology:
#			N1                                    N4
#			  \									 /	
#			   \								/ 
#			    \							   /
#			     \							  / 
#			      N2------------------------N3
#			     /							  \ 	
#			    /							   \	
#			   /								\
#			  /									 \
#			N5									  N6			
#############################################################################

# create new simulator object
set ns [new Simulator]

#save reults to a file
set nf [open result.txt	w]

#define notes
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]

#Define a 'finish' procedure
proc finish {} {
        global ns nf
        $ns flush-trace
	#Close the trace file
        close $nf
	#Execute nam on the trace file
      #  exec nam out.nam &
      #  exit 0
}


# set bindwidth with 10 
set bindwidth 10
set defaultTCPVariant TCP
set defaultTCPSink TCPSink  
# connect each node
$ns duplex-link $n1 $n2 [expr $bindwidth]Mb 10ms DropTail
$ns duplex-link $n5 $n2 [expr $bindwidth]Mb 10ms DropTail
$ns duplex-link $n2 $n3 [expr $bindwidth]Mb 10ms DropTail
$ns duplex-link $n3 $n4 [expr $bindwidth]Mb 10ms DropTail
$ns duplex-link $n3 $n6 [expr $bindwidth]Mb 10ms DropTail


######################################################################################################################
# The one-way TCP sending agents currently supported are:															 #	
#																													 #
#    Agent/TCP - a ``tahoe'' TCP sender																			     #
#    Agent/TCP/Reno - a ``Reno'' TCP sender																			 #	
#    Agent/TCP/Newreno - Reno with a modification																	 # 	
#    Agent/TCP/Sack1 - TCP with selective repeat (follows RFC2018)													 #
#    Agent/TCP/Vegas - TCP Vegas																					 #	
#    Agent/TCP/Fack - Reno TCP with ``forward acknowledgment''														 #
#    Agent/TCP/Linux - a TCP sender with SACK support that runs TCP congestion control modules from Linux kernel	 #	
######################################################################################################################

# set n1 as tcp source
set tcpSourceN1 [new Agent/[expr $defaultTCPVariant]] 
$ns attach-agent $n1 $tcpSourceN1

#############################################################################
#The one-way TCP receiving agents currently supported are:					#
#																			#
#   Agent/TCPSink - TCP sink with one ACK per packet						#
#   Agent/TCPSink/DelAck - TCP sink with configurable delay per ACK         #
#   Agent/TCPSink/Sack1 - selective ACK sink (follows RFC2018)				#
#   Agent/TCPSink/Sack1/DelAck - Sack1 with DelAck							#
#############################################################################

# set n4 as tcp sink 
set tcpSinkN4 [new Agent/[expr $defaultTCPSink]]
$ns attach-agent $n4 $tcpSinkN4


#CBR (constant bit rate) with UDP connection
set udpCBR [new Application/traffic/CBR]
$udpCBR set packetSize_ 500
$udpCBR set interval_ 0.005
$udpCBR attach-agent $udpN2

#CBR source 
set udpN2 [new Agent/UDP]
$ns attach-agent $n2 $udpN2

#set udp sink for N3
set udpN3 [new Agent/Null]
$ns attach-agent $n3 $udpN3


#TCP connection 
$ns connect $tcpSourceN1 $tcpSinkN4
$ns connect $udpN2 $udpN3