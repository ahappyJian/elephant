#! /usr/bin/perl -w

# Date: 2014-05-22

use strict;
use File::Basename;

BEGIN {
	unshift(@INC, (dirname($0)."/../lib64/perl5/site_perl/5.14/"));
	unshift(@INC, (dirname($0)."/../lib/perl5/site_perl/5.14/"));
	unshift(@INC, dirname($0));
}

use Getopt::Long;
use Date::Calc qw(Add_Delta_DHMS);

use LauncherUtils qw(cur_time checkConfigs ExecCmd);


main();
exit(0);

#--------------
# main
#--------------
sub main{
	# init 
	my $ret = getConfigs();
	if($ret != 0){
		die "JOB FAILED\n"
		."FATAL ERROR: bad configs of yinst root, grid data path or others configs\n"
		."Please check the yinst settings\n";
	}

	my ($second, $minute, $hour, $day, $month, $year) = localtime(time());
	$job_log = sprintf("$log_path/monitor_$prod-"."%04d_%02d_%02d.log", $year + 1900, $month + 1, $day);
	$report_log = "$log_path/$prod.report";

	while(1){
        my $timestamp = $base_timestamp;
		$timestamp =~ s/^(\d{8}).*$/$1/;
	}
	info("\n=====$0 done=====");
}

#------------------------------------------------------------
# sub functions
#------------------------------------------------------------
sub usage() {

	my $usage = <<END_OF_USAGE;
Usage:
	$0 [--option value]+

Options:
	--report_mail [email-address] 
		This is optional.
		the email address where the report mails will be send to

	--subject [mail-subject-string]
		This is optinal.
		This string will be added to the alert mail subject

	--debug
		This is optional.
		enable this can output the log to stdout, otherwise all the log will be output to log file

END_OF_USAGE
	print "$usage";
}

sub getConfigs{
	GetOptions(
		"report_mail=s" => \$report_email_address,
		"subject=s" => \$email_subject,
		"debug" => \$debug,
	) ;
	return checkConfigs($yinst_root, $monitor_data_hdfs_path, $monitor_start_time, $monitor_data_freq, $report_email_address);
}

sub info{
	if($debug == 1 ){
		print "@_\n";
		return ;
	}
	system "echo '@_' >> $job_log";
}
