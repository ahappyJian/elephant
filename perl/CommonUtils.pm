package LauncherUtils;
use strict;

use File::Basename;
BEGIN {
	unshift(@INC, (dirname($0)."/../lib/perl5/site_perl/"));
	unshift(@INC, (dirname($0)."/../lib64/perl5/site_perl/5.14/"));
	unshift(@INC, (dirname($0)."/../lib64/perl5/site_perl/"));
	unshift(@INC, dirname($0));
} 

use POSIX qw(strftime);
use Log::Log4perl qw(:easy);

use Exporter;
our (@ISA, @EXPORT, $VERSION);
@ISA = qw(Exporter);
$VERSION = 0.1;
@EXPORT = qw(initLogger ExecCmd ExecCmdReturnText curTimestamp checkConfigs info error copyFilesToHDFS cur_time);

sub initLogger{
    my($logDir,$logPrefix) = @_; 
    if (! -e $logDir){
       system("mkdir $logDir");
    }   
    if(not(defined $logPrefix)){
        $logPrefix=""; 
    }   
    my ($second, $minute, $hour, $day, $month, $year) = localtime(time());
    my $logfile=sprintf("$logDir/$logPrefix"."%04d_%02d_%02d.log", $year + 1900, $month + 1, $day);
    
    my $conf=qq{
                log4perl.rootlogger=DEBUG, Screen, LOGFILE
                log4perl.appender.Screen=Log::Log4perl::Appender::Screen
                log4perl.appender.Screen.stderr=0
                log4perl.appender.Screen.layout=PatternLayout
                log4perl.appender.Screen.layout.ConversionPattern=%-5p %c %d - %m%n
                log4perl.appender.LOGFILE=Log::Log4perl::Appender::File
                log4perl.appender.LOGFILE.filename=$logfile
                log4perl.appender.LOGFILE.mode=append
                log4perl.appender.LOGFILE.layout=PatternLayout
                log4perl.appender.LOGFILE.layout.ConversionPattern=%-5p %c %d - %m%n
        };


    Log::Log4perl->init(\$conf);
    my $logger = get_logger();
    return $logger 
}

sub ExecCmdAndLog{
	my ($cmd) = @_;
	my $logger = get_logger();
	$logger->info("CMD: $cmd");
	my @ret =`$cmd 2>&1`;
	my $code = $?;
	my $ret = join("\n", @ret);
	if($ret ne ''){
		$logger->info("$ret");
	}
	return $code>>8;
}


sub ExecCmd{
	my ($cmd) = @_;
	print "CMD: $cmd\n";
	$cmd = "$cmd 2>&1";
	return system($cmd);
}

sub ExecCmdReturnText{
	my ($cmd) = @_;
	print "ReturnTextCMD: $cmd\n";
	return `$cmd`;
}
sub curTimestamp{
	my $tmp = $ENV{TZ};
	$ENV{TZ} = 'UTC';
	my $cur = time();
	$ENV{TZ} = $tmp;
	return $cur;
}
sub cur_time{
    my ($second, $minute, $hour, $day, $month, $year) = localtime(time());
	my $time=sprintf("%04d%02d%02d%02d%02d", $year + 1900, $month + 1, $day, $hour, $minute);
	return $time;
}
sub checkConfigs{
	foreach(@_){
		if(!defined $_){ 
			return 1; 
		}
	}   
	return 0;
}
sub info{
	print "@_\n";
}
sub error{
	print STDERR "@_\n";
}
sub copyFilesToHDFS{
	my ($files, $force) = @_;
	my %exist_path = ();
	defined $files and defined $force or die "please input the valid paremeters for copyFilesToHDFS()";
	foreach(keys %{$files}) {
		if($force == 0){
			if( ExecCmd("hadoop fs -test -e $files->{$_}") == 0){
				info("$_ is exsting on hdfs, will be ignored");
				next; 
			}
		}
		my $path = $files->{$_};
		if(! exists $exist_path{$path}){
			ExecCmd("hadoop fs -mkdir -p $path");
			$exist_path{$path} = 1;
		}
		if( ExecCmd("hadoop fs -put -f $_ $path") != 0){
			info("put $_ Failed");
			return 1;
		}
	}
	return 0;
}

1;
