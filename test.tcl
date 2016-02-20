# Create a ns object
set ns [new Simulator]

$ns color 1 Blue
$ns color 2 Red

# Open the Trace files
set TraceFile [open outudp.tr w]
$ns trace-all $TraceFile

# Open the NAM trace file
set NamFile [open outudp.nam w]
$ns namtrace-all $NamFile

set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]

$ns duplex-link $n0 $n2 2Mb 10ms DropTail
$ns duplex-link $n1 $n2 2Mb 10ms DropTail
$ns duplex-link $n2 $n3 0.25Mb 100ms DropTail # bottleneck link
$ns duplex-link $n3 $n4 2Mb 10ms DropTail
$ns duplex-link $n3 $n5 2Mb 10ms DropTail

$ns queue-limit $n2 $n3 20

$ns duplex-link-op $n0 $n2 orient right-down
$ns duplex-link-op $n1 $n2 orient right-up
$ns duplex-link-op $n2 $n3 orient right
$ns duplex-link-op $n3 $n4 orient right-up
$ns duplex-link-op $n3 $n5 orient right-down

#TCP N0 and N4
set tcp [new Agent/TCP/Newreno]
$ns attach-agent $n0 $tcp

set sink [new Agent/TCPSink/DelAck]
$ns attach-agent $n4 $sink

$ns connect $tcp $sink
$tcp set fid_ 1

#FTP TCP N0 and N4
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ftp set type_ FTP

#UDP N1 and N5
set udp [new Agent/UDP]
$ns attach-agent $n1 $udp
set null [new Agent/Null] 
$ns attach-agent $n5 $null
$ns connect $udp $null
$udp set fid_ 2

#CBR N1 and N5
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set type_ CBR
$cbr set packet_size_ 500
$cbr set interval_ 0.005

$ns duplex-link-op $n2 $n3 queuePos 0.5

$ns at 0.1 "$ftp start"
$ns at 10.0 "$cbr start"
$ns at 40.0 "$cbr stop"
$ns at 50.0 "$ftp stop"

proc finish {} {
        global ns TraceFile NamFile 
        $ns flush-trace
        close $TraceFile
        close $NamFile
        exec nam outudp.nam &
        exit 0
}

$ns at 60.0 "finish"
$ns run