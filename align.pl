#!/usr/bin/perl
use strict;

my (@lines);
my (@in_files);
my (@line_split);
my (@pre_when);
my (@post_when);
my ($in_file);
my ($line);
my ($num);
my ($argument);
my ($count_line);
my ($i,$j,$m,$a,$k);
my ($count);
my ($count_comma);

my ($architect_begin);
my ($port_begin);
my ($colon);
my ($letter);
my ($semi);
my ($entity_name);
my ($arch_name);
my ($signal);
my ($constant);
my ($component);
my ($entity_start);
my ($first_noncomment);
my ($count_open);
my ($count_close);
my ($entity_end);
my ($one_ref);
my ($two_ref);
my ($third_ref);



#First new Statements....
print "\n****************************************************************************
               Honeywell Confidential and Proprietary
 This work contains valuable confidential and proprietary information.
 Disclosure, use or reproduction outside of Honeywell, Inc. is prohibited
 except as authorized in writing. This unpublished work is protected by
 the laws of the United States and other countries. If publication occurs,
 following notice shall apply:
                     Copyright 2009, Honeywell Inc.
                         All rights reserved.
                Freedom of Information Act(5 USC 522) and
         Disclosure of Confidential Information Generaly(18 USC 1905)
 This material is being furnished in confidence by Honeywell, Inc. The
 information disclosed here falls within Exemption (b)(4) of 5 USC 522
 and the prohibitions of 18 USC 1905
****************************************************************************
\n\n";

print "\n NOTE :- This may introduce syntax error. So, kindly cross-verify it with the";
print "\n         original file\n\n";

#==============================================================================
# It tap the arguments
#==============================================================================
while ($#ARGV >= 0)
{
  $argument = shift(@ARGV);
  if ($argument eq "*.vhd")
  {
    @in_files = <*.vhd>;
  }
  else
  {
    @in_files = $argument;
  }

  for $in_file (@in_files)
  {
    chomp($in_file);   
    print "Input is : ",$in_file,"\n";

    open (INPUT, "<$in_file") || die("File doesnt exist or cannot open that file");
    mkdir("new_files", 0777);
    open OUTPUT, ">test1.vhd";
    @lines = <INPUT>; 
    close INPUT;
    #==============================================================================
    # To bring the comments to a single line
    #==============================================================================
    for $line(@lines)
    {
      chomp($line);
      $line =~ s/^\s*(\S*)/$1/;
      if($line !~ m/^--/)
      {
        $num=index($line,"--");
  	    if($num ne "-1"){
          print OUTPUT substr($line,index($line,"--")),"\n";
          print OUTPUT substr($line,0,index($line,"--")-1),"\n";
        }
        else {print OUTPUT $line,"\n";}	    
      }	
      else{print OUTPUT $line,"\n";}
    }    
    close OUTPUT;
	$k = 0;

	#==============================================================================
    # To remove the new line
    #==============================================================================
    open INPUT, "<test1.vhd";
    open OUTPUT, ">test2.vhd";
    @lines = <INPUT>; 
    close INPUT;	
	
    for $line(@lines)
    {
      if($line ne "\n")
      {
        $line =~ s/^\s*//;  
        print OUTPUT $line;
      }    	    
    }    
    close OUTPUT;
	
    #==============================================================================
    # To remove the new line
    #==============================================================================	
    open INPUT, "<test2.vhd";
    open OUTPUT, ">test3.vhd";
    @lines = <INPUT>; 
    close INPUT;
    $count_line=@lines;

    for($i=0;$i<$count_line;$i++)
    {
      chomp($lines[$i]);
      if ($lines[$i] =~ m/--/ || $lines[$i] !~ m/;/)
      {
        if(($lines[$i] =~ m/--\s(Signal|Constant|Component)\sDeclarations\./ && $lines[$i+1] =~ m/\-{77}/) ||
           ($lines[$i] =~ m/--\sLibrary\sDeclarations\./ && $lines[$i+1] =~ m/\={75}/)){
          $i = $i + 1;}
        elsif($lines[$i]=~ m/--/ && $lines[$i+1]=~ m/BEGIN/ && $lines[$i]=~ m/\-{79}/){
          $i = $i + 2;}	
        else{
          print OUTPUT $lines[$i],"\n";}
      }	  
      else
      {
        $count = ($lines[$i] =~ tr/;//);
        #$single_line=;
        @line_split = split(/;/,$lines[$i]);    	 
        for ($j=0;$j < $count; $j++)
        {
          chomp($line_split[$j]);
          $line_split[$j] =~ s/^\s*//;	  
          print OUTPUT $line_split[$j],";","\n";
        }    
      }
    }
    close OUTPUT;
	
    #==============================================================================
    # To split the line has has more closing bracket with opening bracket
    #==============================================================================	
    open INPUT, "<test3.vhd";
    open OUTPUT, ">test4.vhd";
    @lines = <INPUT>; 
    close INPUT;

    $semi = 0;
    for $line(@lines)
    {
      chomp($line);
      if($line=~ m/port|generic\s*map/i){
        $semi = 1;}
      if($semi eq 1){
        $count_comma = ($line =~ tr/,//);
        @line_split = split(/,/,$line);    
        for ($a=0;$a < $count_comma; $a++){                
          print OUTPUT $line_split[$a],",","\n";
        }      
        print OUTPUT $line_split[$count_comma],"\n";
        if($line =~ m/\;\s*$/){
          $semi=0;}
      }
      else{
        print OUTPUT $line,"\n";}     
    }
    close OUTPUT;	
	
    #==============================================================================
    # Spliting of multiple signal/variable names
    #==============================================================================
	
    open INPUT, "<test4.vhd";
    open OUTPUT, ">test5.vhd";
    @lines = <INPUT>; 
    close INPUT;
    $architect_begin = 0;
    $port_begin = 0;

    for $line(@lines)
    {
      chomp($line);
      if ($line =~ m/--/){ 
        print OUTPUT $line,"\n";        
      }	  
      else{   
	  
        if($line=~ m/^begin/i){
          $architect_begin = 1;}
        elsif($line=~ m/port|generic/i){
          $port_begin = 1;}
        elsif($line =~ m/end/i){
          $port_begin = 0;}
		  
        if($line =~ m/\,/ && $architect_begin eq 0 && $port_begin eq 1){     
          $colon = substr($line,index($line,":"));
          $count = ($line =~ tr/,//);
          @line_split = split(/,/,$line);
          for ($i=0;$i < $count; $i++){        
            print OUTPUT $line_split[$i],$colon,"\n";
          }      
          print OUTPUT $line_split[$count],"\n";	  
        }
        elsif($line=~ m/^\s*(signal|variable)\s+/i && $line =~ m/\,/){      
          if ($line=~ m/signal/i){
            $letter = "SIGNAL ";}
          else{
            $letter = "VARIABLE ";
          }      
          $colon = substr($line,index($line,":"));	  
          $count = ($line =~ tr/,//);
          @line_split = split(/,/,$line);
          chomp($line_split[0]);
          print OUTPUT $line_split[0], $colon,"\n";
          for ($i=1;$i < $count; $i++){
            chomp($colon);
            $line_split[$i]=~ s/\s*(\S)/$1/;
            print OUTPUT $letter,$line_split[$i],$colon,"\n";
          }
          print OUTPUT $letter,$line_split[$count],"\n";      	  
        }   
        else {
          print OUTPUT $line,"\n";}    	    
      }
    }
    close OUTPUT;
	
    #==============================================================================
    # Spliting of multiple signal/variable names
    #==============================================================================	
	
    open INPUT, "<test5.vhd";
    open OUTPUT, ">test6.vhd";
    @lines = <INPUT>; 
    close INPUT;

    for $line(@lines)
    {
      chomp($line);
      if($line !~ m/^--/)
      {
        $line =~ s/\s*:\s*/ : /;
	
        $line =~ s/use\s+/USE /i;
        $line =~ s/library\s+/LIBRARY /i;
        $line =~ s/ieee/IEEE/i;
        $line =~ s/conv\_integer\s*\(/CONV_INTEGER(/i;
	
        $line =~ s/numeric\_std/NUMERIC_STD/i;
        $line =~ s/STD\_LOGIC\_ARITH/STD_LOGIC_ARITH/i;
        $line =~ s/NUMERIC\_STD/NUMERIC_STD/i;
        $line =~ s/std\_logic\_unsigned/STD_LOGIC_UNSIGNED/i;
        $line =~ s/std\_logic\_signed/STD_LOGIC_SIGNED/i;
        $line =~ s/numeric\_bit/NUMERIC_BIT/i;
        $line =~ s/std\_logic\_misc/STD_LOGIC_MISC/i;
	
        $line =~ s/std\_logic\_vector/STD_LOGIC_VECTOR/i;
        $line =~ s/std\_logic\_vector\s*\(/STD_LOGIC_VECTOR(/i;
        $line =~ s/std_logic/STD_LOGIC/i;
        $line =~ s/\s+is/ IS/i;
        $line =~ s/entity\s*/ENTITY /i;
        $line =~ s/end\s*/END /i;
        $line =~ s/architecture\s*/ARCHITECTURE /i;
        $line =~ s/port\s+map/PORT MAP/i;	
        $line =~ s/(\s|^)port/PORT/i;
        $line =~ s/generic\s+map/GENERIC MAP/i;
        $line =~ s/(\s|^)generic/GENERIC/i;
        $line =~ s/\s+in\s+/ IN  /i;
        $line =~ s/\s+out\s+/ OUT /i;
        $line =~ s/\s+inout\s+/ INOUT /i;
        $line =~ s/\s+(d|D)(o|O)(w|W)(n|N)(t|T)(o|O)\s+/ DOWNTO /g;
        $line =~ s/constant\s+/CONSTANT /i;
        $line =~ s/\s+integer/ INTEGER/i;
        $line =~ s/\s+natural/ NATURAL/i;
        $line =~ s/\s+signed/ SIGNED/i;
        $line =~ s/\s+unsigned/ UNSIGNED/i;
        $line =~ s/\s+range\s+/ RANGE /i;
        $line =~ s/(\S*)begin(\S*)/$1\nBEGIN\n$2/i;
        $line =~ s/for\s+/FOR /i;    
        $line =~ s/\s+to\s+/ TO /i;
        $line =~ s/generate/GENERATE/i;
        $line =~ s/if\s*\(/IF (/i;	
        $line =~ s/if\s+/IF /i;
        $line =~ s/\s+of/ OF/i;
        $line =~ s/elsif\s*\(/ELSIF (/i;
        $line =~ s/elsif\s+/ELSIF /i;
        $line =~ s/else/ELSE/i;
		$line =~ s/else\s?(\S*)/ELSE\n$1/ig;
        $line =~ s/end\s+process\s*/END PROCESS /i;	
        $line =~ s/process\s*\(/PROCESS (/i;
        $line =~ s/process\s*/PROCESS /i;
        $line =~ s/variable\s+/VARIABLE /i;
        $line =~ s/^signal\s+/SIGNAL /i;
        $line =~ s/type\s+/TYPE /i;    
        $line =~ s/when\s*/WHEN /i;
        $line =~ s/\)\s*then/) THEN/i;
        $line =~ s/\s+then/ THEN/i;
        $line =~ s/(o|O)(t|T)(h|H)(e|E)(r|R)(s|S)/OTHERS/g;	
        $line =~ s/end\s+case\s*\;/END CASE;/i;
        $line =~ s/end\s+case/END CASE /i;
        $line =~ s/case\s+/CASE /i;
        $line =~ s/case\s*\(/CASE (/i;
        $line =~ s/null/NULL/i;
        $line =~ s/library\s+/LIBRARY /i;
        $line =~ s/all\s*\;/ALL;/i;
        $line =~ s/procedure/PROCEDURE/i;
        $line =~ s/function/FUNCTION/i;
        $line =~ s/end\s+loop/END LOOP/i;
        $line =~ s/end\s+if/END IF/i;
        $line =~ s/loop/LOOP /i;
		
        $line =~ s/wait/WAIT/i;
        $line =~ s/until/UNTIL/i;
        $line =~ s/report/REPORT/i;		
	
        $line =~ s/end\s+component/END COMPONENT/i;
        $line =~ s/component\s+/COMPONENT /i;
		
        $line =~ s/\)\s*and\s*\(/) AND (/ig;
        $line =~ s/\)\s*and\s*/) AND /ig;
        $line =~ s/\s+and\s*\(/ AND (/ig;
        $line =~ s/\s+and\s+/ AND /ig;
	
        $line =~ s/\)\s*nand\s*\(/) NAND (/ig;
        $line =~ s/\)\s*nand\s*/) NAND /ig;
        $line =~ s/\s+nand\s*\(/ NAND (/ig;
        $line =~ s/\s+nand\s+/ NAND /ig;
	
        $line =~ s/\)\s*or\s*\(/) OR (/ig;
        $line =~ s/\)\s*or\s*/) OR /ig;
        $line =~ s/\s+or\s*\(/ OR (/ig;
        $line =~ s/\s+(o|O)(r|R)\s+/ OR /ig;
	
        $line =~ s/\)\s*nor\s*\(/) NOR (/ig;
        $line =~ s/\)\s*nor\s*/) NOR /ig;
        $line =~ s/\s*nor\s*\(/ NOR (/ig;
        $line =~ s/\s+nor\s+/ NOR /ig;
	
        $line =~ s/\)\s*xor\s*\(/) XOR (/ig;
        $line =~ s/\)\s*xor\s*/) XOR /ig;
        $line =~ s/\s+xor\s*\(/ XOR (/ig;
        $line =~ s/\s+xor\s+/ XOR /ig;
	
        $line =~ s/\)\s*xnor\s*\(/) XNOR (/ig;
        $line =~ s/\)\s*xnor\s*/) XNOR /ig;
        $line =~ s/\s+xnor\s*\(/ XNOR (/ig;
        $line =~ s/\s+xnor\s+/ XNOR /ig;
	
        $line =~ s/not\s*\(/NOT (/ig;
        $line =~ s/not\s+/NOT /ig;
	
        $line =~ s/falling\_edge/FALLING_EDGE/i;
        $line =~ s/rising\_edge/RISING_EDGE/i;
	
        $line =~ s/\(?(\S*)\s*\=\s*\'1\'\s+and\s+(\S*)\s*\'(e|E)(v|V)(e|E)(n|N)(t|T)\)?/RISING_EDGE($1)/i;
        $line =~ s/\(?(\S*)\s*\=\s*\'0\'\s+and\s+(\S*)\s*\'(e|E)(v|V)(e|E)(n|N)(t|T)\)?/FALLING_EDGE($1)/i;
        $line =~ s/\(?(\S*)\s*\'(e|E)(v|V)(e|E)(n|N)(t|T)\s+and\s+(\S*)\s*\=\s*\'1\'\)?/RISING_EDGE($1)/i;
        $line =~ s/\(?(\S*)\s*\'(e|E)(v|V)(e|E)(n|N)(t|T)\s+and\s+(\S*)\s*\=\s*\'0\'\)?/FALLING_EDGE($1)/i;
	
        $line =~ s/with\s+/WITH /ig;
        $line =~ s/\s+select\s+/ SELECT /ig;  
        $line =~ s/\s*\=\s*/ = /;
        $line =~ s/\s*<\s*=\s*/ <= /;
        $line =~ s/\s*=\s*>\s*/ => /;	
	
        $line =~ s/^\s*\(\s*(\S+)/$1/;
        $line =~ s/\(\s*(\S+)/($1/g;
        $line =~ s/^\s*\(\s*$//g;
        $line =~ s/\s*,\s*/, /g;
        $line =~ s/\s*;\s*/;/;
        $line =~ s/\s*\)/)/;
        $line =~ s/\(\s*/(/;
        $line =~ s/:\s+\=/:=/;
	
        $line =~ s/PORT\sMAP\s*\(*/PORT MAP (/;
        $line =~ s/GENERIC\sMAP\s*\(*/GENERIC MAP (/;
        if ($line !~ m/MAP/){
          $line =~ s/(\s|^)PORT\s*\(*/PORT (/;$line =~ s/(\s|^)GENERIC\s*\(*/GENERIC (/;
        }
		
        $line =~ s/(\S\s*)PORT\sMAP\s\(/$1\nPORT MAP (/;
        $line =~ s/(\S\s*)GENERIC\sMAP\s\(/$1\nGENERIC MAP (/;
        $line =~ s/(\S\s*)PORT\s\(/$1\nPORT (/;
        $line =~ s/(\S\s*)GENERIC\s\(/$1\nGENERIC (/;	  
	
        $line =~ s/(PORT\sMAP\s\()(\S)/$1\n$2/;	
        $line =~ s/(GENERIC\sMAP\s\()(\S)/$1\n$2/;	
        $line =~ s/(PORT\s\()(\S)/$1\n$2/;
        $line =~ s/(GENERIC\s\()(\S)/$1\n$2/;	
      }
      print OUTPUT $line,"\n";
    }
    close OUTPUT;
	
    #==============================================================================
    # Spliting the brackets
    #==============================================================================		
	
    open INPUT, "<test6.vhd";
    open OUTPUT, ">test7.vhd";
    @lines = <INPUT>; 
    close INPUT;
    for $line(@lines)
    {
      chomp($line);
      if ($line !~ m/--/){ 
        $count_open = ($line =~ tr/(//);
        $count_close = ($line =~ tr/)//);
        if ($count_close > $count_open){
          $line =~ s/(\S*)\)\;/$1\n);/       
        }
        print OUTPUT $line,"\n";
      }
      else{
        print OUTPUT $line,"\n";}
    }
    close OUTPUT;
	
    #==============================================================================
    # tapping the entity and architecture name
    #==============================================================================	
    
	
    open INPUT, "<test7.vhd";
    @lines = <INPUT>; 
    close INPUT;
    
    for $line(@lines){
      if ($line =~ m/^ENTITY/){
        @line_split = split(/ /, $line);      
        $entity_name=$line_split[1];
      }
      if ($line =~ m/^ARCHITECTURE/){
        @line_split = split(/ /, $line);      
        $arch_name=$line_split[1];
      }
    }
	
	#==============================================================================
    # converting all keywords from lower case to upper case
    #==============================================================================

    open INPUT, "<test7.vhd";
    open OUTPUT, ">test8.vhd";
    @lines = <INPUT>; 
    close INPUT;

    $architect_begin = 0;
    $entity_end = 0;
    $count = @lines;
    $semi = 0;
    for ($a=0;$a<$count;$a++){
      chomp($lines[$a]);  
      if ($lines[$a] !~ m/^--/){
        if ($lines[$a] =~ m/^LIBRARY/ || $lines[$a] =~ m/^USE/){
          print OUTPUT $lines[$a],"\n";
        }
        elsif ($lines[$a] =~ m/^ENTITY|^COMPONENT/ && $architect_begin eq 0){	  
          ($k,$a)=entity_component($k,$a,\@lines);	  
        }		
        elsif ($lines[$a] =~ m/PORT\sMAP|GENERIC\sMAP/){
          ($k,$a)=port_generic_map($k,$a,\@lines);
        }	
        elsif ($lines[$a] =~ m/^\s*(SIGNAL|CONSTANT|VARIABLE)\s+/ && $architect_begin eq 0){
          ($k,$a)=signal_allign($k,$a,\@lines);  		  
        }	  	          	
        elsif ($lines[$a] =~ m/^ARCHITECTURE/ || $lines[$a] =~ m/^PORT/ || ($lines[$a] =~ m/PROCESS/ && $lines[$a] !~ m/END/)){
          space($k); 
          print OUTPUT $lines[$a],"\n";	
          $k=$k+2;
        }
        elsif($lines[$a] =~ m/\s+GENERATE/ && $lines[$a] !~ m/END/){
          space($k); 
          print OUTPUT $lines[$a],"\n";	
          $k=$k+2;
          if($lines[$a+1] !~ m/--/){
            space($k); 
            print OUTPUT "--\n";
          }
        }
        elsif ($lines[$a] =~ m/^END\s*ARCHITECTURE/i || $lines[$a] =~ m/^END\s*\b$arch_name\b*\s*(;)/){
          print OUTPUT "END ARCHITECTURE ",$arch_name,";\n";      
        }		
        elsif($lines[$a] =~ m/END/ && $entity_end eq 0){  
          $k = $k -2;	
          space($k); 
          print OUTPUT "END ENTITY ",$entity_name,";\n";       
          $entity_end = 1;
        }   	          		  	 
        elsif ($lines[$a] =~ m/^BEGIN/ && $architect_begin eq 0){      	
          $architect_begin = 1;		
          first_begin($k,$lines[$a]);
          if($lines[$a+2] !~ m/--/){
            space($k); 
            print OUTPUT "--\n";
          }
        }
        elsif ($lines[$a] =~ m/^BEGIN/ && $architect_begin eq 1){      	
          space($k-2);        		
          print OUTPUT $lines[$a],"\n";
        }	
        elsif ($lines[$a] =~ m/^CASE/){      
          ($one_ref, $two_ref) = case_when($k,$a,$lines[$a],\@pre_when,\@post_when,\@lines);
          @pre_when = @$one_ref;
          @post_when = @$two_ref;
          $k = $k + 2;	  	  
        }
        elsif ($lines[$a] =~ m/^END\sCASE/){ 
          ($one_ref, $two_ref, $third_ref) = end_case($lines[$a],\@pre_when,\@post_when);
          $k = $one_ref;
          @pre_when = @$two_ref;
          @post_when = @$third_ref;
        }	
        elsif ($lines[$a] =~ m/^WHEN/){       
          ($a,$k)=case_when_statement($a,\@pre_when,\@post_when,\@lines);  
        }	  
        elsif ($lines[$a] =~ m/^IF|^FOR/){      	      
          $k=if_for_statement($k,$lines[$a]);
        }		
        elsif($lines[$a] =~ m/^ELSIF|^ELSE/){ 
          else_elsif_statement($k,$lines[$a]);	  
        }	
        elsif ($lines[$a] =~ m/^END\sPROCESS\s*/ && $entity_end eq 1){ 
          $k = $k - 2;	
          space($k); 	
          print OUTPUT $lines[$a],"\n";
          if($lines[$a+1] !~ m/--/){
            space($k); 
            print OUTPUT "--\n";
          }        
        }	
        elsif ($lines[$a] =~ m/^END\sGENERATE\s*/ && $entity_end eq 1){ 
          $k = $k - 2;	
          space($k); 	
          print OUTPUT $lines[$a],"\n";
          if($lines[$a+1] !~ m/--/){
            space($k); 
            print OUTPUT "--\n";
            space($k); 
            print OUTPUT "--\n";
          }
        }
        elsif ($lines[$a] =~ m/^END\sCOMPONENT\s*/ && $entity_end eq 1){
          $k = $k - 2;	
          space($k);  	
          print OUTPUT $lines[$a],"\n";      	
          if ($lines[$a+1] !~ m/--/){
            space($k); 
            print OUTPUT "--\n";
          }
        }
        elsif ($lines[$a] =~ m/^END/ && $entity_end eq 1){ 
          $k = $k - 2;	
          space($k);  	
          print OUTPUT $lines[$a],"\n";      		  
        }    
        elsif ($lines[$a] =~ m/<=/ && $lines[$a] !~ m/;\s*$/){      
          $a=when_else($k,$k,$a,$lines[$a],\@lines);
        }
        elsif ($lines[$a] =~ m/<=/ && $lines[$a] =~ m/;/){
          $a=statement_allign($k,$k,$a,$lines[$a],\@lines);	      
        }	
        else{
          else_statement($k,$a,$lines[$a]);      
        }	  
      }   	
      else{
        if(scalar(@pre_when) gt 0) {
          $m=$a;
          while ($lines[$m] =~ m/^--/){
            $m++;
          }
          if ($lines[$m] =~ m/^when/i){
            $k=pop(@pre_when);push(@pre_when,$k);
          }
        }	  
        space($k);    
        print OUTPUT $lines[$a],"\n";
      }
    }
    
# Funstions....

    sub when_else {
      #local ($k,$a,$second_half,@rahul);
      my ($k) = $_[0];
      my ($start) = $_[1];
      my ($a) = $_[2];
      my ($second_half) = $_[3];
      my (@rahul) = @{ $_[4] };
      chomp($rahul[$a]);  

      my ($i);	        
      space($start);	
      print OUTPUT $second_half,"\n";
      $num= 3+index($second_half,"<=");  
	  
      do{             
        $a++;  	    
        chomp($rahul[$a]);	        
        space($k+$num);
        print OUTPUT $rahul[$a],"\n";
      }while($rahul[$a] !~ m/;/);
      if($rahul[$a+1]!~ m/--/){
        space($k);
        print OUTPUT "--\n";
      }  
      return($a);
    }       

	
    sub if_for_statement {
      #local ($k,$statement);
      my ($k) = $_[0];
      my ($statement) = $_[1];
	  
	  my ($i);
      if ($statement =~ m/IF/ && $statement =~ m/THEN/){
        if ($statement !~ m/IF\s*\(/ && $statement !~ m/\)\s*THEN/){
          $statement =~ s/IF\s*/IF (/;
          $statement =~ s/\s*THEN/) THEN/;
        }
      }     
      space($k);      	  
      $k = $k + 2;
      print OUTPUT $statement,"\n";
      return $k;
    }
	

    sub else_elsif_statement {
      #local ($k,$statement);
      my($k) = $_[0];
      my($statement) = $_[1];
	  
	  my ($i);
      if ($statement !~ m/ELSIF\s*\(/ && $statement !~ m/\)\s*THEN/){
        $statement =~ s/ELSIF\s*/ELSIF (/;
        $statement =~ s/\s*THEN/) THEN/;
      }
      space($k-2);	  
      print OUTPUT $statement,"\n";	  
    }

	
    sub first_begin {
      #local ($k,$statement);
      my ($k) = $_[0];
      my ($statement) = $_[1];
	  my ($i);
      space($k-2);
      print OUTPUT "-------------------------------------------------------------------------------\n";
      space($k-2);  
      print OUTPUT "-- BEGIN\n";
      space($k-2);  
      print OUTPUT "-------------------------------------------------------------------------------\n";
      space($k-2);  
      print OUTPUT $statement,"\n";  
    }

	
    sub entity_component {
      #local ($k,$a,@line);  
      my ($k) = $_[0];
      my ($a) = $_[1];
      my (@line) = @{ $_[2] }; 
      
      my ($i,$max,$m,$r);	  
      chomp($line[$a]);
      if($line[$a-1] !~ m/--/){
        space($k);
        print OUTPUT "--\n";
      }
      space($k);
      print OUTPUT $line[$a],"\n";		  
      $max = 0;
      $m=$a;
      do{        	  
        $m++;	  
        if ($line[$m] !~ m/^--/){
          if($max < index($line[$m],":")){
            $max = index($line[$m],":");
          }			
        }            		
      }while($line[$m+1] !~ m\END\);	  
      
	  $k=$k+2;	  
      
	  while($line[$a+1]!~ m/END/){
        $a++;
        chomp($line[$a]);		
        if ($line[$a] =~ m/PORT\s|GENERIC\s|^\)\;/){
          space($k);
          print OUTPUT $line[$a],"\n";
        }
        else{
          space($k+2);
          if ($line[$a] !~ m/--/){            		  
            print OUTPUT substr($line[$a],0,index($line[$a],":")-1);
			space($max - index($line[$a],":")+1); 
            print OUTPUT substr($line[$a],index($line[$a],":")),"\n";
          }
          else {
            print OUTPUT $line[$a],"\n";
          }
        }		        		
      }    
      return($k,$a);
    }  
  

    sub port_generic_map {
      #local ($k,$a,@rahul);  
      my ($k) = $_[0];
      my ($a) = $_[1];
      my (@rahul) = @{ $_[2] }; 
      my ($i,$max,$r,$m);	  
      chomp($rahul[$a]);  
      space($k);
      print OUTPUT $rahul[$a],"\n";		  
      $max = -1;
      $m=$a;
      do{        	  
        $m++;	  
        if($rahul[$m] !~ m/^--/){
          if($max < index($rahul[$m],"=>")) {
            $max = index($rahul[$m],"=>");
          }			
        }            		
      }while($rahul[$m+1] !~ m/\)\s*\;/);	  	  

      do{
        $a++;
        chomp($rahul[$a]);		
        if ($rahul[$a] =~ m/PORT\s|GENERIC\s|^\)/) {
          space($k);
          print OUTPUT $rahul[$a],"\n";
        }
        else {
          space($k+2);
          if ($rahul[$a] !~ m/--/ && $max ne -1){
            print OUTPUT substr($rahul[$a],0,index($rahul[$a],"=>")-1);
			space($max - index($rahul[$a],"=>")+2);            
            print OUTPUT substr($rahul[$a],index($rahul[$a],"=>")),"\n"; 			
          }          
          else {
            print OUTPUT $rahul[$a],"\n";
          }
        }		        		
      }while($rahul[$a+1]!~ m/\)\;/);
      $a++;
      space($k);
      print OUTPUT $rahul[$a],"\n";
      if ($rahul[$a+1] !~ m/--/) {
        space($k);
        print OUTPUT "--\n";
      }
      return($k,$a);
    }

	
    sub signal_allign {
      #local ($k,$a,@rahul);  
      my ($k) = $_[0];
      my ($a) = $_[1];
      my (@rahul) = @{ $_[2] }; 
      my ($i,$r,$max,$m);	  
      chomp($rahul[$a]);
      $m=$a;
      $max = index($rahul[$m],":");	  
      while ($rahul[$m+1] =~ m/\s*SIGNAL|\s*CONSTANT|\s*VARIABLE/ && $rahul[$m+1] !~ m/--/){        	    
        $m++;  
        if($max < index($rahul[$m],":")){
          $max = index($rahul[$m],":");
        }			    	
      }
      while ($rahul[$a] =~ m/\s*SIGNAL|\s*CONSTANT|\s*VARIABLE/ && $rahul[$a] !~ m/--/){        
        chomp($rahul[$a]);		
        space($k);        		  
        print OUTPUT substr($rahul[$a],0,index($rahul[$a],":")-1);
        #for($r=0;$r<($max - index($rahul[$a],":")+1);$r++) {print OUTPUT " ";}
		space($max - index($rahul[$a],":")+1);
        print OUTPUT substr($rahul[$a],index($rahul[$a]," : ")),"\n";
        $a++;
      }     
      $a--;  		
      return($k,$a);
    }
 
    sub statement_allign {
      #local ($k,$kfirst,$a,$rohan,@rahul);    
      my ($k) = $_[0];
      my ($kfirst) = $_[1];
      my ($a) = $_[2];
      my ($rohan) = $_[3];
      my (@rahul) = @{ $_[4] }; 
      my ($i,$m,$r,$max);	  
      $m=$a;
      $max = index($rohan,"<=");
    
      while($rahul[$m+1] =~ m/<=/ && $rahul[$m+1] =~ m/;/  && $rahul[$m+1] !~ m/WHEN|IF|ELSE|ELSIF|FOR|CASE|END/){        	  
        $m++;	  
        if ($rahul[$m] !~ m/^--/){
          if ($max < index($rahul[$m],"<=")){
            $max = index($rahul[$m],"<=");
          }			
        }          
      }
      #for($i=0;$i<$kfirst;$i++){print OUTPUT " ";}
	  space($kfirst);
      print OUTPUT substr($rohan,0,index($rohan,"<=")-1);
      #for($r=0;$r<($max - index($rohan,"<=")+1);$r++) {print OUTPUT " ";}
	  space($max - index($rohan,"<=")+1);
      print OUTPUT substr($rohan,index($rohan,"<=")),"\n";
  
      while($rahul[$a+1] =~ m/<=/ && $rahul[$a+1] =~ m/;/   && $rahul[$a+1] !~ m/WHEN|IF|ELSE|ELSIF|FOR|CASE|END/){    
        $a++;	  
        chomp($rahul[$a]);		
        space($k); 
        print OUTPUT substr($rahul[$a],0,index($rahul[$a],"<=")-1);
        #for($r=0;$r<($max - index($rahul[$a],"<=")+1);$r++) {print OUTPUT " ";}
		space($max - index($rahul[$a],"<=")+1); 
        print OUTPUT substr($rahul[$a],index($rahul[$a],"<=")),"\n";                  		
      }
      return($a);
    }  
  
    sub case_when {
      #local ($k,$a,$line,@pre_when,@post_when,@rahul);  
      my ($k) = $_[0];
      my ($a) = $_[1];
      my ($line) = $_[2];
      my (@pre_when) = @{ $_[3] };
      my (@post_when) = @{ $_[4] };
      my (@rahul) = @{ $_[5] };    
	  my ($i,$m,$mult_case,$max);
      space($k);      	  
      print OUTPUT $line,"\n";
      $k = $k + 2;
      $m=$a;
      $max = 0;	  
      $mult_case = 1;    
      while ($mult_case ne 0){	       
        $m++;   
        while($rahul[$m] !~ m/\s*END\sCASE\s*/){        	  
          chomp($rahul[$m]);	
          if($rahul[$m] !~ m/^--/){
            if($rahul[$m] =~ m/^CASE/){
              $mult_case++;
            }			  
            if ($mult_case eq 1 && $rahul[$m] =~ m/^WHEN/ && $rahul[$m] =~ m/=>/ && $max < index($rahul[$m],"=>")){
              $max = index($rahul[$m],"=>");
            }        		
          }
          $m++;          
        }
        $mult_case--;		
      }    
      push(@pre_when,$k);
      push(@post_when,$k+$max);  
      return(\@pre_when,\@post_when);
    }  

    sub case_when_statement {
      #local ($a,@pre_when,@post_when,@rahul);  
      my ($a) = $_[0];
      my (@pre_when) = @{ $_[1] };
      my (@post_when) = @{ $_[2] };
      my (@rahul) = @{ $_[3] };  
      my ($second_half,$k,$r,$when,$afterwhen);	  
      $when = pop(@pre_when);
      push(@pre_when,$when);
      $afterwhen = pop(@post_when);
      push(@post_when,$afterwhen);  
      space($when);      	  
      chomp($rahul[$a]);
      print OUTPUT substr($rahul[$a],0,index($rahul[$a],"=>")-1);
  
      #for($r=0;$r<($afterwhen - index($rahul[$a],"=>")+1-$when);$r++) {print OUTPUT " ";}
	  space($afterwhen - index($rahul[$a],"=>")+1-$when);
      print OUTPUT "=> ";  
      $second_half = substr($rahul[$a],index($rahul[$a],"=>")+2);
      $second_half =~ s/\s*(\S)/$1/;
  
      if ($second_half =~ m/^IF|^FOR/){
        $k=if_for_statement(0,$second_half);$k=$afterwhen+5;
      }  
      elsif ($second_half =~ m/^CASE/){
        (@pre_when,@post_when)=case_when($afterwhen+3,$a,\@pre_when,\@post_when,\@rahul);
      }
      elsif ($second_half =~ m/\s*<\s*=\s*/ && $rahul[$a] =~ m/;/){
        $a=statement_allign($afterwhen+3,0,$a,$second_half,\@rahul);$k=$afterwhen+3;
      }
      elsif ($rahul[$a] =~ m/<=/ && $rahul[$a] !~ m/;\s*$/){
        $k = $afterwhen + 3;$a=when_else($afterwhen+3,0,$a,$second_half,\@rahul);
      }
      else{
        else_statement(0,$a,$second_half);$k = $afterwhen + 3;
      }  
      return($a,$k);
    }
	
    sub space {
      my ($margin) = $_[0];
      for ($i = 0;$i<$margin;$i++){ 	  
        print OUTPUT " ";
      }
    }	  

    sub end_case {      
      my ($rahul) = $_[0];
      my @pre_when = @{ $_[1] };
      my @post_when = @{ $_[2] };
	  my ($k,$i,$dummy);
      $k = pop(@pre_when) - 2;
      space($k);
      print OUTPUT $rahul,"\n";
      $dummy = pop(@post_when);  
      return($k,\@pre_when,\@post_when);  
    }
  
    sub else_statement {
      my($k) = $_[0];
      my($a) = $_[1];
      my($rahul) = $_[2]; 
      my ($i);	  
      space($k);	
      print OUTPUT $rahul,"\n";
    }    

    close OUTPUT;
	
	#==============================================================================
    # Adding comments
    #==============================================================================


    open INPUT, "<test8.vhd";
    open OUTPUT, ">new_files/$in_file";
    @lines = <INPUT>; 
    close INPUT; 
    $count = @lines;
    $signal=0;
    $constant=0;
    $component=0;
    $entity_start=1;
    $first_noncomment = 0;

    for ($i=0;$i<$count;$i++){  
      chomp($lines[$i]);
      $lines[$i] =~ s/(\S*)\s*\;\s*$/$1;/;  
      $lines[$i] =~ s/(\S*)\s*$/$1/;  
      if ($lines[$i] !~ m/^\s*--/ && $lines[$i] !~ m/^\s*$/){   
        if ($lines[$i] =~ m/^ENTITY/ && $entity_start eq 0){
          print OUTPUT "-------------------------------------------------------------------------------\n";
          print OUTPUT "--\n";
          print OUTPUT "-- ENTITY       : ",$entity_name,"\n";	  
          print OUTPUT "-------------------------------------------------------------------------------\n";
          print OUTPUT "--\n";
          $entity_start = 1;       
        }	
        elsif ($lines[$i] =~ m/^END\sENTITY/){
          print OUTPUT $lines[$i],"\n";	
          while ($lines[$i] !~ m/^ARCHITECTURE/){
            $i++;	
            chomp($lines[$i]);
          }	    	  
          print OUTPUT "-------------------------------------------------------------------------------\n";
          print OUTPUT "--\n";
          print OUTPUT "-- ENTITY       : ",$entity_name,"\n";
          print OUTPUT "-- ARCHITECTURE : ",$arch_name,"\n";
          print OUTPUT "-------------------------------------------------------------------------------\n";
          print OUTPUT "--\n";	  	  
        }
        elsif ($lines[$i] =~ m/^END ARCHITECTURE/){
          print OUTPUT $lines[$i],"\n";		  
          print OUTPUT "-------------------------------------------------------------------------------\n";	  
          $i = $count;
        }
        elsif ($lines[$i] =~ m/^\s*SIGNAL\s+/ && $signal eq 0){
          print OUTPUT "  -- Signal Declarations.\n";
          print OUTPUT "  -----------------------------------------------------------------------------\n";	  
          $signal = 1;	  
        }
        elsif ($lines[$i] =~ m/^\s*CONSTANT\s+/ && $constant eq 0){
          print OUTPUT "  -- Constant Declarations.\n";
          print OUTPUT "  -----------------------------------------------------------------------------\n";	  
          $constant = 1;	  
        }
        elsif ($lines[$i] =~ m/^\s*COMPONENT\s+/ && $component eq 0){
          print OUTPUT "  -- Component Declarations.\n";
          print OUTPUT "  -----------------------------------------------------------------------------\n";	  
          $component = 1;	  
        }	      	
        elsif ($first_noncomment eq 0){
          $entity_start = 0;$first_noncomment=1;
          print OUTPUT "-- Library Declarations.\n";
          print OUTPUT "-- ===========================================================================\n";
        }
        print OUTPUT $lines[$i],"\n";
      }  
      elsif ($lines[$i] =~ m/^\s*--/){
        if ($entity_start eq 0){ 
          $m=$i; 
          while ($lines[$m+1] =~ m/^--/){
            $m++;
          }
          if ($lines[$m+1] =~ m/^\s*ENTITY/){
            print OUTPUT "-------------------------------------------------------------------------------\n";
            print OUTPUT "--\n";
            print OUTPUT "-- ENTITY       : ",$entity_name,"\n";	  
            print OUTPUT "-------------------------------------------------------------------------------\n";
            print OUTPUT "--\n";
            $entity_start = 1;
            $i=$m;		
          }
          else{
            print OUTPUT $lines[$i],"\n";}
        }
        elsif ($signal eq 0){
          $m=$i; 
          while ($lines[$m+1] =~ m/^--/){
            $m++;
          }	
          if ($lines[$m+1] =~ m/^\s*SIGNAL\s+/){
            print OUTPUT "  -- Signal Declarations.\n";
            print OUTPUT "  -----------------------------------------------------------------------------\n";				
            $signal = 1;	  
            for ($j=$i;$j<$m;$j++){ 
              chomp($lines[$j]);
              print OUTPUT $lines[$j],"\n";
            } 
            $i = $m;
          }
          else{
            print OUTPUT $lines[$i],"\n";
          }	  
        }
        elsif ($component eq 0){
          $m=$i; 
          while ($lines[$m+1] =~ m/^--/){
            $m++;
          }	
          if ($lines[$m+1] =~ m/^\s*COMPONENT\s+/){
            print OUTPUT "  -- Component Declarations.\n";
            print OUTPUT "  -----------------------------------------------------------------------------\n";		
            $component = 1;	  
            for($j=$i;$j<$m;$j++){ 
              chomp($lines[$j]);
              print OUTPUT $lines[$j],"\n";
            } 
            $i = $m;
          }
          else{
            print OUTPUT $lines[$i],"\n";
          }	  
        }	
        else{
          print OUTPUT $lines[$i],"\n";
        }
      }
    }
    unlink("test1.vhd");
    unlink("test2.vhd");
    unlink("test3.vhd");
    unlink("test4.vhd");
    unlink("test5.vhd");
    unlink("test6.vhd");
    unlink("test7.vhd");
    unlink("test8.vhd");
    close OUTPUT;	
  } 
}  
  
  
  
