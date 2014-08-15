#!/usr/bin/perl -w 

my $debug_info_prefix	= "[DEBUG]";
my $info_info_prefix	= "[INFO ]";
my $error_info_prefix	= "[ERROR]";
my $warning_info_prefix = "[WARN ]";

#base func 
sub _zj_print{ print "@_\n"; }

#debug func
my $debug_flag = 0;
sub Endebug{ $debug_flag = 1; }
sub Disdebug{ $debug_flag = 0; }
sub De{ $debug_flag == 0 or &_zj_print($debug_info_prefix,@_); }

#info func
my $mute = 0;
sub Enmute{ $mute = 1; }
sub Dismute{ $mute = 0; }
sub Info{ $mute == 1 or &_zj_print($info_info_prefix, @_); }
sub Die{ die("@_\n"); }

#error func
sub Warn{ &_zj_print($warning_info_prefix, @_); }
sub Err{ &_zj_print($error_info_prefix,@_); }

#return true
1;
