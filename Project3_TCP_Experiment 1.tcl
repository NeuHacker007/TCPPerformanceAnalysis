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
set print 0
# recieve environment arguments
if {$argc > 0}
{
    if {[lindex $argv 0] == "v"} {
        set print 1
        puts "-v is seted -----> $print"      
    }
	set tcpVariant [lindex $argv 1]
    if {$print} {
        puts "tcpVariant ------------> $tcpVariant"
    }
    if {[llength $tcpVariant] == 0}
    {
        
        set tcpVariant Tahoe
        if {$print} {
            puts "tcp tcpVariant is not specified"
            puts "default -----------------> $tcpVariant"
        }
    }
	set CBRRate [lindex $argv 2]
    if {$print} {
        puts "CBRRate ------------> $CBRRate"
    }
    if {[llength $CBRRate] == 0} {
        set CBRRate 5
        if {$print} {
            puts "tcp CBRRate is not specified"
            puts "default -----------------> $CBRRate"
        }
    }
	set tcpStartTime [lindex $argv 3]
    if {$print} {
        puts "tcpStartTime ------------> $tcpStartTime"
    }
    if {[llength $tcpStartTime] == 0} {
        set tcpStartTime 5
        if {$print} {
            puts "tcpStartTime is not specified"
            puts "default -----------------> $tcpStartTime"
        }
    }
	set tcpEndTime [lindex $argv 4]
    if {$print} {
        puts "tcpEndTime ------------> $tcpEndTime"
    }
    if {[llength $tcpEndTime] == 0} {
        set tcpEndTime 5
        if {$print} {
            puts "tcpEndTime is not specified"
            puts "default -----------------> $tcpEndTime"
        }
    }
	set bandwidth [lindex $argv 5]
    if {$print} {
        puts "bandwidth ------------> $bandwidth"
    }
    if {[llength $bandwidth] == 0} {
        set bandwidth 5
        if {$print} {
            puts "bandwidth is not specified"
            puts "default -----------------> $bandwidth"
        }
    }
	set delay [lindex $argv 5]
    if {$print} {
        puts "delay ------------> $delay"
    }
    if {[llength $delay] == 0} {
        set delay 5
        if {$print} {
            puts "delay is not specified"
            puts "default -----------------> $delay"
        }
    }
}else{
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
}



# generate trace file
set tracefile [open epr1_result_$(tcpVariant)_$CBRRate_$bandwidth_$delay.tr w]
$ns trace-all $tracefile
if {$print} {
        puts "tracefile created"
}
set namTracefile [open epr1_result_$(tcpVariant)_$CBRRate_$bandwidth_$delay.nam w]
$ns trace-all $namTracefile
if {$print} {
        puts "namTracefile created"
}
proc finish {
    global ns tracefile namTracefile
    $ns flush-trace
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
$ns duplex-link $n1 $n2 orient left-up
$ns duplex-link $n5 $n2 orient left-down
$ns duplex-link $n2 $n3 orient right
$ns duplex-link $n3 $n4 orient right-up
$ns duplex-link $n3 $n6 orient right-down 


#set up udp 
set upd [new Agent/UDP]
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
if {$tcpVariant eq "Tahoe"} {
    set tcp [new Agent/TCP]
    if {$print} {
        puts "TCP Variant (Tahoe) ----------------> $tcpVariant"
    }
}elseif{$tcpVariant eq "Reno"}{
    set tcp [new Agent/TCP/Reno]
    if {$print} {
        puts "TCP Variant (Reno) ----------------> $tcpVariant"
    }
}elseif{$tcpVariant eq "NewReno"}{
    set tcp [new Agent/TCP/Newreno]
    if {$print} {
        puts "TCP Variant (Newreno) ----------------> $tcpVariant"
    }
}elseif {$tcpVariant eq "Vegas"}{
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
$ns at ${tcpStartTime} "$ftp start"
$ns at ${tcpEndTime} "$ftp stop"
$ns at 20.0 "$cbr stop"

$ns at 20.0 "finish"

$ns run 
if {$print} {
        puts "ns running"
}