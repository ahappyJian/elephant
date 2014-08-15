#!/home/y/bin64/perl 

use strict;
use warnings;

BEGIN {
	*CORE::GLOBAL::readpipe = \&mock_readpipe
};

use Test::More;
use Test::MockModule;
use Test::Exception;
use Data::Dumper;
use XML::Simple;

my $module = Test::MockModule->new('MupUtils');
my $xml_module = Test::MockModule->new('XML::Simple');

my $mock_readpipe_case = 0;
sub mock_readpipe{
	return "<certificate>123</certificate>200" if ($mock_readpipe_case == 0);
	return "wrong" if ($mock_readpipe_case == 1);
	return 0;
}

# begin testing
plan tests=>8;
t_info();
t_warnInfo();
t_getElement();
t_checkConfigs();
t_ExecCmd();
t_ExecCmdDieOnError();
t_ExecCmdWithRet();
# end testing

sub t_getElement{
	my $test_name = "test for getElement";
	my %nums = (
		'first' => 1,
		'second' => 2
	);
	is(getElement(\%nums, 'first'), 1, $test_name." valid value");
dies_ok{ getElement(\%nums, 'third') } "$test_name no element case";
}

sub t_checkConfigs{
	my $test_name = "test for checkConfigs";
	my ($c1, $c2, $c3, $c4) = (1, 2, 3, 4);
	my $null_c;
	my $empty_c = "";
	is(checkConfigs($c1, $c2, $c3, $c4), 0, $test_name." all config not null");
	is(checkConfigs($c1, $null_c, $c3, $c4), 1, $test_name." some config null");
	is(checkConfigs($c1, $c2, $empty_c, $c4), 0, $test_name." some config empty string");
}

sub t_ExecCmd{
	my $test_name = "test for ExecCmd";
	is(ExecCmd("echo \"hello world\""), 0, $test_name." run command");
}

sub t_ExecCmdDieOnError{
	my $test_name = "test for ExecCmdDieOnError";
	ExecCmdDieOnError("echo \"hello world\"");
}

sub t_ExecCmdWithRet{
	my $test_name = "test for ExecCmdWithRet";
	ExecCmdWithRet("echo \"hello world\"");
}
sub t_updateModel{
	$module->mock( 'getFileFromMob' => sub {} );
	$xml_module->mock( 'XMLin' => sub {} );
	$module->mock( 'getElement' => sub { return {} } );
	updateModel('test_model');
}
