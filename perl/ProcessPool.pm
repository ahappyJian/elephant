#!/usr/bin/perl
package ProcessPool;
require Exporter;
use strict;
use warnings;
use POSIX ":sys_wait_h";

use vars qw(@ISA @EXPORT $VERSION);
@ISA = qw(Exporter);
@EXPORT = qw(processpool_set_cnt processpool_waitforall processpool_run_task);
$VERSION = 0.1;

my $process_cnt = 10;
my $current_cnt = 0;
sub processpool_set_cnt{
	if( @_ > 0 ){
		$process_cnt = int($_[0]);
		$process_cnt = $process_cnt == 0 ? 10 : $process_cnt;
		print "set ok : process count: $process_cnt\n";
	}
}
sub processpool_waitforall{
	while($current_cnt > 0){
		my $code = waitpid(-1, WNOHANG);
		if( $code > 0){ 
			$current_cnt --; 
		}elsif( $code == -1 ){
			$current_cnt = 0;
		}else{
			sleep(3);
		}
	}
	print "JOBs all DONE\n";
}
sub processpool_run_task{
	my $func = shift@_;
	my @params = @_;
	while($current_cnt >= $process_cnt){
		my $code = waitpid(-1, WNOHANG);
		if( $code > 0 ){
			$current_cnt --;
		}elsif( $code == -1 ){
			print "process count ERROR\n";
			$current_cnt = 0;
		}elsif( $code == 0 ){
			sleep(3);
		}
	}
	#do job 
	my $pid = fork;
	if( ! defined($pid) ){ 
		print "Process create FAILED: $func @params\n"; 
		return 1;
	}
	if( $pid == 0 ){
		#child process 
		my $res = &{$func}(@params);
		exit $res;
	}
	$current_cnt++;
	return 0;
}
### tail
1;
