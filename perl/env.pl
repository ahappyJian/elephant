#!/home/y/bin/perl -w 

sub info{
print "@_\n";
}
sub execmd{
	info(@_);
return system "@_";
}

info($ARGV[0]);
$ENV{PATH} = "/home/zhujian/workspace/test:$ENV{PATH}";
execmd("curl nihao");
