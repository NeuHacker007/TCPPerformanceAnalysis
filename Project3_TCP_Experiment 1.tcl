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
#create a simulator object
set ns [new Simulator]
$ns color 1 Blue
$ns color 2 Red
set print 1
# recieve environment arguments

    if {$print} {
        puts "no args entry"
    }
    # TCP means it use default Tahoe implementation
    # CBRRate 5MB
    # tcpStartTime 5s after NS running 
    # tcpEndTime 20s after NS running
    # bandwidth 10 MB
    # delay 10ms
    set tcpVariant Tahoe
    set CBRRate 5
    set tcpStartTime 5.0
    set tcpEndTime   15.0
    set bandwidth 10 
    set delay 10

    if {$print} {
        puts "parameter setted up"
    }




# generate trace file
set tracefile [open epr1_result_$tcpVariant\_$CBRRate\_$bandwidth\_$delay\.tr w]
$ns trace-all $tracefile
if {$print} {
        puts "tracefile created"
}
set namTracefile [open epr1_result_$tcpVariant\_$CBRRate\_$bandwidth\_$delay\.nam w]
$ns namtrace-all $namTracefile
if {$print} {
        puts "namTracefile created"
}
proc finish {} {
    global print ns tracefile namTracefile
    $ns flush-trace
	if {$print} {
	 puts "trace flushed"
	}
    close $tracefile
    close $namTracefile
    exit 0
}
# define nodes
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]
if {$print} {
        puts "bandwidth -----------> $bandwidth"
        puts "delay --------------------> $delay"
}
#link the nodes with 10MB bandwidth 10ms delay queue type is DropTail 
$ns duplex-link $n1 $n2 [expr $bandwidth]Mb [expr $delay]ms DropTail
$ns duplex-link $n2 $n3 [expr $bandwidth]Mb [expr $delay]ms DropTail
$ns duplex-link $n3 $n4 [expr $bandwidth]Mb [expr $delay]ms DropTail
$ns duplex-link $n5 $n2 [expr $bandwidth]Mb [expr $delay]ms DropTail
$ns duplex-link $n3 $n6 [expr $bandwidth]Mb [expr $delay]ms DropTail   

#define nodes position
#$ns duplex-link $n1 $n2 orient right-up 
#$ns duplex-link $n5 $n2 orient right-down
#$ns duplex-link $n2 $n3 orient right
#$ns duplex-link $n3 $n4 orient right-up
#$ns duplex-link $n3 $n6 orient right-down 


#set up udp 
set udp [new Agent/UDP]
$ns attach-agent $n2 $udp
$udp set fid_ 1

set null [new Agent/Null]
$ns attach-agent $n3 $null

#connect udp 
$ns connect $udp $null
if {$print} {
        puts "udp connected"
}

#CBR(common bit rate) settings
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set type_ CBR
$cbr set rate_ ${CBRRate}Mb
$cbr set packetSize_ 500
$cbr set interval_ 0.005

if {$print} {
        puts "cbr setted up"
        puts "tcp variant $tcpVariant"
}
#TCP settings 
if {$tcpVariant=="Tahoe"} {
    set tcp [new Agent/TCP]
    if {$print} {
        puts "TCP Variant (Tahoe) ----------------> $tcpVariant"
    }
} elseif {$tcpVariant=="Reno"} {
    set tcp [new Agent/TCP/Reno]
    if {$print} {
        puts "TCP Variant (Reno) ----------------> $tcpVariant"
    }
} elseif {$tcpVariant=="NewReno"} {
    set tcp [new Agent/TCP/Newreno]
    if {$print} {
        puts "TCP Variant (Newreno) ----------------> $tcpVariant"
    }
} elseif {$tcpVariant=="Vegas"} {
    set tcp [new Agent/TCP/Vegas]
    if {$print} {
        puts "TCP Variant (Vegas) ----------------> $tcpVariant"
    }
}

$tcp set fid_ 2
$ns attach-agent $n1 $tcp

set tcpSink [new Agent/TCPSink]
$ns attach-agent $n4 $tcpSink
$ns connect $tcp $tcpSink
if {$print} {
        puts "tcp connected"
}
# set up tcp Application
set ftp [new Application/FTP]
$ftp attach-agent $tcp
if {$print} {
        puts "ftp connected"
        puts "TCP start time ---------> $tcpStartTime"
        puts "TCP end time ---------> $tcpEndTime"
}
$ns at 0.0 "$cbr start"
$ns at $tcpStartTime "$ftp start"
$ns at $tcpEndTime "$ftp stop"
$ns at 20.0 "$cbr stop"

$ns at 20.0 "finish"

$ns run 
if {$print} {
        puts "ns running"
}
