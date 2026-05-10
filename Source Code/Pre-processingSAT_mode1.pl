#!/usr/bin/perl
require "VerilogHandeling.pl";
require "ProbablityComputing.pl";
no warnings;
use Term::ANSIColor qw(:constants);
use List::Util qw[min max];
print (YELLOW,".... Pre-processing step of SAT based Desing based on minimum depth selection...\n\n");

 @X=@LowTr; #Set the low transition nodes as X-labeled
 # Adding output node into X category for more observability
# foreach $t(@outputs_arr){
#	 push(@X,$t) unless grep{$_ eq $t} @X;
#}
 #@X=(G10,G9,G16,G15,G13);# Low probablity nodes(X-nodes)

# Block1--> Create @X_sort:contains the X-nodes in pre
#			Create @valueDepth:contains depth of X-nodes          
 foreach $var(@X){
	#$Depth_h{$var}=$info_h{$var}{"MaxDepth"};
	push(@X_sort,$var);
	push(@vauleDepth,$info_h{$var}{"MaxDepth"});
	 }
# Sorting X_sort based on @valueDepth array and print both of them
#@X_sort=sort({$Depth_h{$b} <=> $Depth_h{$a}}keys %Depth_h);# sort based on Descending order
my @idx = sort { @vauleDepth[$b] <=> @vauleDepth[$a] } 0 .. $#vauleDepth;
@vauleDepth = @vauleDepth[@idx];
@X_sort = @X_sort[@idx];
#print(WHITE,"Sort LowTr Nodes based on Depth (Descending)::\n @X_sort\n");
#print(WHITE,"MaxDepth::\n@vauleDepth\n");

######## Processing X array ####################################################### 
$m=1;# for printing steps
foreach $var(@X_sort){
#print(GREEN,"$m) Processing::$var\n");$m++;
   ($TYPE)=$info_h{$var}{"type"}=~m/(\w+)\d/x;# $TYPE:AND,NAND,NOT,BUF,XOR,NOR,INPUT
 #  print(WHITE,"'$TYPE'\n");
   
 ##################################################################################3
if($TYPE eq INPUT){ # checking type of X-node
		next;
		}
elsif($TYPE eq AND ||$TYPE eq OR||$TYPE eq NAND ||$TYPE eq NOR){
#processing #number of fanin contain X lable
	my $cnt=0;
	for($i=1;$i<=$info_h{$var}{"#fanin"};$i=$i+1){
		push(@fan_arr,$info_h{$var}{"fanin"."$i"}); # @fan_arr contains all fanins of node $var
		if ( grep( /^$info_h{$var}{"fanin"."$i"}$/, @X_sort ) ) {#fan_in that labed by X value
			$cnt=$cnt+1;
		   push(@fan_arrx,$info_h{$var}{"fanin"."$i"})unless grep{$_ eq $info_h{$var}{"fanin"."$i"}} @fan_arrx;
		}# we add the X-labeld fanin to @fan_arrx array => @fan_arrx contain fanins that have X-labeld
	}
#	print(WHITE,"Fan_ins::@fan_arr\n");# contains fan_in of processing node
#	print(WHITE,"#fanins that have X label::$cnt\n");# contains number of X-labeld fan_in 
#	print(WHITE,"inpust that have X lable::@fan_arrx\n");# contains x-labeld fan_in of processing node

#block2--> Cnt>1 confilict
	if ($cnt>1){ # if two or more fanin inputs be X we have confilict on fanout node
#		print(RED,"Confilict X on $var----> number of X inputs::$cnt-->inputs::@fan_arrx\n");
		push(@X_conflict, $var)unless grep{$_ eq $var} @X_conflict;
		#$confilict_h{$var}='X';# add to the confilict hash--> type of confilict is 'X'
	}
#block2--> Cnt==0 Select between inputs with minimum depth
#attention: stucked node shouldnot be selected
	elsif($cnt==0){ 
		
		if (grep( /^$fan_arr[0]$/, @stucked) ) {
			$select=$fan_arr[1];
#			print(RED,"$fan_arr[0] is a stucked node at",$stucked_h{$fan_arr[0]},"\n");
			}
		elsif (grep( /^$fan_arr[1]$/, @stucked) ) {
			$select=$fan_arr[0];
#			print(RED,"$fan_arr[1] is a stucked node at",$stucked_h{$fan_arr[1]},"\n");
			}
#		elsif(scalar @{$Baninfo_h{$fan_arr[0]}} < scalar @{$Baninfo_h{$fan_arr[1]}}){
#			$select=$fan_arr[0];
#			print(CYAN,"$fan_arr[0] has less shared nodes::@{$Baninfo_h{$fan_arr[0]}}","\n");
#			}
#		elsif(scalar @{$Baninfo_h{$fan_arr[0]}} > scalar @{$Baninfo_h{$fan_arr[1]}}){
#			$select=$fan_arr[1];
#			print(CYAN,"$fan_arr[1] has less shared nodes::@{$Baninfo_h{$fan_arr[1]}}","\n");
#			}	
		
		else{
			  if($info_h{$fan_arr[0]}{"MaxDepth"} < $info_h{$fan_arr[1]}{"MaxDepth"}){
				  $select=$fan_arr[0];
				  }
			  else{
				  $select=$fan_arr[1];
				  }	  
			}	
		
        @ForbiddenNodes=grep (!/$select/,@fan_arr);# contains fanin nodes except $select, these nodes shouldnt be selected in next steps
		$BanInp= @ForbiddenNodes[0];# current forbidden node (only one)
			# checking difftype conflict 
			if( grep( /^$BanInp$/, @FN)){ 
#				print(BLUE,"Warning::$BanInp is shared forbidden node(SFN)=>input of $var and @{$Baninfo_h{$BanInp}}\n");
				  foreach $rem(@{$Baninfo_h{$BanInp}}){ # @{$Baninfo_h{$BanInp}} is an array that contains fanout of gate connecting to the forbidden node
					  if(($info_h{$var}{"type"} ne $info_h{$rem}{"type"})){
						  $type1=$info_h{$var}{"type"}; $type2=$info_h{$rem}{"type"};
						   if(($type1 eq AND2 && $type2 ne NAND2)||($type1 eq NAND2 && $type2 ne AND2)||($type1 eq OR2 && $type2 ne NOR2)||($type1 eq NOR2 && $type2 ne OR2)){
#							  print(RED,"Type($var)=>",$info_h{$var}{"type"},"\n",RED,"Type($rem)=>",$info_h{$rem}{"type"},"\n"); 
							  push(@DiffType_conflict,$rem) unless grep{$_ eq $rem} @DiffType_conflict;
							 # $info_h{$var}{"MaxDepth"}>$info_h{$rem}{"MaxDepth"}? push(@DiffType_conflict,$var):push(@DiffType_conflict,$rem);
							}
					    }	 
				 }
			} 
			# @FN contains all the forbidden nodes
            # @forbiddenNodes contains only current forbidden node			
#		print(YELLOW"\xE2\x9C\x94 Selected Node as X::$select\n");
		# check if the selected node was chosen as forbidden nodes in pervious processes
		if( grep( /^$select$/, @FN)){
#		  	print(RED,"value $select was used before as non-x-->X_Conflict on @{$Baninfo_h{$select}}\n");
			 foreach $kem(@{$Baninfo_h{$select}}){
				push(@X_conflict, $kem)unless grep{$_ eq $kem} @X_conflict;
			 }
		}
		push(@{$Baninfo_h{$BanInp}},$var) unless grep{$_ eq $var} @{$Baninfo_h{$BanInp}};
		push(@FN,$BanInp) unless grep{$_ eq $BanInp} @FN;

		if (!grep( /^$select$/, @X_sort ) ) {	# serach if $select is not in @X_sort
			        push(@X_sort,$select);# push a new node to X_sort that there isn't in X_sort
	                push(@vauleDepth,$info_h{$select}{"MaxDepth"});
				  	### Sort Descending		
					my @idx = sort { @vauleDepth[$b] <=> @vauleDepth[$a] } 0 .. $#vauleDepth; # sort an array based on another array
					@vauleDepth = @vauleDepth[@idx];
					@X_sort = @X_sort[@idx];
		}				
	}
#===============================================================================================
	else{# cnt==1
		$select=$fan_arrx[0];
#		print(YELLOW"\xE2\x9C\x94 Selected Node as X::$select\n");
		@ForbiddenNodes=grep (!/$select/,@fan_arr);
		$BanInp= @ForbiddenNodes[0];# forbidden node
			
			if( grep( /^$BanInp$/, @FN)){ 
#				print(BLUE,"Warning::$BanInp is input of $var and @{$Baninfo_h{$BanInp}}\n");
				  foreach $rem(@{$Baninfo_h{$BanInp}}){
					  if(($info_h{$var}{"type"} ne $info_h{$rem}{"type"})){
						  $type1=$info_h{$var}{"type"}; $type2=$info_h{$rem}{"type"};
						   if(($type1 eq AND2 && $type2 ne NAND2)||($type1 eq NAND2 && $type2 ne AND2)||($type1 eq OR2 && $type2 ne NOR2)||($type1 eq NOR2 && $type2 ne OR2)){
#							  print(RED,"Type($var)=>",$info_h{$var}{"type"},"\n",RED,"Type($rem)=>",$info_h{$rem}{"type"},"\n"); 
							  push(@DiffType_conflict,$rem) unless grep{$_ eq $rem} @DiffType_conflict;
							 # $info_h{$var}{"MaxDepth"}>$info_h{$rem}{"MaxDepth"}? push(@DiffType_conflict,$var):push(@DiffType_conflict,$rem);
							}
					    }	 
				 }
			} 
					 
		push(@{$Baninfo_h{$BanInp}},$var) unless grep{$_ eq $var} @{$Baninfo_h{$BanInp}};
		push(@FN,$BanInp) unless grep{$_ eq $BanInp} @FN;
	}	
 }
 
 
elsif($TYPE eq NOT||$TYPE eq BUFF){
	
	 if($TYPE eq NOT){
	  push(@NOT_conflict,$var);
	  }
	  $select=$info_h{$var}{"fanin1"};
#	  print(YELLOW"\xE2\x9C\x94 Selected Node as X::$select\n");
		if( grep( /^$select$/, @FN)){
#		  	print(RED,"value $select was used before as non-x-->Conflict on @{$Baninfo_h{$select}}\n");
			 foreach $kem(@{$Baninfo_h{$select}}){
				push(@X_conflict, $kem)unless grep{$_ eq $kem} @X_conflict;
			 }
		}

	   if (!grep( /^$select$/, @X_sort ) ) {	# serach if $select is not in @X_sort
			      push(@X_sort,$select);# push a new node to X_sort that there isn't in X_sort
	              push(@vauleDepth,$info_h{$select}{"MaxDepth"});
				  	### Sort Descending		
					my @idx = sort { @vauleDepth[$b] <=> @vauleDepth[$a] } 0 .. $#vauleDepth; # sort an array based on another array
					@vauleDepth = @vauleDepth[@idx];
					@X_sort = @X_sort[@idx];
				}				
	}
	
elsif($TYPE eq XOR || $TYPE eq XNOR) {
	
		@select=($info_h{$var}{"fanin1"},$info_h{$var}{"fanin2"});# all the inputs of xor must be selected as X-node
#		print(WHITE,"Fan_ins::@select\n");
#		print(YELLOW"\xE2\x9C\x94 Selected Nodes as X::(@select)\n");
		foreach $km (@select){
			if( grep( /^$km$/, @FN)){
#		  		print(RED,"value $km was used before as non-x-->Conflict on @{$Baninfo_h{$km}}\n");
			  foreach $kem(@{$Baninfo_h{$km}}){
				push(@X_conflict, $kem)unless grep{$_ eq $kem} @X_conflict;
			 }
		  }
		  
			if(!grep( /^$km$/, @X_sort ) ) {	# serach if $select is not in @X_sort
			    push(@X_sort,$km);# push a new node to X_sort that there isn't in X_sort
	            push(@vauleDepth,$info_h{$km}{"MaxDepth"});
				 ### Sort Descending		
			    my @idx = sort { @vauleDepth[$b] <=> @vauleDepth[$a] } 0 .. $#vauleDepth; # sort an array based on another array
				@vauleDepth = @vauleDepth[@idx];
				@X_sort = @X_sort[@idx];
				}				 
		}
	}

#		print(WHITE,"Forbidden X Nodes::@FN \n");	
	    @fan_arrx=();@fan_arr=();
#		print(WHITE,"Updated X array::@X_sort\n");
#		print(WHITE,"Updated X Depths::@vauleDepth\n\n");
}

		#@confilict=keys %confilict_h; # 
		@Soft_Nodes=(@DiffType_conflict,@NOT_conflict,@X_conflict); # generating hard and soft cluases
		#@X_conflict:: gate and/nand or 'or/nor ' that have two or more inputs x-labeled
		#@DiffType_conflict:: two gate that have confilict on value
		#@NOT_conflict:: not gates with X-labeld output
		 foreach my $elem (@X_sort){
			  if( !grep( $elem eq $_, @Soft_Nodes )){
				push( @Hard_Nodes, $elem );
				}
		}
# final Results
        $num1=scalar @X_sort;
		$num2=scalar @X_conflict;
		$num3=scalar @DiffType_conflict;
   		print(WHITE,"Updated X array($num1)::@X_sort\n");# final X_sort .> this nodes add constraint to cnf file minus ex_hard
		print(WHITE,"X-Conflict($num2)::@X_conflict\n");# just for information. cuase no unsat in cnf
#		print("conflict on Not gate output::(@NOT_conflict)\n");# shouldnt be set as hard cluse--> contains X_node fanout not;and ...
        print("SFN-Conflict($num3))::",@DiffType_conflict,"\n");
		#print("Soft nodes of X_nodes::(@Soft_Nodes)\n");
		#print(WHITE,"Hard nodes of X_nodes::(@Hard_Nodes)\n");

print (YELLOW,".... END of Pre-processing step of SAT based Desing................\n\n");
no warnings;
