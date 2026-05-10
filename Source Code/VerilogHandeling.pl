#!/usr/bin/perl
no warnings;
require "ProbablityComputing.pl";
use Term::ANSIColor qw(:constants);
use List::Util qw[min max];
print("\n\n");
print(YELLOW,".....Verilog File Processing...\n\n");
open(data1,"<config.txt");
while($line=<data1>){
	if($line=~m /Design_Name/x){
     ($Design)=$line=~m /Design_Name=\s*(\w+)/x;
	 $Design=$Design.'.v';
	}	
	elsif($line=~m /Test_Bench/x){
     ($TB_Design)=$line=~m /Test_Bench=\s*(\w+)/x;
	 $TB_Design=$TB_Design.'.v';
	}
	elsif($line=~m /Probability_Threshold/x){
     ($Pth)=$line=~m /Probability_Threshold=\s*(\d+.\d+)/x;
	}	
	elsif($line=~m /NumOfTest/x){
     ($NumTest)=$line=~m /NumOfTest=\s*(\d+)/x;
	}
	elsif($line=~m /CycleTime/x){
     ($CycleTime)=$line=~m /CycleTime=\s*(\d+)/x;
	}
	else{
		
	}
}

open(data,"<$Design");
open(data1,">InfoGate.out");
no warnings;
$count=0;
while(<data>){
	$line=$_;chomp($line);
#======================= Input Extracting========================================
    if($line=~m /^\s*input/x){
		$line=~s /input \s+//x;
		$line=~s /;//x;
		@inputs_arr=split(',',$line);
    		while(<data>){#input While
			 $line=$_; chomp($line);
			if($line=~m /^\s*output/x){
				$line=~s /^\s*output\s+//x;$line=~s/;//x;
				@outputs_arr=split(',',$line);
				last;
			}
			else{
				$line=~s/^\s*//x;
				$line=~s/;//x; 
			@inputs_arr=(@inputs_arr, split(',', $line));
				}
		}
foreach $var (@inputs_arr){
	  $var2=$var;
      $info_h{$var2}={	  "type"=> "INPUT1",
	                      "probablity"=>$prob_h{$var},
						  "fanin1"=> undef,
						  "fanin2"=> undef,
						  "fanin3"=> undef,
						  "fanin4"=> undef,
						  "fanin5"=> undef,
						  "fanin6"=> undef,
						  "fanin7"=> undef,
						  "fanin8"=> undef,				  
						  "gatenumber"=>"NA",
						  "map" => undef,
						  "#fanin" => 0, 
						  "MinDepth"=> 0,
						  "MaxDepth"=> 0}; # all the inputs have MaxDepth equal to zero and other depth is evaluated
						                   # based on the value of pervious nodes
}	
#======================= Output Extracting=======================================================		
		  while(<data>){ #output While
			   $line=$_; chomp($line);
			if($line=~m /^\s*wire/x){
				$line=~s /^\s*wire\s+//x;
				@wires_arr=split(',',$line);
				last;
			}
			else{
			  $line=~s/^\s*//x;$line=~s/;//x;
			  @outputs_arr=(@outputs_arr, split(',', $line));
			 }
		}
#=========================Wire Extracting====================================================		
		  while(<data>){ #Wire While
			   $line=$_; chomp($line);
			if($line=~m /^\s*nand|and|or|nor|buf|not|xor|xnor/x){
				last;
			}
			else{
			  $line=~s/^\s*//x;$line=~s/;//x;
			  @wires_arr=(@wires_arr, split(',', $line));
			 }
		}
	# all the nodes in Nodes
	@Nodes=(@inputs_arr,@wires_arr,@outputs_arr); # all the nodes
	@INTNodes=(@wires_arr,@outputs_arr);# internal Nodes

#======================== Gate processing==================================================	    
	}
	if($line=~m /^\s*nand|and|or|nor|buf|not|xor|xnor/x){
		$count++;
		  my($type,$numb)=$line=~m /^\s*\w+ \s+(\w+)_(\d+)/x; # extract type and index of gate
		  my(@fanin)=$line=~m /(\w+),/xgi;my($var)=$line=~m /(\w+)\)/xgi;@fanin=(@fanin,$var);# extract all the inputs
		  $NumofFanin=$#fanin;  # fanin[0]:;out , fanin[1..$NumofFanin]::inputs # extract number of inputs
		  $out=$fanin[0];# extarct output node
		  shift(@fanin);$max=0; # discard the first element in @fanin array becuase it is ouput
		  foreach $var (@fanin){ # processing on inputs of gate (in this case we have only two inputs due to conversion)
			  if(defined $info_h{$var}{"MaxDepth"}){
				  if($info_h{$var}{"MaxDepth"}>$max){
					  $max=$info_h{$var}{"MaxDepth"};
					  }
			   }
			   else{
				 #  push(@undef_depth, $var) unless grep{$_ eq $var} @undef_depth; # aviod duplicate value for string use eq instead of ==
				   push(@undef_depth, $out) unless grep{$_ eq $out} @undef_depth;
				   $max=undef;
				   last;
				   }
		   }
		   
		   if(defined $max){
			   $max=$max+1;# if depth of inputs of gate is defined, so maximum depth of out is maximum depth of
			               # inputs plus one
			   }
			   # adding information related to the node $out
		        $info_h{$out}={"type"=> $type,
							   "probablity"=>$prob_h{$out},
								"fanin1"=> $fanin[0],
								"fanin2"=> $fanin[1],
								"fanin3"=> $fanin[2],
								"fanin4"=> $fanin[3],
								"fanin5"=> $fanin[4],
						        "fanin6"=> $fanin[5],
								"fanin7"=> $fanin[6],
								"fanin8"=> $fanin[7],
								"gatenumber"=>$numb,
								"map" => undef,
								"#fanin" =>  $NumofFanin,
								"MinDepth"=> 0,
								"MaxDepth"=> $max};
    }
}
close data;


$UndefSize=scalar @undef_depth;
#print("undefind depth nodes:::\n @undef_depth\n");
#print("Size:::$UndefSize\n");

while($UndefSize!=0){
	foreach $tmp (@undef_depth){
		#print(CYAN,"Process($tmp)...\n");
		$fanin1=$info_h{$tmp}{"fanin1"};
		$fanin2=$info_h{$tmp}{"fanin2"};
		if(! grep( /^$fanin1$/, @undef_depth ) && ! grep( /^$fanin2$/, @undef_depth )){ # so we can calculate the depth
			if($info_h{$fanin1}{"MaxDepth"} >= $info_h{$fanin2}{"MaxDepth"}){
				$info_h{$tmp}{"MaxDepth"}=$info_h{$fanin1}{"MaxDepth"} +1;
			}
			else{
				$info_h{$tmp}{"MaxDepth"}=$info_h{$fanin2}{"MaxDepth"} +1;
			}
		  @undef_depth = grep {!/$tmp$/} @undef_depth;
		  $UndefSize=scalar @undef_depth;	
		} 
	}
}

@undef_depth= grep { @undef_depth[$_] eq $tmp} 0..$#undef_depth;

foreach $nem(@INTNodes){
  if($info_h{$nem}{"MaxDepth"} == 0){
	  $fanin1=$info_h{$nem}{"fanin1"};
	  $fanin2=$info_h{$nem}{"fanin2"};
	  if($info_h{$fanin1}{"MaxDepth"} >= $info_h{$fanin2}{"MaxDepth"}){
				$info_h{$nem}{"MaxDepth"}=$info_h{$fanin1}{"MaxDepth"} +1;
			}
			else{
				$info_h{$nem}{"MaxDepth"}=$info_h{$fanin2}{"MaxDepth"} +1;
			}
	 }
}

foreach $nem(@INTNodes){
  if($info_h{$nem}{"MaxDepth"} == 0){
#	  print(BLUE,"$nem\n");
	 }
}
#****************** fanout extraction**********************************************************
open(data,"<$Design");
open(data2,">fanout.out");
no warnings;
print(data2 "Node \t   #number \t fanout1 \t fanout2 \t fanout3 \t fanout4 \t fanout5 \t fanout6 \t fanout7 \t fanout8 \t \n");
print(data2"=====================================================================================================================================\n");

#nor NOR2_144 (N198, N115, N151);
foreach $elem(@Nodes){
	@fanouts=(); # for new $elem
	#print("\nProcessing node::$elem\n");
	open(data,"<$Design");
	while($line=<data>){
		if($line=~m /,\s+ $elem, | ,\s+ $elem\)/x){
		    my($out)=$line=~m /\((\w+),/x;
			push(@fanouts, $out);
		}
	}
	$NumFanout=scalar (@fanouts);
	#print("$elem ::number of fanout::\n $NumFanout\n");
	$fanout_h{$elem}={		    "fanout1"=> $fanouts[0],
							    "fanout2"=> $fanouts[1],
							    "fanout3"=>$fanouts[2],
								"fanout4"=> $fanouts[3],
								"fanout5"=> $fanouts[4],
								"fanout6"=> $fanouts[5],
								"fanout7"=> $fanouts[6],
						        "fanout8"=> $fanouts[7],
								"fanout9"=> $fanouts[8],
								"fanout10"=> $fanouts[9],
								"fanout11"=> $fanouts[10],
								"fanout12"=> $fanouts[11],
								"fanout13"=> $fanouts[12],
								"fanout14"=> $fanouts[13],
								"fanout15"=> $fanouts[14],
								"fanout16"=> $fanouts[15],
								"fanout17"=> $fanouts[16],
								"fanout18"=> $fanouts[17],
								"fanout19"=> $fanouts[18],
								"fanout20"=> $fanouts[19],
								"fanout21"=> $fanouts[20],
								"fanout22"=> $fanouts[21],
								"#fanout"=>$NumFanout};
printf (data2 "%-7s \t %-5d \t %-7s \t %-7s \t %-7s \t %-7s \t %-7s \t %-7s \t %-7s \t %-7s \t %-7s\n",
		   $elem,$fanout_h{$elem}{"#fanout"}, $fanout_h{$elem}{"fanout1"},$fanout_h{$elem}{"fanout2"},$fanout_h{$elem}{"fanout3"},
		   $fanout_h{$elem}{"fanout4"},$fanout_h{$elem}{"fanout5"},$fanout_h{$elem}{"fanout6"},$fanout_h{$elem}{"fanout7"},
		   $fanout_h{$elem}{"fanout8"},$fanout_h{$elem}{"fanout9"});
close data;
}
#============== Map file Generation ===============================================
print(YELLOW,"\t.....Map File Generation..\n\n");
open(myfile,">Design.map");
$j=0;
print(myfile "Node\t Map\n==================\n");
 foreach $node(@Nodes){
	 $j++;
	 $map_h{$node}=$j;
	 $info_h{$node}{"map"}=$j;
	 print(myfile "$node\t\t  $j\n");
	 }
$NumVar=$j;	
print("Total veriable in map file::$NumVar\n");
%map_rev_h=reverse %map_h;
close myfile;
print(YELLOW,"\t.....Map File Generation Done..\n\n");

####### Display to shell command
#			print("Inputs:::\n @inputs_arr\n");
#			print("outputs:::\n @outputs_arr\n");
#			print("Wires:::\n @wires_arr\n");
#			print("Updated undefind depth nodes:::\n @undef_depth\n");
####### Display to information.out file
	print("=====================================================================================================================================\n");
    print(CYAN,"#     Node   #fanin\t  probablity\t type\t  MaxDepth\tfan_in1  fan_in2\tTR\tTC\t\tT0\tT1\tfanout\n");
	print(WHITE,"===========================================================================================================================================\n");
    print(data1 "#     Node   #fanin\t  probablity\t type\t  MaxDepth\tfan_in1  fan_in2\tTR\tTC\t\tT0\tT1\tfanout\n");

foreach $var (@Nodes){
	no warnings;
	printf (data1 "%-5d  %-7s\t%-10d%-f \t\%-5s \t\t%-5d \t%-10s  %-10s  %-f  %-7.0f \t%-6d\t%-6d\n",
		    $info_h{$var}{"map"},$var,$info_h{$var}{"#fanin"},$info_h{$var}{"probablity"},
	       $info_h{$var}{"type"}, $info_h{$var}{"MaxDepth"},
		   $info_h{$var}{"fanin1"}, $info_h{$var}{"fanin2"},$TR_h{$var},$TC_h{$var},$T0_h{$var}/1000,$T1_h{$var}/1000);
	
	printf ("%-5d  %-7s\t%-10d%-f \t\%-5s \t\t%-5d \t%-10s  %-10s  %-f  %-7.0f \t%-6d\t%-6d\n",
		    $info_h{$var}{"map"},$var,$info_h{$var}{"#fanin"},$info_h{$var}{"probablity"},
	       $info_h{$var}{"type"}, $info_h{$var}{"MaxDepth"},
		   $info_h{$var}{"fanin1"}, $info_h{$var}{"fanin2"},$TR_h{$var},$TC_h{$var},$T0_h{$var}/1000,$T1_h{$var}/1000);
	}

print(YELLOW,"....End of Verilog File Processing...\n\n");

close data;
close data1;

#==============================================================================================
open(data1,"+>>InfoGate.out");
@SortPro=sort({$prob_h{$a} <=> $prob_h{$b}}keys %prob_h);
#print("\n========================================================\nSorting internal Nodes based on probablity::\n @SortPro\n");

$i=0;$j=0;
### Desiplay Low and High probality Nodes
foreach $var(@SortPro){
	if($prob_h{$var}<=$Pth && $prob_h{$var}>0){
		$LowTr[$i++]=$var;
		}
	elsif($prob_h{$var}>$Pth){
		if($info_h{$var}{"type"} ne INPUT1){ #remove node labled as input
			 $HighTr[$j++]=$var;
			}
		}
	}
	my $numcols = 0;
$LTnum=scalar @LowTr;
$HTnum=scalar @HighTr;
print("\nLow Transition Nodes(Pth=$Pth)::\n@LowTr\n");
print(data1 "\n\nLow Transition Nodes(Pth=$Pth)::\n@LowTr\n");
print(data1 "#LT Node(Pth=$Pth)::$LTnum\n");
print(WHITE,"#LT Node(Pth=$Pth)::",GREEN,"$LTnum\n");

print("\n\nHigh Transition Nodes(Pth=$Pth)::\n@HighTr\n");
print(data1 "\n\nHigh Transition Nodes(Pth=$Pth)::\n@HighTr\n");
print(data1 "#HT Node(Pth=$Pth)::$HTnum\n");
print(WHITE,"#HT Node(Pth=$Pth)::",GREEN,"$HTnum\n");

#print(data1 "========================================================\n");
#print(data1 "\nStucked intermidiate nodes::\nNodes\tStucked in\n=====================================================\n");
#print("\nStucked intermidiate nodes::\nNodes\tStucked in\n================================================\n");
#foreach $var(keys %stucked_h){
#	    push(@stucked,$var);# stucked array contan node that are strucked at specefic value
#		print("Stucked nodes::\n,$var\t$stucked_h{$var}");
#		printf(data1 "%-10s \t %d \n",$var,$stucked_h{$var});
#	}
#close data1;

# Analyze number of transition in LT,HT and inside trojan
#$TCLT=0;
#$TCHT=0;
#$TCTOT=0;
#foreach $elem (@LowTr){
#	$TCLT=$TCLT+ $TC_h{$elem};
#	$TCTOT=$TCTOT+ $TC_h{$elem};
#	}
#foreach $elem (@HighTr){
#	$TCHT=$TCHT+ $TC_h{$elem};
#	$TCTOT=$TCTOT+ $TC_h{$elem};
#	}
#print(WHITE,"Number of Transition on LT::",GREEN,"$TCLT",WHITE,"==> Ave=",$TCLT/$LTnum,"\n");
#print(WHITE,"Number of Transition on HT::",GREEN,"$TCHT",WHITE,"==> Ave=",$TCHT/$HTnum,"\n");
#print(WHITE,"Number of Total Transition::",GREEN,"$TCTOT",WHITE,"==> Ave=",$TCTOT/($LTnum+$HTnum),"\n");













