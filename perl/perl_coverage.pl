#!/home/y/bin64/perl 

use TAP::Parser qw/all/;
use TAP::Parser::Aggregator qw/all/;


### Main function
sub main($) {
    print "-------------------------------------------------------\n";
    print "PERL UNIT TEST\n";
    print "-------------------------------------------------------\n";
    return runUT();

}

############################# Entry point
my $ret = main(\@ARGV);

exit ($ret);

############################# Functions

sub runUT($$) {
	my @ut_files = `ls ./t/*.t`;

	`rm -rf ./t/*.tr`;
	my $ut_file;
	my $ut_file_basename;
	my $ut_res;
	my $has_fail_ut = 0;

	if(scalar (@ut_files) >0){
		foreach (<@ut_files>){		
			$ut_file = $_;
			if( (-e $ut_file) && (-x $ut_file)){
				$ut_file_basename = `basename $ut_file`;
				chomp($ut_file_basename);
				$ut_res = "./t/".getResultFileName($ut_file_basename);
				#`perl $ut_file > $ut_res`;		
				
				# if the result file exists, delete it first
				if( -e $ut_res ){
					unlink($ut_res);
				}
				print "#----- Start Processing UT file '$ut_file' ---\n";
				open(RESULTFILE,">$ut_res") or die "Can't Open Unit Test Result File: $ut_res\n";
				
				my $parser = TAP::Parser->new( { source => $ut_file } );
				while( my $result = $parser->next ){
					my $mystring = $result->as_string;
					print "$mystring\n";
					print RESULTFILE "$mystring\n";
				}
			
				my $aggregate = TAP::Parser::Aggregator->new;
				$aggregate->add('testcases',$parser);
				printf "\n#\tPassed: %s\n#\tFailed: %s\n", scalar($aggregate->passed),scalar($aggregate->failed);
				print "#----- Finish Processing UT file '$ut_file' ---\n";
				if(scalar($aggregate->failed) > 0){
					$has_fail_ut = 1;
				}
			}
		}
	}
	my $output = `perl Makefile.PL`;
	print "$output\n";
	$output = `cover -delete`;
	print "$output\n";
	$output = `cover -test`;
	print "$output\n";
	`rm -rf clover-reports`;
	`cover2clover.pl`;

	mergeClover();

	if($has_fail_ut == 1){
		return -1;
	}
    return 0;
}

sub mergeClover{

	my $javaClover = '../target/site/clover/clover.xml';
	my $perlClover = 'clover-reports/cover_db/clover.xml';
	my $output;
	my $params = "";
	if( -e $javaClover){
		$output = `cp -r ../target/site/clover clover-reports/java_clover`;
		$javaClover = 'clover-reports/java_clover/clover.xml';
		if( -e $javaClover ){
			$params .= " --clover-xml $javaClover";
		}
	}
	if( -e $perlClover){
		$cmd="mv clover-reports/cover_db  clover-reports/perl_clover";
		$result=system($cmd);
		if($result==0)
		{
			$params .= " --clover-xml  \"clover-reports/perl_clover/clover.xml\"";
		}
		else
		{
			exit(1);
		}
	} 

	`rm -rf aggregated-clover`;
	$output = `mergeclover.pl $params`;
	print "$output\n";
}

sub getResultFileName{
	 my  ($filename) = @_;
	 my $delta = ".tr";
	 if($filename =~ m/(.*).t/){
	 	return $1.$delta;
	 }else{
	 	return $filename.$delta;
	 }
}
