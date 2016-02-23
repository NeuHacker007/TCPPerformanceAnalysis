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
$ns color 1 Blue
$ns color 2 Red
#save reults to a file
set TraceFile [open e1-1.tr	w]
$ns trace-all $TraceFile

set NamFlie [open e1-1.nam w]
$ns namtrace-all $NamFlie

#define notes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]

#Define a 'finish' procedure
proc finish {} {
        global ns nf NamFlie
		puts "we are now in finish procedure"
        $ns flush-trace
		puts "trace file is flushed"
	#Close the trace file
        close $TraceFile
		puts "trace file is closed"
	#Execute nam on the trace file
	  puts "nam invoked"
      exec nam e1-1.nam &
      exit 0
}


# set bindwidth with 10 
#set bindwidth 10
#set defaultTCPVariant TCP
#set defaultTCPSink TCPSink
# topology:
#			N0                                    N3
#			  \									 /	
#			   \								/ 
#			    \							   /
#			     \							  / 
#			      N1------------------------N2
#			     /							  \ 	
#			    /							   \	
#			   /								\
#			  /									 \
#			N4									  N5			
#############################################################################  
# connect each node
$ns duplex-link $n0 $n1 10Mb 10ms DropTail
$ns duplex-link $n1 $n2 10Mb 10ms DropTail
$ns duplex-link $n2 $n3 10Mb 10ms DropTail
$ns duplex-link $n1 $n4 10Mb 10ms DropTail
$ns duplex-link $n2 $n5 10Mb 10ms DropTail

puts "nodes link setted up"
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
set tcpSource [new Agent/TCP]
$tcpSource set fid_ 1 
$ns attach-agent $n0 $tcpSource
puts "tcp source setted up"
#############################################################################
#The one-way TCP receiving agents currently supported are:					#
#																			#
#   Agent/TCPSink - TCP sink with one ACK per packet						#
#   Agent/TCPSink/DelAck - TCP sink with configurable delay per ACK         #
#   Agent/TCPSink/Sack1 - selective ACK sink (follows RFC2018)				#
#   Agent/TCPSink/Sack1/DelAck - Sack1 with DelAck							#
#############################################################################

# set n4 as tcp sink 
set tcpSink [new Agent/TCPSink]
$ns attach-agent $n3 $tcpSink
puts "TCPSink setted up"
$ns connect $tcpSource $tcpSink
puts "TCP conneted"

set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcpSource
$ftp1 set type_ FTP 
#CBR source 
set udp1 [new Agent/UDP]
$udp1 set fid_ 2
$ns attach-agent $n1 $udp1
puts "UDP1 source set up"
#CBR (constant bit rate) with UDP connection
set udpCBR [new Application/Traffic/CBR]
$udpCBR set type_ CBR
$udpCBR set packetSize_ 500
$udpCBR set interval_ 0.005
$udpCBR attach-agent $udp1
puts "CBR setup"


#set udp sink for N2
set udpSink [new Agent/Null]
$ns attach-agent $n2 $udpSink

#UDP connection 
$ns connect $udp1 $udpSink
puts "UDP connected"

$ns at 0.5 "$udpCBR start"
$ns at 5.0 "$ftp1 start"
$ns at 10.0 "$udpCBR stop"
$ns at 20.5 "$ftp1 stop"

#Call the finish procedure after 5 seconds of simulation time
$ns at 25.0 "finish"

#$ns at 0.0 "$udpCBR start"
#puts "udpCBR started"
#$ns at 5.0 "$tcpSourceN1 start"
#puts "tcp started"
#$ns at 50.0 "udpCBR stop"
#puts "udpCBR stop"
#$ns at 55.0 "$tcpSourceN1 stop"
#puts "TCP stop"

#$ns at 60 "finish"
#puts "run before"
#$ns make
$ns run
#puts "run after" 
