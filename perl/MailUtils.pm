package SkynetMailUtils;
use strict;

# Date: 2014-04-24

use File::Basename;

BEGIN {
	unshift(@INC, (dirname($0)."/../lib64/perl5/site_perl/5.14/"));
	unshift(@INC, (dirname($0)."/../lib/perl5/site_perl/5.14/"));
	unshift(@INC, dirname($0));
}

use Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(set_email_title add_email_body add_email_attach get_email_content);
#------------------------------------------------------------
# sendmail utils functions
#------------------------------------------------------------
my $email_title = "";
my $email_boundary = "";
my $email_body_boundary = "";
my $email_body = "";
my $email_attach = "";

sub set_email_title{
	# init mail parameters
	$email_title = "";
	$email_boundary = "556BB169-D157-4B69-A7F0-99767B9337A4";
	$email_body_boundary = "91870D18-E3EF-4BD7-A2ED-03ECCCB7D9F5";
	$email_body = "";
	$email_attach = "";
	# end init 

	my ($to_mail, $subject) = @_;
	$email_title = <<END_OF_STRING;
To: $to_mail
Subject: $subject
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="$email_boundary"
END_OF_STRING
}

sub add_email_body{
	my ($type, $content) = @_;
	if($email_body eq ""){
		$email_body = "\n--$email_boundary"
		."\nContent-Type: multipart/alternative; boundary=\"$email_body_boundary\"";
	}
	if($type eq "html"){
		$email_body .= 
		"\n\n--$email_body_boundary"
		."\nContent-Type: text/html; charset=utf-8"
		."\nContent-Disposition: inline"
		."\n\n$content"
		;
	}else{
		$email_body .= 
		"\n\n--$email_body_boundary"
		."\nContent-Type: text/plain; charset=utf-8"
		."\nContent-Disposition: inline"
		."\n\n$content"
		;
	}
}

sub add_email_attach{
	my ($file_name, $content) = @_;
	my $encode_content = `echo '$content' | uuencode $file_name`;
	$email_attach .= 
	"\n\n--$email_boundary"
	."\nContent-Type: text/html; name=\"$file_name\""
	."\nContent-Transfer-Encoding: uuencode"
	."\nContent-Disposition: attachment; filename=\"$file_name\""
	."\n\n$encode_content"
	;
}

sub get_email_content{
	return $email_title
	.$email_body
	."\n--$email_body_boundary--"
	.$email_attach
	."\n--$email_boundary--"
	;
}

1;
