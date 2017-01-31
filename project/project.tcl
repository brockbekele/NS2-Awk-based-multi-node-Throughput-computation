#Create a simulator object
set ns [new Simulator]

#Define different colors for data flows (for NAM)
$ns color 1 Blue
$ns color 2 orange

#Open the NAM and Trace files
set namfile [open namb.nam w]
#record all simulation traces in Nam input
$ns namtrace-all $namfile
set TraceFile [open traceb.tr w]
set trace_wnd [open cwnd.trc w]
set trace_seq [open sqn.trc w]
#where trace file will be wrriten
$ns trace-all $TraceFile

#Define a 'finish' procedure
proc finish {} {
        global ns namfile TraceFile trace_wnd trace_seq
#drop traces on respective file
        $ns flush-trace
        #Close the NAM and trace file
        close $namfile
        close $TraceFile
        close $trace_wnd
        close $trace_seq 
      
       #Execute NAM on the trace file
        exec nam namb.nam &
        exit 0
}

#Create six nodes
set S1 [$ns node]
set S3 [$ns node]
set R1 [$ns node]
set R2 [$ns node]
set D1 [$ns node]
set D3 [$ns node]
#giving shape for the nodes serving as router
 $R1 shape hexagon
 $R2 shape hexagon
# marking R1 and R2
$R1 add-mark color Red hexagon	
$R2 add-mark color Green hexagon
#Labeling  the six nodes
$S1 label "S1"
$S3 label "S3"
$D1 label "D1"
$R1 label "R1"
$R2 label "R2"
$D3 label "D3"

#Create links between the nodes
$ns duplex-link $S1 $R1 5Mb 10ms DropTail
$ns duplex-link $S3 $R1 5Mb 10ms DropTail
$ns duplex-link $R1 $R2 7Mb 100ms DropTail
$ns duplex-link $R2 $D1 5Mb 10ms DropTail
$ns duplex-link $R2 $D3 5Mb 10ms DropTail


#Nodes Orientation/oreintaion of links
$ns duplex-link-op $S3 $R1 orient right-up
$ns duplex-link-op $R1 $R2 orient middle
$ns duplex-link-op $S1 $R1 orient right-down
$ns duplex-link-op $R2 $D1 orient right-up
$ns duplex-link-op $R2 $D3 orient right-down
$ns queue-limit $R1 $R2 10
#Setup Flow 1 TCP connection
#creat a Tcp sourceagent and attach to Node 1(S1)
set tcp1 [new Agent/TCP]
$ns attach-agent $S1 $tcp1
#create A Tcp sink and attach to Node D1(destinoan1)
set sink1 [new Agent/TCPSink]
$ns attach-agent $D1 $sink1
#connect Tcp source to destination
$ns connect $tcp1 $sink1
#marking flow for the flow1
$tcp1 set fid_ 1


#Setup Flow 2 UDP connection
#create a udp agent and attach to Node(S3)
set udp1 [new Agent/UDP]
$ns attach-agent $S3 $udp1
#create a null agent/ traffic sink to node which D3
set null [new Agent/Null]
$ns attach-agent $D3 $null
#connect traffic source to sink
$ns connect $udp1 $null
#marking flow for the flow2
$udp1 set fid_ 2

#Setup a FTP over TCP connection
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1
$ftp1 set type_ FTP

#Setup a CBR over UDP connection
#create a CBR traffic source attach to udp1
set cbr1 [new Application/Traffic/CBR]
$cbr1 attach-agent $udp1
$cbr1 set type_ CBR
$cbr1 set packet_size_ 500
$cbr1 set interval_ 0.0008

# Sampling of the relevant parameters
proc record {} {
global ns tcp1 trace_wnd trace_seq 

      #the time which the procedure can be called again   
     set time 0.1
     
     set curr_seqn [$tcp1 set t_seqno_]
     set curr_cwnd [$tcp1 set cwnd_]
    
     #Get the current time 
     set now [$ns now]
      #Write/print the variables of now sequnc/wnd vs time 
      puts $trace_wnd "$now $curr_cwnd"
	puts $trace_seq "$now $curr_seqn"
      #Re-schedule the procedure
     $ns at [expr $now+$time] "record"
}


#Schedule events for the CBR and FTP agents
$ns at 0.001 "record"
$ns at 1.5 "$ftp1 start"
$ns at 0.0 "$cbr1 start"
$ns at 10.0 "$ftp1 stop"
$ns at 10.0 "$cbr1 stop"

#Call the finish procedure after 10 seconds of simulation time

$ns at 10.0 "finish"

#Run the simulation
$ns run

