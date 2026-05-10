#!/usr/bin/perl
#
# @File CNFHandeling.pl
# @Author ahmad-pc
# @Created Oct 3, 2017 3:14:59 PM
#

no warnings;
use File::Copy qw(move);
use File::Copy qw(copy);
#require "Pre-processingSAT_mode1.pl";
$start=time;
require "Verilog2CNF.pl";

use Term::ANSIColor qw(:constants);
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
#############################################################################################################
print("\n");
  print(YELLOW"================================================================================================\n");
  print(WHITE"                                  WCNF File Generation.....\n");
  print(YELLOW"=================================================================================================\n");
open(data_in,"< Design.cnf");
open(data_out,">Design.wcnf");

print(data_out "c\n");
print(data_out "c Partial Max-SAT by Ahmad shabani\n");
print(data_out "c\n");
$top=600;# number of allowed soft unsat clause. Total unsat cluses shouldent be larger than this number 
while($line=<data_in>){
	next if($.<2);
	chomp($line);
	if($line=~m /^p/x){
		$line=~s/cnf/wcnf/x;
		$line=$line." ".$top;
		print(data_out"$line\n");
		}
	else{
		$line="1 ".$line; # converting to soft cluase
		print(data_out"$line\n");

		}
	}
close data_in;

$i=1;
#@ConsNodes=(@Soft_Nodes,@Hard_Nodes);
print(GREEN, "Done\n");
  print(YELLOW"================================================================================================\n");
  print(WHITE"                                  Beginning Constraint Adding (X,SFN,Rest).....\n");
  print(YELLOW"=================================================================================================\n");
  
  foreach $var(@X_sort){
#	print (GREEN,"$i) Processing ", $var,"....\n");
#=== check in @X_conflict array ==============================================
	if ( grep( /^$var$/, @X_conflict ) ) {
	   use Switch;$i++;
       switch($info_h{$var}{"type"}){
          case AND2{  
                        $out=$var;$fanin1=$info_h{$var}{"fanin1"};$fanin2=$info_h{$var}{"fanin2"};
#						print($info_h{$var}{"type"},"=>",$info_h{$var}{"map"},"=(",$info_h{$fanin1}{"map"},",",$info_h{$fanin2}{"map"},")","\n");
						if(exists $HardCluase_h{$out}){
#								print(CYAN,"perviously added cluase",$out,"=>",$HardCluase_h{$out},"\n");
#								print(CYAN,"current cluase $out => 0 \n");
								 if($HardCluase_h{$out} ne '0'){
#									 print(RED"ERROR %%%%%%%%%%%%%%%%%%%%%\n");
								 }
								
							}
							else{
								$HardCluase_h{$out}=0;
								print(data_out "$top ",-$info_h{$out}{"map"}," 0\n");# adding hard cluase
#								print("$top",-$info_h{$out}{"map"}," 0\n");
								push (@InsCand,$out);# contains all the insertion candidate nodes
#								print(WHITE,"============== X_conflict =================>>InsNode::",GREEN,"$out\n");
								$Insinfo_h{$out}={	  "ConfType"=> 'X',#confilict type
											  "GateType"=>AND2, # confilict gate
											  "InsType"=> '1', # insertion type: stucked 1 or 0
											  "InsLoc"=> $fanin1,# first fainin is selected as Insert location
						                      "fanin1"=> $fanin1,
											  "fanin2"=> $fanin2,
											  "#gate" =>$info_h{$out}{"gatenumber"}
																};
							}
						
						
																		}
							
		  case NAND2{  
                        $out=$var;$fanin1=$info_h{$var}{"fanin1"};$fanin2=$info_h{$var}{"fanin2"};
#						print($info_h{$var}{"type"},"=>",$info_h{$var}{"map"},"=(",$info_h{$fanin1}{"map"},",",$info_h{$fanin2}{"map"},")","\n");
						if(exists $HardCluase_h{$out}){
#								print(CYAN,"perviously added cluase",$out,"=>",$HardCluase_h{$out},"\n");
#								print(CYAN,"current cluase $out => 0 \n");
								if($HardCluase_h{$out} ne '0'){
#									 print(RED"ERROR %%%%%%%%%%%%%%%%%%%%%\n");
								 }
							}
							else{
								$HardCluase_h{$out}=0;
								print(data_out "$top ",-$info_h{$out}{"map"}," 0\n");
#								print("$top",-$info_h{$out}{"map"}," 0\n");
								push (@InsCand,$out);# conrains all the insertion candidate nodes
#								print(WHITE,"================X_conflict===============>>InsNode::",GREEN,"$out\n");
								$Insinfo_h{$out}={	  "ConfType"=> 'X',#confilict type
											  "GateType"=>NAND2, # confilict gate
											  "InsType"=> '1', # insertion type: stucked 1 or 0
											  "InsLoc"=> $fanin1,# first fainin is selected as Insert location
						                      "fanin1"=> $fanin1,
											  "fanin2"=> $fanin2,
											  "#gate" =>$info_h{$out}{"gatenumber"}
																};
							}
						
																		}
																		
																		
          case OR2{  
                        $out=$var;$fanin1=$info_h{$var}{"fanin1"};$fanin2=$info_h{$var}{"fanin2"};
#						print($info_h{$var}{"type"},"=>",$info_h{$var}{"map"},"=(",$info_h{$fanin1}{"map"},",",$info_h{$fanin2}{"map"},")","\n");
						if(exists $HardCluase_h{$out}){
#									print(CYAN,"perviously added cluase",$out,"=>",$HardCluase_h{$out},"\n");
#									print(CYAN,"current cluase $out => 0 \n");
								    if($HardCluase_h{$out} ne '0'){
#									 print(RED"ERROR %%%%%%%%%%%%%%%%%%%%%\n");
								 }
								}
								else{
									$HardCluase_h{$out}=0;
									print(data_out "$top ",-$info_h{$out}{"map"}," 0\n");
#									print("$top",-$info_h{$out}{"map"}," 0\n");
									push (@InsCand,$out);# conrains all the insertion candidate nodes
#									print(WHITE,"=================X_conflict==============>>InsNode::",GREEN,"$out\n");
									$Insinfo_h{$out}={	  "ConfType"=> 'X',#confilict type
											  "GateType"=>OR2, # confilict gate
											  "InsType"=> '0', # insertion type: stucked 1 or 0
											  "InsLoc"=> $fanin1,# first fainin is selected as Insert location
						                      "fanin1"=> $fanin1,
											  "fanin2"=> $fanin2,
                                              "#gate" =>$info_h{$out}{"gatenumber"}											  
																};
								}
						
																		}
		  case NOR2{  
                        $out=$var;$fanin1=$info_h{$var}{"fanin1"};$fanin2=$info_h{$var}{"fanin2"};
#						print($info_h{$var}{"type"},"=>",$info_h{$var}{"map"},"=(",$info_h{$fanin1}{"map"},",",$info_h{$fanin2}{"map"},")","\n");
							if(exists $HardCluase_h{$out}){
#									print(CYAN,"perviously added cluase",$out,"=>",$HardCluase_h{$out},"\n");
#									print(CYAN,"current cluase $out => 0 \n");
									if($HardCluase_h{$out} ne '0'){
#									 print(RED"ERROR %%%%%%%%%%%%%%%%%%%%%\n");
								 }
								}
								else{
									$HardCluase_h{$out}=0;
									print(data_out "$top ",-$info_h{$out}{"map"}," 0\n");
#									print("$top",-$info_h{$out}{"map"}," 0\n");
									push (@InsCand,$out);# conrains all the insertion candidate nodes
#									print(WHITE,"==================X_conflict============>>InsNode::",GREEN,"$out\n");
									$Insinfo_h{$out}={	  "ConfType"=> 'X',#confilict type
											  "GateType"=>NOR2, # confilict gate
											  "InsType"=> '0', # insertion type: stucked 1 or 0
											  "InsLoc"=> $fanin1,# first fainin is selected as Insert location
						                      "fanin1"=> $fanin1,
											  "fanin2"=> $fanin2,
											  "#gate" =>$info_h{$out}{"gatenumber"}
																};
								}
						
																		}
		  else              { print RED,"Error in constraint adding X conflict part \n" }
       } #and of switch
} # end of if
#============ Check in @DiffType_conflict array =========================================================================
   	elsif ( grep( /^$var$/, @DiffType_conflict ) ) {
		use Switch;$i++;
       switch($info_h{$var}{"type"}){
          case AND2{  
                        $out=$var;$fanin1=$info_h{$var}{"fanin1"};$fanin2=$info_h{$var}{"fanin2"};
	#					print($info_h{$var}{"type"},"=>",$info_h{$var}{"map"},"=(",$info_h{$fanin1}{"map"},",",$info_h{$fanin2}{"map"},")","\n");
							if(exists $HardCluase_h{$out}){
	#								print(CYAN,"perviously added cluase",$out,"=>",$HardCluase_h{$out},"\n");
	#								print(CYAN,"current cluase $out => 0 \n");
									if($HardCluase_h{$out} ne '0'){
	#								 print(RED"ERROR %%%%%%%%%%%%%%%%%%%%%\n");
								 }
								}
								else{
									$HardCluase_h{$out}=0;
									print(data_out "$top ",-$info_h{$out}{"map"}," 0\n");
	#								print("$top",-$info_h{$out}{"map"}," 0\n");
									push (@InsCand,$out);# contains all the insertion candidate nodes
	#								print(WHITE,"===================DiffTypeConflict===========>>InsNode::",GREEN,"$out\n");
					
										if (!grep( /^$fanin1$/,@X_sort)){ # select insertion location based on non-x fanin
											$InsLoc=$fanin1;
											}
										else{
											$InsLoc=$fanin2;
									   }	
									$Insinfo_h{$out}={	  "ConfType"=> "DiffType",#confilict type
											  "GateType"=>AND2, # confilict gate
											  "InsType"=> '1', # insertion type: stucked 1 or 0
											  "InsLoc"=> $InsLoc,# non_x fainin is selected as Insert location
						                      "fanin1"=> $fanin1,
											  "fanin2"=> $fanin2,
											  "#gate" =>$info_h{$out}{"gatenumber"}
																};
								}
						
																		}
							
		 case NAND2{  
                        $out=$var;$fanin1=$info_h{$var}{"fanin1"};$fanin2=$info_h{$var}{"fanin2"};
	#					print($info_h{$var}{"type"},"=>",$info_h{$var}{"map"},"=(",$info_h{$fanin1}{"map"},",",$info_h{$fanin2}{"map"},")","\n");
							if(exists $HardCluase_h{$out}){
	#								print(CYAN,"perviously added cluase",$out,"=>",$HardCluase_h{$out},"\n");
	#								print(CYAN,"current cluase $out => 0 \n");
									if($HardCluase_h{$out} ne '0'){
	#								 print(RED"ERROR %%%%%%%%%%%%%%%%%%%%%\n");
								 }
								}
								else{
									$HardCluase_h{$out}=0;
									print(data_out "$top ",-$info_h{$out}{"map"}," 0\n");
	#					print("$top",-$info_h{$out}{"map"}," 0\n");
						push (@InsCand,$out);# contains all the insertion candidate nodes
	#					print(WHITE,"==================DiffTypeConflict============>>InsNode::",GREEN,"$out\n");

						if (!grep( /^$fanin1$/,@X_sort)){ # select insertion location based on non-x fanin
							$InsLoc=$fanin1;
							}
						  else{
							 $InsLoc=$fanin2;
							  }	
						$Insinfo_h{$out}={	  "ConfType"=> "DiffType",#confilict type
											  "GateType"=>NAND2, # confilict gate
											  "InsType"=> '1', # insertion type: stucked 1 or 0
											  "InsLoc"=> $InsLoc,# first fainin is selected as Insert location
						                      "fanin1"=> $fanin1,
											  "fanin2"=> $fanin2,
											  "#gate" =>$info_h{$out}{"gatenumber"}
																};
								}
						
																		}
																		
																		
          case OR2{  
                        $out=$var;$fanin1=$info_h{$var}{"fanin1"};$fanin2=$info_h{$var}{"fanin2"};
	#					print($info_h{$var}{"type"},"=>",$info_h{$var}{"map"},"=(",$info_h{$fanin1}{"map"},",",$info_h{$fanin2}{"map"},")","\n");
							if(exists $HardCluase_h{$out}){
	#								print(CYAN,"perviously added cluase",$out,"=>",$HardCluase_h{$out},"\n");
	#								print(CYAN,"current cluase $out => 0 \n");
									if($HardCluase_h{$out} ne '0'){
	#								 print(RED"ERROR %%%%%%%%%%%%%%%%%%%%%\n");
								 }
								}
								else{
									$HardCluase_h{$out}=0;
									print(data_out "$top ",-$info_h{$out}{"map"}," 0\n");
	#					print("$top",-$info_h{$out}{"map"}," 0\n");
						push (@InsCand,$out);# contains all the insertion candidate nodes
	#					print(WHITE,"===================DiffTypeConflict===========>>InsNode::",GREEN,"$out\n");

						if (!grep( /^$fanin1$/,@X_sort)){ # select insertion location based on non-x fanin
							$InsLoc=$fanin1;
							}
						  else{
							 $InsLoc=$fanin2;
							  }	
							
						$Insinfo_h{$out}={	  "ConfType"=> "DiffType",#confilict type
											  "GateType"=>OR2, # confilict gate
											  "InsType"=> '0', # insertion type: stucked 1 or 0
											  "InsLoc"=> $InsLoc,# first fainin is selected as Insert location
						                      "fanin1"=> $fanin1,
											  "fanin2"=> $fanin2,
											  "#gate" =>$info_h{$out}{"gatenumber"}
																};
								}
						
																		}
		  case NOR2{  
                        $out=$var;$fanin1=$info_h{$var}{"fanin1"};$fanin2=$info_h{$var}{"fanin2"};
	#					print($info_h{$var}{"type"},"=>",$info_h{$var}{"map"},"=(",$info_h{$fanin1}{"map"},",",$info_h{$fanin2}{"map"},")","\n");
							if(exists $HardCluase_h{$out}){
	#								print(CYAN,"perviously added cluase",$out,"=>",$HardCluase_h{$out},"\n");
	#								print(CYAN,"current cluase $out => 0 \n");
									if($HardCluase_h{$out} ne '0'){
	#								 print(RED"ERROR %%%%%%%%%%%%%%%%%%%%%\n");
								 }
								}
								else{
									$HardCluase_h{$out}=0;
									print(data_out "$top ",-$info_h{$out}{"map"}," 0\n");
	#					print("$top",-$info_h{$out}{"map"}," 0\n");
						push (@InsCand,$out);# contains all the insertion candidate nodes
	#					  	print(WHITE,"===================DiffTypeConflict============>>InsNode::",GREEN,"$out\n");

						  if (!grep( /^$fanin1$/,@X_sort)){ # select insertion location based on non-x fanin
							$InsLoc=$fanin1;
							}
						  else{
							 $InsLoc=$fanin2;
							  }	
							
						$Insinfo_h{$out}={	  "ConfType"=> "DiffType",#confilict type
											  "GateType"=>NOR2, # confilict gate
											  "InsType"=> '0', # insertion type: stucked 1 or 0
											  "InsLoc"=> $InsLoc,# first fainin is selected as Insert location
						                      "fanin1"=> $fanin1,
											  "fanin2"=> $fanin2,
											  "#gate" =>$info_h{$out}{"gatenumber"}
																};
								}
						
																		}
		  else              { print RED,"Error in constraint adding DiffType conflict part\n" }
       } #and of switch
}
#======== checking Not_conflict array=======================.=================
	elsif ( grep( /^$var$/, ,@NOT_conflict ) ) {
		$i++;
						$out=$var;$fanin1=$info_h{$var}{"fanin1"};
	#					print($info_h{$var}{"type"},"=>",$info_h{$var}{"map"},"=(",$info_h{$fanin1}{"map"},"\n");
							if(exists $HardCluase_h{$out}){
	#								print(CYAN,"perviously added cluase",$out,"=>",$HardCluase_h{$out},"\n");
	#								print(CYAN,"current cluase $out => 0 \n");
									if($HardCluase_h{$out} ne '0'){
	#								 print(RED"ERROR %%%%%%%%%%%%%%%%%%%%%\n");
								 }
								}
								else{
									$HardCluase_h{$out}=0;
									print(data_out "$top ",-$info_h{$out}{"map"}," 0\n");
	#					print("$top ",-$info_h{$out}{"map"}," 0\n");
	#				    print("No insertion is required\n");
						push (@InsCand,$out);
						#print(WHITE,"==============================>>InsNode::",GREEN,"$out\n");
						$InsLoc=$out;
						$Insinfo_h{$out}={	  "ConfType"=> 'NA   ',#conflict type
											  "GateType"=>NOT1, # conflict gate
											  "InsType"=> 'NA', # insertion type: stucked 1 or 0 or NA
											  "InsLoc"=> 'NA',# first fainin is selected as Insert location
						                      "fanin1"=> $fanin1,
											  "fanin2"=> '--',
											  "#gate" =>$info_h{$out}{"gatenumber"}
																};
								}
						
}
#====== checking rest of x nodes==============================================
   else{
	   use Switch;$i++;
	   switch($info_h{$var}{"type"}){
		  
          case AND2{  
                        $out=$var;$fanin1=$info_h{$var}{"fanin1"};$fanin2=$info_h{$var}{"fanin2"};
	#					print($info_h{$var}{"type"},"=>",$info_h{$var}{"map"},"=(",$info_h{$fanin1}{"map"},",",$info_h{$fanin2}{"map"},")","\n");
	#					print($info_h{$var}{"type"},"=>",$var,"=(",$fanin1,",",$fanin2,")","\n");	
							if(exists $HardCluase_h{$out}){
	#							print(CYAN,"perviously added cluase",$out,"=>",$HardCluase_h{$out},"\n");
	#							print(CYAN,"current cluase $out => 0 \n");
								if($HardCluase_h{$out} ne '0'){
	#								 print(RED"ERROR %%%%%%%%%%%%%%%%%%%%%\n");
								 }
							}
							else{
								$HardCluase_h{$out}=0;
								print(data_out "$top ",-$info_h{$out}{"map"}," 0\n");
	#							print("$top ",-$info_h{$out}{"map"}," 0\n");
							}								
						if (!grep( /^$fanin1$/,@X_sort)){ # select insertion location based on non-x fanin
									if(exists $HardCluase_h{$fanin1}){
	#									print(CYAN,"perviously added cluase",$fanin1,"=>",$HardCluase_h{$fanin1},"\n");
	#									print(CYAN,"current cluase $fanin1 => 1 \n");
										if($HardCluase_h{$fanin1} ne '1'){
	#								 print(RED"ERROR %%%%%%%%%%%%%%%%%%%%%\n");
								 }
									}
									else{
										$HardCluase_h{$fanin1}=1;
										print(data_out "$top ",$info_h{$fanin1}{"map"}," 0\n");
	#									print("$top ",$info_h{$fanin1}{"map"}," 0\n");
									}
							}
						  else{
								if(exists $HardCluase_h{$fanin2}){
	#									print(CYAN,"perviously added cluase",$fanin2,"=>",$HardCluase_h{$fanin2},"\n");
	#									print(CYAN,"current cluase $fanin2 => 1 \n");
										if($HardCluase_h{$fanin2} ne '1'){
	#								 print(RED"ERROR %%%%%%%%%%%%%%%%%%%%%\n");
								 }
									}
									else{
										$HardCluase_h{$fanin2}=1;
										print(data_out "$top ",$info_h{$fanin2}{"map"}," 0\n");
	#									print("$top ",$info_h{$fanin2}{"map"}," 0\n");
									}
							}
						
																		}
		  case NAND2{  
                        $out=$var;$fanin1=$info_h{$var}{"fanin1"};$fanin2=$info_h{$var}{"fanin2"};
	#					print($info_h{$var}{"type"},"=>",$info_h{$var}{"map"},"=(",$info_h{$fanin1}{"map"},",",$info_h{$fanin2}{"map"},")","\n");
						if(exists $HardCluase_h{$out}){
	#							print(CYAN,"perviously added cluase",$out,"=>",$HardCluase_h{$out},"\n");
	#							print(CYAN,"current cluase $out => 0 \n");
								if($HardCluase_h{$out} ne '0'){
	#								 print(RED"ERROR %%%%%%%%%%%%%%%%%%%%%\n");
								 }
								
							}
							else{
								$HardCluase_h{$out}=0;
								print(data_out "$top ",-$info_h{$out}{"map"}," 0\n");
	#							print("$top",-$info_h{$out}{"map"}," 0\n");
							}
						if (!grep( /^$fanin1$/,@X_sort)){ # select insertion location based on non-x fanin
								
								if(exists $HardCluase_h{$fanin1}){
	#									print(CYAN,"perviously added cluase",$fanin1,"=>",$HardCluase_h{$fanin1},"\n");
	#									print(CYAN,"current cluase $fanin1 => 1 \n");
										if($HardCluase_h{$fanin1} ne '1'){
	#								 print(RED"ERROR %%%%%%%%%%%%%%%%%%%%%\n");
								 }
									}
									else{
										$HardCluase_h{$fanin1}=1;
										print(data_out "$top ",$info_h{$fanin1}{"map"}," 0\n");
	#									print("$top ",$info_h{$fanin1}{"map"}," 0\n");
									}
							}
						  else{
								
								if(exists $HardCluase_h{$fanin2}){
	#									print(CYAN,"perviously added cluase",$fanin2,"=>",$HardCluase_h{$fanin2},"\n");
	#									print(CYAN,"current cluase $fanin2 => 1 \n");
										if($HardCluase_h{$fanin2} ne '1'){
	#								 print(RED"ERROR %%%%%%%%%%%%%%%%%%%%%\n");
								 }
									}
									else{
										$HardCluase_h{$fanin2}=1;
										print(data_out "$top ",$info_h{$fanin2}{"map"}," 0\n");
	#									print("$top ",$info_h{$fanin2}{"map"}," 0\n");
									}
							}
						
																		}
		  case OR2{  
                        $out=$var;$fanin1=$info_h{$var}{"fanin1"};$fanin2=$info_h{$var}{"fanin2"};
	#					print($info_h{$var}{"type"},"=>",$info_h{$var}{"map"},"=(",$info_h{$fanin1}{"map"},",",$info_h{$fanin2}{"map"},")","\n");
						
						if(exists $HardCluase_h{$out}){
	#							print(CYAN,"perviously added cluase",$out,"=>",$HardCluase_h{$out},"\n");
	#							print(CYAN,"current cluase $out => 0 \n");
								if($HardCluase_h{$out} ne '0'){
	#								 print(RED"ERROR %%%%%%%%%%%%%%%%%%%%%\n");
								 }
							}
							else{
								$HardCluase_h{$out}=0;
								print(data_out "$top ",-$info_h{$out}{"map"}," 0\n");
	#							print("$top",-$info_h{$out}{"map"}," 0\n");
							}
						if (!grep( /^$fanin1$/,@X_sort)){ # select insertion location based on non-x fanin
								
								if(exists $HardCluase_h{$fanin1}){
	#									print(CYAN,"perviously added cluase",$fanin1,"=>",$HardCluase_h{$fanin1},"\n");
	#									print(CYAN,"current cluase $fanin1 => 0 \n");
										if($HardCluase_h{$fanin1} ne '0'){
	#								 print(RED"ERROR %%%%%%%%%%%%%%%%%%%%%\n");
								 }
									}
									else{
										$HardCluase_h{$fanin1}=0;
										print(data_out "$top ",-$info_h{$fanin1}{"map"}," 0\n");
	#									print("$top ",-$info_h{$fanin1}{"map"}," 0\n");
									}
							}
						  else{
								
								if(exists $HardCluase_h{$fanin2}){
	#									print(CYAN,"perviously added cluase",$fanin2,"=>",$HardCluase_h{$fanin2},"\n");
	#									print(CYAN,"current cluase $fanin2 => 0 \n");
										if($HardCluase_h{$fanin2} ne '0'){
	#								 print(RED"ERROR %%%%%%%%%%%%%%%%%%%%%\n");
								 }
									}
									else{
										$HardCluase_h{$fanin2}=0;
										print(data_out "$top ",-$info_h{$fanin2}{"map"}," 0\n");
	#									print("$top ",-$info_h{$fanin2}{"map"}," 0\n");
									}
							}
																		}
						
		  case NOR2{  
                        $out=$var;$fanin1=$info_h{$var}{"fanin1"};$fanin2=$info_h{$var}{"fanin2"};
	#					print($info_h{$var}{"type"},"=>",$info_h{$var}{"map"},"=(",$info_h{$fanin1}{"map"},",",$info_h{$fanin2}{"map"},")","\n");
						
						if(exists $HardCluase_h{$out}){
	#							print(CYAN,"perviously added cluase",$out,"=>",$HardCluase_h{$out},"\n");
	#							print(CYAN,"current cluase $out => 0 \n");
								if($HardCluase_h{$out} ne '0'){
	#								 print(RED"ERROR %%%%%%%%%%%%%%%%%%%%%\n");
								 }
						}
						else{
								$HardCluase_h{$out}=0;
								print(data_out "$top ",-$info_h{$out}{"map"}," 0\n");
	#							print("$top",-$info_h{$out}{"map"}," 0\n");
						}
						if (!grep( /^$fanin1$/,@X_sort)){ # select insertion location based on non-x fanin
								
								if(exists $HardCluase_h{$fanin1}){
	#									print(CYAN,"perviously added cluase",$fanin1,"=>",$HardCluase_h{$fanin1},"\n");
	#									print(CYAN,"current cluase $fanin1 => 0 \n");
										if($HardCluase_h{$fanin1} ne '0'){
	#								 print(RED"ERROR %%%%%%%%%%%%%%%%%%%%%\n");
								 }
									}
									else{
										$HardCluase_h{$fanin1}=0;
										print(data_out "$top ",-$info_h{$fanin1}{"map"}," 0\n");
	#									print("$top ",-$info_h{$fanin1}{"map"}," 0\n");
									}
							}
						  else{
								
								if(exists $HardCluase_h{$fanin2}){
	#									print(CYAN,"perviously added cluase",$fanin2,"=>",$HardCluase_h{$fanin2},"\n");
	#									print(CYAN,"current cluase $fanin2 => 0 \n");
										if($HardCluase_h{$fanin2} ne '0'){
	#								 print(RED"ERROR %%%%%%%%%%%%%%%%%%%%%\n");
								 }
									}
									else{
										$HardCluase_h{$fanin2}=0;
										print(data_out "$top ",-$info_h{$fanin2}{"map"}," 0\n");
	#									print("$top ",-$info_h{$fanin2}{"map"}," 0\n");
									}
							}
						
																		}
		  case XOR2{  
                        $out=$var;$fanin1=$info_h{$var}{"fanin1"};$fanin2=$info_h{$var}{"fanin2"};
	#					print($info_h{$var}{"type"},"=>",$info_h{$var}{"map"},"=(",$info_h{$fanin1}{"map"},",",$info_h{$fanin2}{"map"},")","\n");
						
						if(exists $HardCluase_h{$out}){
	#							print(CYAN,"perviously added cluase",$out,"=>",$HardCluase_h{$out},"\n");
	#							print(CYAN,"current cluase $out => 0 \n");
								if($HardCluase_h{$out} ne '0'){
	#								 print(RED"ERROR %%%%%%%%%%%%%%%%%%%%%\n");
								 }
						}
						else{
								$HardCluase_h{$out}=0;
								print(data_out "$top ",-$info_h{$out}{"map"}," 0\n");
	#							print("$top",-$info_h{$out}{"map"}," 0\n");
						}
						
						
																		}
	     case XNOR2{  
                        $out=$var;$fanin1=$info_h{$var}{"fanin1"};$fanin2=$info_h{$var}{"fanin2"};
	#					print($info_h{$var}{"type"},"=>",$info_h{$var}{"map"},"=(",$info_h{$fanin1}{"map"},",",$info_h{$fanin2}{"map"},")","\n");
						
						if(exists $HardCluase_h{$out}){
	#							print(CYAN,"perviously added cluase",$out,"=>",$HardCluase_h{$out},"\n");
	#							print(CYAN,"current cluase $out => 0 \n");
								if($HardCluase_h{$out} ne '0'){
	#								 print(RED"ERROR %%%%%%%%%%%%%%%%%%%%%\n");
								 }
							}
							else{
								$HardCluase_h{$out}=0;
								print(data_out "$top ",-$info_h{$out}{"map"}," 0\n");
	#							print("$top",-$info_h{$out}{"map"}," 0\n");
							}
																		}
		 case NOT1{  
                        $out=$var;$fanin1=$info_h{$var}{"fanin1"};
	#					print($info_h{$var}{"type"},"=>",$info_h{$var}{"map"},"=(",$info_h{$fanin1}{"map"},"\n");
						
						if(exists $HardCluase_h{$out}){
	#							print(CYAN,"perviously added cluase",$out,"=>",$HardCluase_h{$out},"\n");
	#							print(CYAN,"current cluase $out => 0 \n");
								if($HardCluase_h{$out} ne '0'){
	#								 print(RED"ERROR %%%%%%%%%%%%%%%%%%%%%\n");
								 }
							}
							else{
								$HardCluase_h{$out}=0;
								print(data_out "$top ",-$info_h{$out}{"map"}," 0\n");
	#							print("$top",-$info_h{$out}{"map"}," 0\n");
							}
																		}				
		 case BUFF1{  
                        $out=$var;$fanin1=$info_h{$var}{"fanin1"};
	#					print($info_h{$var}{"type"},"=>",$info_h{$var}{"map"},"=(",$info_h{$fanin1}{"map"},"\n");
						
						if(exists $HardCluase_h{$out}){
	#							print(CYAN,"perviously added cluase",$out,"=>",$HardCluase_h{$out},"\n");
	#							print(CYAN,"current cluase $out => 0 \n");
								if($HardCluase_h{$out} ne '0'){
	#								 print(RED"ERROR %%%%%%%%%%%%%%%%%%%%%\n");
								 }
							}
							else{
								$HardCluase_h{$out}=0;
								print(data_out "$top ",-$info_h{$out}{"map"}," 0\n");
	#							print("$top",-$info_h{$out}{"map"}," 0\n");
							}
																		}
		  case INPUT1{  
                        $out=$var;
	#					print($info_h{$var}{"type"},"=>",$info_h{$var}{"map"},"\n");
						
						if(exists $HardCluase_h{$out}){
	#							print(CYAN,"perviously added cluase",$out,"=>",$HardCluase_h{$out},"\n");
	#							print(CYAN,"current cluase $out => 0 \n");
								if($HardCluase_h{$out} ne '0'){
	#								 print(RED"ERROR %%%%%%%%%%%%%%%%%%%%%\n");
								 }
							}
							else{
								$HardCluase_h{$out}=0;
								print(data_out "$top ",-$info_h{$out}{"map"}," 0\n");
	#							print("$top",-$info_h{$out}{"map"}," 0\n");
							}
						push(@X_inp,$out);
																		}															
	   	  else { print RED,"Error in constraint adding no conflict part\n" }

               }
   } # rest of the X nodes 
} # end of X_Sort reading
print(GREEN, "Done\n");

  print(YELLOW"================================================================================================\n");
  print(WHITE"                                  Checking Blocking Conflict.....\n");
  print(YELLOW"=================================================================================================\n");

 $b=0;
foreach $var(@X_sort){
	$b++;
	#print (GREEN,"$b) Processing ", $var,"....\n");
   @fanout=();
   for($i=1; $i<=$fanout_h{$var}{"#fanout"} ; $i=$i+1){ # extarct all the fanouts of $var
	   push(@fanout,$fanout_h{$var}{"fanout"."$i"});
	}
	foreach $kem (@fanout){ # check if the output is non-x node
	   if (!grep( /^$kem$/, @X_sort)) {
		   	$out=$kem;$fanin1=$info_h{$kem}{"fanin1"};$fanin2=$info_h{$kem}{"fanin2"};
	#		print($info_h{$kem}{"type"},"=>",$kem,"=(",$fanin1,",",$fanin2,")","\n");
		    my $type=$info_h{$kem}{"type"};
           # print(YELLOW, "Propagating must be blocked $type($var => $kem)\n");
			   if($info_h{$kem}{"type"} eq AND2 || $info_h{$kem}{"type"} eq NAND2){
				    if (grep( /^$info_h{$kem}{"fanin1"}$/, @X_sort) && grep( /^$info_h{$kem}{"fanin2"}$/, @X_sort)) {
	#					print(RED, " Multi_X input on $kem must be Blocked by insertion\n");
						push(@BlockEX, $kem) unless grep{$_ eq $kem} @BlockEX;
					}
					# for preventing propagation of X non-x input must be stucked at 0 for and/nand gate
				    elsif(grep( /^$info_h{$kem}{"fanin1"}$/, @X_sort)){   # Finding non-X input
						$nonXinp=$info_h{$kem}{"fanin2"};
	#					print("Non_X input::$nonXinp=>",$info_h{$nonXinp}{"map"},"\n");
						
						if(exists $HardCluase_h{$nonXinp}){
	#							print("perviously added cluase",$nonXinp,"=>",$HardCluase_h{$nonXinp},"\n");
	#							print("current cluase $nonXinp => 0 \n");
								if($HardCluase_h{$nonXinp} ne '0'){
	#								 print(RED"$kem must be blocked(inconsistency in constraint)\n");
									 push(@Block,$kem) unless grep{$_ eq $kem} @Block;
								 }
							}
							else{
								$HardCluase_h{$nonXinp}=0;
								print(data_out "$top ",-$info_h{$nonXinp}{"map"}," 0\n");
	#							print("$top ",-$info_h{$nonXinp}{"map"}," 0\n");
							}
					} 
					elsif(grep( /^$info_h{$kem}{"fanin2"}$/, @X_sort)){   # Finding non-X input
						$nonXinp=$info_h{$kem}{"fanin1"};
	#					print("Non_X input::$nonXinp=>",$info_h{$nonXinp}{"map"},"\n");
						
						if(exists $HardCluase_h{$nonXinp}){
	#							print(CYAN,"perviously added cluase",$nonXinp,"=>",$HardCluase_h{$nonXinp},"\n");
	#							print(CYAN,"current cluase $nonXinp => 0 \n");
								if($HardCluase_h{$nonXinp} ne '0'){
	#								 print(RED"$kem must be blocked(inconsistency in constraint)\n");
									 push(@Block,$kem) unless grep{$_ eq $kem} @Block;
								 }								
							}
							else{
								$HardCluase_h{$nonXinp}=0;
								print(data_out "$top ",-$info_h{$nonXinp}{"map"}," 0\n");
	#							print("$top ",-$info_h{$nonXinp}{"map"}," 0\n");
							}
					}
					else{
	#				 print(RED,"ERROR\n");	
					}
					
				}
			   elsif($info_h{$kem}{"type"} eq OR2 || $info_h{$kem}{"type"} eq NOR2){
				  if (grep( /^$info_h{$kem}{"fanin1"}$/, @X_sort) && grep( /^$info_h{$kem}{"fanin2"}$/, @X_sort)) {
	#				 print(RED,"Multi_X $kem must be blocked by insertion\n");
				     push(@BlockEX, $kem) unless grep{$_ eq $kem} @BlockEX;
					}
				  elsif(grep( /^$info_h{$kem}{"fanin1"}$/, @X_sort)){   # Finding non-X input
						$nonXinp=$info_h{$kem}{"fanin2"};
	#					print("Non_X input::$nonXinp=>",$info_h{$nonXinp}{"map"},"\n");
						
						if(exists $HardCluase_h{$nonXinp}){
	#							print(CYAN,"perviously added cluase",$nonXinp,"=>",$HardCluase_h{$nonXinp},"\n");
	#							print(CYAN,"current cluase $nonXinp => 1 \n");
								if($HardCluase_h{$nonXinp} ne '1'){
	#								 print(RED"$kem must be blocked(inconsistency in constraint)\n");
									 push(@Block,$kem) unless grep{$_ eq $kem} @Block;
								 }
							}
							else{
								$HardCluase_h{$nonXinp}=1;
								print(data_out "$top ",$info_h{$nonXinp}{"map"}," 0\n");
	#							print("$top ",$info_h{$nonXinp}{"map"}," 0\n");
							}
					} 
				  elsif(grep( /^$info_h{$kem}{"fanin2"}$/, @X_sort)){
						$nonXinp=$info_h{$kem}{"fanin1"};
	#					print("Non_X input::$nonXinp=>",$info_h{$nonXinp}{"map"},"\n");
						
						if(exists $HardCluase_h{$nonXinp}){
	#							print(CYAN,"perviously added cluase",$nonXinp,"=>",$HardCluase_h{$nonXinp},"\n");
	#							print(CYAN,"current cluase $nonXinp => 1 \n");
								if($HardCluase_h{$nonXinp} ne '1'){
	#								 print(RED"$kem must be blocked(inconsistency in constraint)\n");
									 push(@Block,$kem) unless grep{$_ eq $kem} @Block;
								 }
							}
							else{
								$HardCluase_h{$nonXinp}=1;
								print(data_out "$top ",$info_h{$nonXinp}{"map"}," 0\n");
	#							print("$top ",$info_h{$nonXinp}{"map"}," 0\n");
							}
				    }
					else{
	#				  print(RED,"ERROR\n");	
					}
			    }
				else{ # type=not/xor/xnor/buf
	#			   print(RED, "$kem must be Blocked by insertion\n");
				   push(@Block, $kem) unless grep{$_ eq $kem} @Block;
				}		 
		}
	}
	#print("\n");
}


@InsCandPre=@InsCand; # contains X,SFN,Not Conflicts  
print(GREEN, "Done\n");

#print(CYAN,"inputs X-labeld::\n @X_inp\n\n");

#=========== End of constraint adding =====================================================

# Runing MaxSAT solver and saving the results of solver in result.txt;
  print(YELLOW"================================================================================================\n");
  print(WHITE"                                  SAT Solver is Running.....\n");
  print(YELLOW"=================================================================================================\n");

$cmd='open-wbo Design.wcnf >SATSolver.txt';	
system($cmd);
$cmd='open-wbo Design.wcnf';	
system($cmd);

open(data,"<SATSolver.txt");
while($line=<data>){
	if($line=~m /^s/x){
		chomp($line);
	#	print(BLUE,"$line\n");# print optimum found or unsatisfable
		if($line eq 's UNSATISFIABLE'){
			exit;
			}
		}
	elsif($line=~m /^v/x){
		chomp($line);
	#	print("$line\n");# print optimum Answer
		$line=~s/v//x;
		@result=split(' ',$line); # contains the truth assignment

	}
	elsif($line=~m /^c\s+Nb \s UNSAT/x){
		($NumofUNSAT)=$line=~m /\:\s+(\d+)/x;
		}
}
#print("\nNumber of UNSAT Clause::$NumofUNSAT\n");
print(YELLOW,"End of SAT Solver Results...........................................\n\n");
close data;
@PreInsCand=@InsCand; 
#print(CYAN,"InsCand(Pre-Process):: @PreInsCand1\n");# this contains only insertion gate based on conflict gate(X_conflict+ DiffType_Conflict)
############# Extracting UNSAT clauses ########################################
  print(YELLOW"================================================================================================\n");
  print(WHITE"                                  Extracting UNSAT Cluase.....\n");
  print(YELLOW"=================================================================================================\n");open(data,"<Design.wcnf");

$p=0;
$NumUNSATGate=0;
while($line=<data>){ # scaning wcnf file (Read a cluase)
	@convliteral=(); # contains inv_map of soft cluases(input and output)
	$flag=0;chomp($line);
	if($line=~m /^1\s/x){ # we investigate only soft cluases to check unsat cluase
		$cpyline=$line;
	 $line=~s/^1\s//x;$line=~s/\s 0//x; #remove 0 from begging and 1 from end of line of cluase
	 @literal=split(' ',$line);# contains literals of soft cluase based on map
		foreach $var(@literal){
			push(@convliteral,$map_rev_h{abs($var)});
			if (grep( /^$var$/, @result)) { # if literal under process exists in truth assignment
			$flag=1;last; # means this clause is SAT so we procced to next cluase
			}
		}
		# the cluase is SAT if exists at least one literal which exists in truth assignment
	 if($flag==0){ # check in current clause is sat or not   flag=0 unsat::make relation to gate	flag=1 sat go to next line/clause
	            #flag=0 means we cannot find even a literal of cluase in truth assignemt
		 $p++;#print(YELLOW,"$p)");
			#print(WHITE," UNSAT Clause::$cpyline\n");
		    #print("\t\t   @convliteral\n");
			if(scalar @convliteral==1){# if unsat clause has only one literal so this is output the gate 
				if (!grep( /^$convliteral[0]$/, @InsCand)) {
					$InsLoc=$convliteral[0];
					push (@InsCand,$convliteral[0]) unless grep{$_ eq $convliteral[0]} @InsCand;
			#		print("=========== one literal Cluase===========>>InsNode::",GREEN,"$convliteral[0]\n\n");
					$NumUNSATGate++;
					$Insinfo_h{$convliteral[0]}={"ConfType"=> "UNSAT",#confilict type
												 "GateType"=>$info_h{$convliteral[0]}{"type"}, # confilict gate
												 "InsType"=> 'UNKNOWN', # insertion type: stucked 1 or 0
												 "InsLoc"=> $InsLoc,# first fainin is selected as Insert location
												 "fanin1"=> $info_h{$convliteral[0]}{"fanin1"},
												 "fanin2"=> 'NA',
												 "#gate" =>$info_h{$convliteral[0]}{"gatenumber"}
												 
																};
					}
				}
			else{#  we should process the inputs and output of clause to assign to a gate
				  foreach $elem(@convliteral){
					no warnings;@fan_arr=();
					@fan_arr=($info_h{$elem}{"fanin1"},$info_h{$elem}{"fanin2"});	 
						if (grep( /^$fan_arr[0]$/, @convliteral) || grep( /^$fan_arr[1]$/, @convliteral)) {
						   if (grep( /^$elem$/, @InsCand)) {
							   if (grep( /^$elem$/, @NOT_conflict)){
								   	$NumUNSATGate++; # increment of number of unsat GATE
								   }
							   }
						   else{	   
			#				 print("$elem=(@fan_arr)\n");
							 push (@InsCand,$elem)unless grep{$_ eq $elem} @InsCand;
			#				 print("=================UNSAT Cluase==============>>InsNode::",GREEN,"$elem\n\n");
							 $NumUNSATGate++; # increment of number of unsat GATE
							 if (grep(/^$map_h{$elem}$/,@result)){ # if map($elem) exists in truth assignment
							                                       # we should stuck the node at '1' else '0'
								  $InsertionType="1";
								  }
							  else{
								  $InsertionType="0";
								  }
							  $Insinfo_h{$elem}={"ConfType"=> "UNSAT",#confilict type
												 "GateType"=>$info_h{$elem}{"type"}, # confilict gate
					 							 "InsType"=> $InsertionType, # insertion type: stucked 1 or 0
												 "InsLoc"=> $elem,# output of gate is selected as insertion location
												 "fanin1"=> $info_h{$elem}{"fanin1"},
												 "fanin2"=> $info_h{$elem}{"fanin2"},
												 "#gate" =>$info_h{$elem}{"gatenumber"}
																};
							  }
						    }
				   }
				}
			}
	}# end of searching in soft clauses				
}	#next line of wcnf file(next cluase)				
close data;
## printing::
foreach my $elem (@InsCand){
			  if( !grep( $elem eq $_, @InsCandPre)){
				push(@InsSAT, $elem );# contain only UNSAT gates
				}
		}
# ****************************************************************************
#					Adding @AfterSAT nodes to @InsCand array 
#*****************************************************************************	
 foreach $rem(@Block){
		push (@InsCand,$rem)unless grep{$_ eq $rem} @InsCand;
		if(grep( $rem eq $_, @InsSAT )){
			@InsSAT = grep (!/$rem/,@InsSAT);
		}
		$ConfType="Block";
		$InsLoc=$rem;
			if (grep(/^$map_h{$rem}$/,@result)){ # if map($elem) exists in truth assignment
	                                      # we should stuck the node at '1' else '0'
				$InsertionType="1";
			}
			else{
				$InsertionType="0";
			}
						
			$Insinfo_h{$rem}={					 "ConfType"=>$ConfType,#confilict type
												 "GateType"=>$info_h{$rem}{"type"}, # confilict gate
					 							 "InsType"=> $InsertionType, # insertion type: stucked 1 or 0
												 "InsLoc"=> $InsLoc,# output of gate is selected as insertion location
												 "fanin1"=> $info_h{$rem}{"fanin1"},
												 "fanin2"=> $info_h{$rem}{"fanin2"},
												 "#gate" =>$info_h{$rem}{"gatenumber"}
																};
	 	
}
 foreach $rem(@BlockEX){
		push (@InsCand,$rem)unless grep{$_ eq $rem} @InsCand;
		if(grep( $rem eq $_, @InsSAT )){
			@InsSAT = grep (!/$rem/,@InsSAT);
		}
		$ConfType="BlockEX";
		$InsLoc=$info_h{$rem}{"fanin1"};	
			if (grep(/^$map_h{$rem}$/,@result)){ # if map($elem) exists in truth assignment
	                                      # we should stuck the node at '1' else '0'
				$InsertionType="1";
			}
			else{
				$InsertionType="0";
			}
						
			$Insinfo_h{$rem}={					 "ConfType"=>$ConfType,#confilict type
												 "GateType"=>$info_h{$rem}{"type"}, # confilict gate
					 							 "InsType"=> $InsertionType, # insertion type: stucked 1 or 0
												 "InsLoc"=> $InsLoc,# output of gate is selected as insertion location
												 "fanin1"=> $info_h{$rem}{"fanin1"},
												 "fanin2"=> $info_h{$rem}{"fanin2"},
												 "#gate" =>$info_h{$rem}{"gatenumber"}
																};
}  
@Blocking=(@Block,@BlockEX);
  print(YELLOW"================================================================================================\n");
  print(WHITE"                   Insertion Candidate Statistic....\n");
  print(YELLOW"=================================================================================================\n");
#*************************************************************************************
print("\n\n");
print(GREEN,"Statistic......\n");
#print(WHITE,"Number of Insertion (Block)::",scalar @Block,"\n");
#print(WHITE,"Number of Insertion (BlockEX)::",scalar @BlockEX,"\n");
print(WHITE,"Number of all Nodes/Variables::",scalar @Nodes,"\n");
print(WHITE,"Number of X Nodes::",scalar @X_sort,"\n");
#print("Number of Insertion(UNSAT)::$NumUNSATGate\n");
#print("Number of Insertion (NOT)::",scalar @NOT_conflict,"\n");
print(WHITE,"Number of Insertion (X-Conflict)::",scalar @X_conflict,"\n");
print(WHITE,"Number of Insertion (SFN-Conflict)::",scalar @DiffType_conflict,"\n");
#print("Number of Insertion (X,SFN,NOT)::",GREEN,scalar @InsCandPre,"\n");
#print("Number of Insertion (X,SFN,NOT,Blocking,UNSAT)::",GREEN,scalar @InsCand,"\n");
print(WHITE,"Number of Insertion (Blocking-Conflict)::",scalar @Blocking,"\n");
print(WHITE,"Number of Insertion (UNSAT-Conflict)::",scalar @InsSAT,"\n");
#print("Number of Insertion (UNSAT)::\n@InsSAT\n");
#print("Number of Insertion (Block)::\n@Block\n");
#print("Number of Insertion (Block2)::\n@Block2\n");



#print(CYAN,"Selected Candidates(UNSAT Conflict):: @PostInsCand\n");
#print(CYAN,"Selected Candidates(Blocking Conflict):: @Blocking\n");

print("===============================================================================================================\n");
print(CYAN,"#gate\tout\t       type\tfanin1\t    fanin2  ConfType  InsType\tInsLoc\t  TypeGateIns  Depth\n==========================================================================================================  \n");

$numm=0;
foreach $var (@InsCand){    # @InsCand contains all the candidate insertion nodes including Not_conflict
	$type=$Insinfo_h{$var}{"GateType"};
	$gatenum=$Insinfo_h{$var}{"#gate"};
	$out=$var;
	$fanin1=$Insinfo_h{$var}{"fanin1"};
	$fanin2=$Insinfo_h{$var}{"fanin2"};
	$ConfilictType=$Insinfo_h{$var}{"ConfType"};
	$InsertionType=$Insinfo_h{$var}{"InsType"};
	$InsertionLoc=$Insinfo_h{$var}{"InsLoc"};
	$TypeGateIns=$info_h{$InsertionLoc}{"type"};
	$InsDepth=$info_h{$InsertionLoc}{"MaxDepth"};
	push(@InsDepth, $InsDepth) unless grep{$_ eq $InsDepth} @InsDepth; 
	if($type eq NOT1 && grep( /^$var$/, @InsCandPre)){ # extract selected insertion node(@InsCand - @Not_conflict)
		# or we can write the nodes belong to @Not_conflict
		}
	else{
		$numm++;
		push(@FinalInsCand,$var);
		#print("#$gatenum\t$out\t          $type\t $fanin1\t $fanin2\t   $ConfilictType\t$InsertionType\t $InsertionLoc\t $TypeGateIns\n");
		printf ("%-5d  #%-5d  %-8s\t%-5s \t%-10s  %-10s  %-7s  %-5s \t%-10s\t%-6s %-4d\n",
		    $numm, $gatenum, $out, $type,$fanin1,$fanin2,$ConfilictType,$InsertionType,$InsertionLoc,$TypeGateIns,$InsDepth);
		}	
	}
print("==========================================================================================================\n");
print(WHITE,"\n");
print(YELLOW,"END of Extraction of UNSAT Clauses...........................................\n\n");
#===== Input test-vector ==============================================			
	foreach $var(@result){
		$check=$map_rev_h{abs($var)};
		if ( grep( /^$check$/, @X_inp ) ) {
			$modi_inp_h{$check}='X';
			}
		elsif ($info_h{$check}{"type"} eq INPUT1) {
			if($var<0){
				$value=0;
				}
			else{
				$value=1;
				}
			$modi_inp_h{$check}=$value; # this is hash 
			}	
		}
		
foreach $kel (keys %modi_inp_h){
     if($modi_inp_h{$kel} eq X ){
		 push(@inp_XVal,$kel);
		 }	
     elsif($modi_inp_h{$kel} eq 1 ){
		 push(@inp_1Val,$kel);
		 }
	elsif($modi_inp_h{$kel} eq 0 ){
		 push(@inp_0Val,$kel);
		 }	 	 
}	
  print(YELLOW"================================================================================================\n");
  print(WHITE"                   Test Vector Generation....\n");
  print(YELLOW"=================================================================================================\n");
print("Input with X value::","(",scalar @inp_XVal,")::\n", join(',',@inp_XVal ),"\n");
print("\nInput with 1 value::","(",scalar @inp_1Val,")::\n", join(',',@inp_1Val ),"\n");
print("\nInput with 0 value::","(",scalar @inp_0Val,")::\n", join(',',@inp_0Val ),"\n");

print("\n\n");

foreach $var(@FinalInsCand){ # extract insertion node which are input node(these nodes dont need insertion)
	$infoLoc_h{$Insinfo_h{$var}{"InsLoc"}}=$var;
	push(@InsCandInd,$Insinfo_h{$var}{"#gate"});
	push(@FinalInsCandNonDup,$var) unless grep{$_ eq $Insinfo_h{$var}{"InsLoc"}} @InsertNode; # non_duplicate
	push(@InsertNode,$Insinfo_h{$var}{"InsLoc"}) unless grep{$_ eq $Insinfo_h{$var}{"InsLoc"}} @InsertNode; # non_duplicate
		if($info_h{$Insinfo_h{$var}{"InsLoc"}}{"type"} eq INPUT1){
#		print($Insinfo_h{$var}{"InsLoc"}," is input and must be stucked at::",$Insinfo_h{$var}{"InsType"},"\n");
		push(@InsertNodeInp,$Insinfo_h{$var}{"InsLoc"}) unless grep{$_ eq $Insinfo_h{$var}{"InsLoc"}} @InsertNodeInp;
		}
	}
# FinalInsCand:: Contain all the insertion condidate in table
# InsertNode:: Contain all the insertion location in table
# InsCandInd:: Conrain all the index of insertion candidate
# InsertNodeInp:: contain all the input insertion locations 
	
print(CYAN,"\nTotal Insertion Gate::",scalar @FinalInsCand,"\n","@FinalInsCand\n");
#print(CYAN,"Total Insertion Gate(Non_Dup)::",scalar @FinalInsCandNonDup,"\n","@FinalInsCandNonDup\n");			
print(CYAN,"\nNon duplicate Insertion ::",scalar @InsertNode,"\n@InsertNode \n");	
#print(CYAN,"Insertion Nodes(inputs)::@InsertNodeInp\n");
#print(CYAN,"Level of insertions::",(scalar @InsDepth)-1,"\n@InsDepth\n");
#*********************************\**************************************************************
print (YELLOW,"....End of Processing..............................\n");
print("\n");
  print(YELLOW"================================================================================================\n");
  print(WHITE"                                 Auto Insertion Procedure.....\n");
  print(YELLOW"=================================================================================================\n");

#nand NAND2_283 (I39, I38, N379);
$cnt=9000;
open(data,"< $Design");
open(data1,">Design_1.v");
 while($line=<data>){
	 if($line=~m /\s+ \(\w+/x){
		 my($var)=$line=~m /\s+\((\w+) /x;
		if(grep( $var eq $_, @FinalInsCand )){ 
		   my $instype=$Insinfo_h{$var}{"InsType"};
		   my $loc=$Insinfo_h{$var}{"InsLoc"};
		      if($Insinfo_h{$var}{"ConfType"} eq 'X' || $Insinfo_h{$var}{"ConfType"} eq 'DiffType'){
					my($ind)=$line=~m /\s+ \w+_(\d+)/x;
					my $perInd= $ind-1;
					my($indg)=$perInd.'g';
					my($locg)=$loc.'g';
					push(@NewWire,$locg)unless grep{$_ eq $locg} @NewWire;
						if($instype==1){
							 print(data1 "or OR2_$cnt ($locg, TE, $loc);\n");
							 $cnt++;
						}
						else{
							 print(data1 "and AND2_$cnt ($locg, ~TE, $loc);\n");
							 $cnt++;
						}
				    $line=~s /$loc/$locg/x;
					print(data1 "$line");
			  }
			  elsif($Insinfo_h{$var}{"ConfType"} eq 'BlockEX' ){
				    my($ind)=$line=~m /\s+ \w+_(\d+)/x;
					my $perInd= $ind-1;
					my $perInd1= $ind-2;
					my($indg)=$perInd.'g';
					my($indg1)=$perInd1.'g';
					if($info_h{$var}{"type"} eq AND2){
					      if($instype==0){
							 $locg=$loc.'g';
							 push(@NewWire,$locg)unless grep{$_ eq $locg} @NewWire;
							 print(data1 "and AND2_$cnt ($locg, ~TE, $loc);\n");
							 $cnt++;
							 $line=~s /$loc/$locg/x;
					         print(data1 "$line");
						  }
						  else{
							 $loc1=$info_h{$var}{"fanin2"};
							 $locg=$loc.'g';
							 $locg1=$loc1.'g';
							 push(@NewWire,$locg)unless grep{$_ eq $locg} @NewWire;
							 push(@NewWire,$locg1)unless grep{$_ eq $locg1} @NewWire;
							 print(data1 "or OR2_$cnt ($locg1, TE, $loc1);\n");$cnt++;
							  print(data1 "or OR2_$cnt ($locg, TE, $loc);\n");$cnt++;
							  $line=~s /$loc/$locg/x;
							  $line=~s /$loc1/$locg1/x;
					          print(data1 "$line");
						  }
					}
					elsif($info_h{$var}{"type"} eq NAND2){
					      if($instype==1){
							 $locg=$loc.'g';
							 push(@NewWire,$locg)unless grep{$_ eq $locg} @NewWire;
							 print(data1 "and AND2_$cnt ($locg, ~TE, $loc);\n");$cnt++;
							 $line=~s /$loc/$locg/x;
					         print(data1 "$line");
						  }
						  else{
							 $loc1=$info_h{$var}{"fanin2"};
							 $locg=$loc.'g';
							 $locg1=$loc1.'g';
							 push(@NewWire,$locg)unless grep{$_ eq $locg} @NewWire;
							 push(@NewWire,$locg1)unless grep{$_ eq $locg1} @NewWire;
							 print(data1 "or OR2_$cnt ($locg1, TE, $loc1);\n");$cnt++;
							  print(data1 "or OR2_$cnt ($locg, TE, $loc);\n");$cnt++;
							  $line=~s /$loc/$locg/x;
							  $line=~s /$loc1/$locg1/x;
					          print(data1 "$line");
						  }
					}
					elsif($info_h{$var}{"type"} eq OR2){
					      if($instype==1){
							 $locg=$loc.'g';
							 push(@NewWire,$locg)unless grep{$_ eq $locg} @NewWire;
							  print(data1 "or OR2_$cnt ($locg, TE, $loc);\n");$cnt++;
							  $line=~s /$loc/$locg/x;
					          print(data1 "$line");
						  }
						  else{
							 $loc1=$info_h{$var}{"fanin2"};
							 $locg=$loc.'g';
							 $locg1=$loc1.'g';
							 push(@NewWire,$locg)unless grep{$_ eq $locg} @NewWire;
							 push(@NewWire,$locg1)unless grep{$_ eq $locg1} @NewWire;
							 print(data1 "and AND2_$cnt ($locg1, ~TE, $loc1);\n");$cnt++;
							  print(data1 "and AND2_$cnt ($locg, ~TE, $loc);\n");$cnt++;
							  $line=~s /$loc/$locg/x;
							  $line=~s /$loc1/$locg1/x;
					          print(data1 "$line");
						  }
					}
					else{ # NOR
						  if($instype==0){
							 $locg=$loc.'g';
							 push(@NewWire,$locg)unless grep{$_ eq $locg} @NewWire;
							  print(data1 "or OR2_$cnt ($locg, TE, $loc);\n");$cnt++;
							  $line=~s /$loc/$locg/x;
					          print(data1 "$line");
						  }
						  else{
							 $loc1=$info_h{$var}{"fanin2"};
							 $locg=$loc.'g';
							 $locg1=$loc1.'g';
							 push(@NewWire,$locg)unless grep{$_ eq $locg} @NewWire;
							 push(@NewWire,$locg1)unless grep{$_ eq $locg1} @NewWire;
							 print(data1 "and AND2_$cnt ($locg1, ~TE, $loc1);\n");$cnt++;
							  print(data1 "and AND2_$cnt ($locg, ~TE, $loc);\n");$cnt++;
							  $line=~s /$loc/$locg/x;
							  $line=~s /$loc1/$locg1/x;
					          print(data1 "$line");
						  }
					}
					
			  }
			  else{
				 # print(YELLOW,"$var\n");
					my($ind)=$line=~m /\s+ \w+_(\d+)/x;
					my($indg)=$ind.'g';
					my($locg)=$loc.'g';
				    $line=~s /\($loc,/\($locg,/x;
					print(data1 "$line");
					#print("$line");
					push(@NewWire,$locg)unless grep{$_ eq $locg} @NewWire;
						if($instype==1){
							 print(data1 "or OR2_$cnt ($loc, TE, $locg);\n");$cnt++;	
						}
						else{
							 print(data1 "and AND2_$cnt ($loc, ~TE, $locg);\n");$cnt++;
						}
			  }	  
		}
		else{
		  print(data1 "$line");	
		 } 
	}
	else{
	     print(data1 "$line");	
	}	 
}
close data;
close data1;
print(GREEN,"New Wires that must be added to Design::\n @NewWire\n");
#********************** Adding Extra node to design ************************************
$test=join(',',@NewWire);
$test=$test.',';
open (data, "+<Design_1.v") or die "Can't open $file: $!\n";
open (data1, ">Design_sec.v") or die "Can't open $file: $!\n";
while($line=<data>){
    chomp($line);
	if ($line=~m/wire/x){
	    $line=~s/wire\s+/wire $test/;
	    print(data1 "$line\n");
	}
    elsif($line=~m/module/x){
	    $line=~s/Design\s+ \(/Design_sec\(TE,/x;
	    print(data1 "$line\n");
	}
	elsif($line=~m/input/x){
	    $line=~s/input\s+/input TE,/;
	    print(data1 "$line\n");
	}
	else{
	    print(data1 "$line\n"); 	
	}
	 
}
	
close data;
close data1;
#deleting temp files
unlink glob "Design_1.v";  # delete intermediate file 

$end=time;
$duration=$end-$start;
print(CYAN,"\n\nRun Time (Sec)::$duration\n\n\n");

print (YELLOW,"....Automatic Insertion Done..............................\n");
#print(WHITE,"#LT Node(Pth=$Pth)::",GREEN,"$LTnum\n");

#  print(YELLOW"================================================================================================\n");
#  print(YELLOW"                                  Updating TB_Design_sec.v.....\n");
#  print(YELLOW"=================================================================================================\n");
#  #@inp_XVal
#   open(data_in,"< TB_Design_sec.v");
#   open(data_out,">TB_Design_sec_temp.v");
#   $i=23;$j=1;
#   $num=scalar @inp_XVal;
#   $num1=scalar @inp_1Val;
#   $num2=scalar @inp_0Val;
#       while($line=<data_in>){
#			if($line=~m/repeat/){
#				print(data_out "$line");
#				print(data_out "\n");
#				while($num!=0){
#					loop1:for $i(1..$i){
#						if($num==0){
#							last loop1;
#						}
#						else{
#							$samp=shift(@inp_XVal);
#						    $num=scalar @inp_XVal;
#							push(@myline,$samp);
#						}
#					}
#					$line=join(',',@myline);
#					$line='{'.$line.'}=$urandom;';
#					print(data_out "$line\n");
#					@myline=();
#					$num=scalar @inp_XVal;
#				}
#				print(data_out "\n");
#				push(@myline,'TE');
#				while($num1!=0){
#					loop2:for $i(1..$i){
#						if($num1==0){
#							last loop2;
#						}
#						else{
#							$samp=shift(@inp_1Val);
#						    $num1=scalar @inp_1Val;
#							push(@myline,$samp);
#						}
#					}
#					$line=join(',',@myline);
#					$line='{'.$line.'}=-1;';
#					print(data_out "$line\n");
#					@myline=();
#					$num1=scalar @inp_1Val;
#				}
#				print(data_out "\n");
#				while($num2!=0){
#					loop3:for $i(1..$i){
#						if($num2==0){
#							last loop3;
#						}
#						else{
#							$samp=shift(@inp_0Val);
#						    $num2=scalar @inp_0Val;
#							push(@myline,$samp);
#						}
#					}
#					$line=join(',',@myline);
#					$line='{'.$line.'}=0;';
#					print(data_out "$line\n");
#					@myline=();
#					$num2=scalar @inp_0Val;
#				}
#				
#			}
#			else{
#				print(data_out "$line");
#			}
#	   }
#close data_in;
#close data_out;
#copy "TB_Design_sec_temp.v","TB_Design_sec.v";
#unlink "TB_Design_sec_temp.v";
#
#
#print("\n\n\n");
#  print(YELLOW"================================================================================================\n");
#  print(YELLOW"                                  Dummy TE Insertion.....\n");
#  print(YELLOW"=================================================================================================\n");
##print("@InsertNode\n");
##print("@InsDepth\n");
## extract number of insertion gate in each level
#foreach $lev (@InsDepth){
#	$NumInsGate=0;
#	foreach $rec (@InsertNode){
#	    if($info_h{$rec}{"MaxDepth"}==$lev){
#			$NumInsGate++;
#		}	
#	}
#   $NumIns_h{$lev}=$NumInsGate;	
#}
#@InsDepth=sort({$a <=> $b}@InsDepth); # Ascending order
#shift (@InsDepth);
#foreach $var(@InsDepth){
#   print("Level::$var =>", $NumIns_h{$var},"\n");
#}
#
#
