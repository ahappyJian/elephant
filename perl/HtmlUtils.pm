package SkynetHtmlUtils;

# Date: 2014-04-24

use strict;
use File::Basename;

BEGIN {
	unshift(@INC, (dirname($0)."/../lib64/perl5/site_perl/5.14/"));
	unshift(@INC, (dirname($0)."/../lib/perl5/site_perl/5.14/"));
	unshift(@INC, dirname($0));
}

use Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(set_html_header add_html_body add_html_end get_html_content set_html_table_header add_html_table_record add_html_table_end get_html_table_content);

#------------------------------------------------------------
# html table functions
#------------------------------------------------------------
my ($html_begin, $html_end, $html_header, $html_body);
my ($html_table_header, $html_table_records, $html_table_tail);
my @color = ('#aaaaaa', '#cccccc');
my $record_color = $color[0];

sub set_html_header{
	# init
	$html_begin = "<html><body>";
	$html_header = "";
	$html_body = "";
	$html_end = "</body></html>";

	my ($header) = @_;    
	$html_header = "<h3>$header</h3>";
	return $html_header;
}
sub add_html_body{
	$html_body .= $_[0];
	return $html_body;
}
sub add_html_end{
	$html_end = "</body></html>";
	return $html_end;
}
sub get_html_content{
	return $html_begin
		."\n$html_header"
		."\n$html_body"
		."\n$html_end";
}

#--------------------html table---------------------
sub set_html_table_header{
	my (@heads) = @_;
	$html_table_records = "";
	$html_table_tail = "</table>";
	$html_table_header = "\n<table border=\"0\">\n\t<tr>";
	foreach(@heads){
		$html_table_header .= "\n\t\t<th bgcolor=#99ccff>$_</th>";
	}
	$html_table_header .= "\n\t</tr>";
	return $html_table_header;
}
sub add_html_table_record{
	my (@fields) = @_;
	my $ret = "\n\t<tr>";
	foreach(@fields){
		$ret .= "\n\t\t<td bgcolor=$record_color>$_</td>";
	}
	$ret .= "\n\t</tr>";
	$html_table_records .= $ret; 
	return $html_table_records;
}
sub add_html_table_end{
	$html_table_tail = "</table>";
	return $html_table_tail;
}
sub get_html_table_content{
	return "$html_table_header"
		."\n$html_table_records"
		."\n$html_table_tail";
}


1;
