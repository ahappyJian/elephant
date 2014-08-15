package SkynetMonitorUtils;
use strict;

use File::Basename;

BEGIN {
	unshift(@INC, (dirname($0)."/../lib64/perl5/site_perl/5.14/"));
	unshift(@INC, (dirname($0)."/../lib/perl5/site_perl/5.14/"));
	unshift(@INC, dirname($0));
	unshift(@INC, "$(YINST_ROOT)"."/bin/");
}

use POSIX qw(strftime);
use Date::Calc qw(Add_Delta_DHMS);
use SkynetHtmlUtils;
use SkynetMailUtils;
use LauncherUtils;

use Exporter;
our (@ISA, @EXPORT, $VERSION);
@ISA = qw(Exporter);
$VERSION = 0.1;
@EXPORT = qw(get_report_timestamp test_report_timestamp get_report_records sort_by_column get_report_content send_report add_hour float_format gen_html_table gen_html);


sub get_report_timestamp{
	my ($report_log, $start_time) = @_; 

	my $log_timestamp = get_log_timestamp($report_log);
	my $cur_timestamp = get_cur_timestamp();

	$start_time = format_time_YYYYMMDDHHmm($start_time);
	$log_timestamp = format_time_YYYYMMDDHHmm($log_timestamp);
	$cur_timestamp = format_time_YYYYMMDDHHmm($cur_timestamp);

	my $timestamp = ""; 
	if($log_timestamp eq "000000000000"){
		$timestamp = $start_time eq "000000000000" ? $cur_timestamp : $start_time;
	}else{
		$log_timestamp = add_hour($log_timestamp, 24);
		$timestamp = $log_timestamp;
	}   
	return $timestamp;
}
sub get_log_timestamp{
	my ($report_log) = @_;
	my $log_timestamp = ""; 
	if( -e $report_log ){
		my @content = `cat $report_log`;
		for(my $i = $#content; $i >= 0; $i --){
			if($content[$i] =~ /^(\d+)/){
				$log_timestamp = $1; 
				last;
			}   
		}   
	}
	return $log_timestamp;
}
sub get_cur_timestamp{
	my ($second, $minute, $hour, $day, $month, $year) = localtime(time());
	my $time=sprintf("%04d%02d%02d%02d%02d", $year + 1900, $month + 1, $day, $hour, $minute);
	return $time;
}

sub format_time_YYYYMMDDHHmm{
	# return YYYYMMDDHHmm
	my ($ts) = @_;
	$ts .= "000000000000";
	$ts =~ s/^(\d{12}).*$/$1/g;
	return $ts;
}

sub test_report_timestamp{
	my ($hdfs_path, $feeds, $freq, $timestamp, $cmdprefix) = @_;
	foreach(@$feeds){
		my $path = "$hdfs_path/$_/$freq/data/$timestamp/";
		if(ExecCmd($cmdprefix."hadoop fs -test -e $path") != 0){
			return 1;
		}
	}
	return 0;
}
sub get_report_records{
	my ($hdfs_path, $feeds, $freq, $timestamp, $cmdprefix) = @_;
	my @ret = ();
	foreach my $feed (@$feeds){
		my $path = "$hdfs_path/$feed/$freq/data/$timestamp/";
		my $content = ExecCmdReturnText($cmdprefix."hadoop fs -cat $path/*");
		if($? != 0){ return ; }
		my @content = split("\n", $content);
		@content = map {"$feed\001".$_} @content;
		push@ret, @content;
	}
	return @ret;
}
sub sort_by_column{
	my ($records, $index, $incr, $numerical) = @_;
	my %table = ();
	my @ret = ();
	foreach(@$records){
		my @tmp = split(/\001/, $_, -1);
		my $key = $tmp[$index];
		my $value = $_;
		if(! exists $table{$key}){
			$table{$key} = ();
		}
		push@{$table{$key}}, $value;
	}
	my @keys_sort = ();
	if(lc $incr eq lc"asc"){
        if(lc $numerical eq lc "numerical"){
		    @keys_sort = sort {$a <=> $b} keys %table;
        }else{
		    @keys_sort = sort {$a cmp $b} keys %table;
        }
	}else{
        if(lc $numerical eq lc "numerical"){
		    @keys_sort = sort {$b <=> $a} keys %table;
        }else{
		    @keys_sort = sort {$b cmp $a} keys %table;
        }
	}
	foreach my $key (@keys_sort){
		push@ret, @{$table{$key}};
	}
	return @ret;
}
sub get_report_content{
	my ($title, $all_title, $filter_title, $records, $all_cnt) = @_;
	# get tables 
	my %all = ();
	my @filters = ();
	my $all_boundary = $all_cnt - 1;
	foreach(@$records){
		my @tmp = split("\001", $_, -1);
		my $key = join("\001", @tmp[0..$all_boundary]);
		$all{$key} = 1;
		push@filters, join("\001", @tmp[0, $all_cnt..$#tmp]);
	}
	my @all = keys %all;

	# gen html table 
	my $table_all = gen_html_table($all_title, \@all);
	my $table_filter = gen_html_table($filter_title, \@filters);

	set_html_header($title);
	add_html_body("$table_all\n<br/>\n$table_filter");
	return get_html_content();
}
sub gen_html_table{
	my ($title, $records) = @_;
	set_html_table_header(@$title);
	foreach(@{$records}){
		my @tmp = split(/\001/, $_, -1) ;
		add_html_table_record(@tmp);
	}
	return get_html_table_content();
}

sub gen_html{
    my $title = shift@_;
	set_html_header($title);
    my $content = "";
    foreach(@_){
        if($content eq ""){ $content = $_; }
        else{ $content .= "\n<br/>\n".$_; }
    }
	add_html_body("$content");
	return get_html_content();
}
sub send_report{
	my($timestamp, $email_addr, $email_subject, $html_body, $txt_body, @attachments) = @_;

	#gen report mail 
	my $report_ts = $timestamp;
	$report_ts =~ s/^(\d{8}).*/$1/;
	set_email_title($email_addr, $email_subject);
	add_email_body("text", $txt_body) if ((defined $txt_body) and $txt_body ne "");
	add_email_body("html", $html_body) if ((defined $html_body) and $html_body ne "");
    for(my $i = 1; $i < @attachments; $i+=2){
        add_email_attach($attachments[$i-1], $attachments[$i]);
    }
	my $email_content = get_email_content();

	# send report mail 
	my $temp = "tmp_tp_skynet_report_99767B9337A4";
	open FILE, ">$temp" or die "open tmp file:$temp failed:$?\n";
	print FILE $email_content;
	close FILE;

	ExecCmd("cat $temp | sendmail -i -t ");
	ExecCmd("rm -f $temp");
	return 0;
}
sub add_hour{
	my ($time, $value) = @_;
	$time =~ /^(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})/;
	my ($year, $month, $day, $hour, $minute) = ($1, $2, $3, $4, $5);
	# todo
	($year, $month, $day, $hour, $minute) = Add_Delta_DHMS($year, $month, $day, $hour, $minute, 0,
		0, $value, 0, 0);
	return sprintf("%04d%02d%02d%02d%02d", $year, $month, $day, $hour, $minute);
}
sub float_format{
    return sprintf("%6.4f", $_[0]);
}


1;
