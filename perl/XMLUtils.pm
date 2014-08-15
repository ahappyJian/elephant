package XMLUtils;

# Date: 2013-12-18
#
# Usage:
#

use strict;
use XML::Simple;

use Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(readXML writeXML getRoot getChildren getChild getNodeText getChildText removeChildren removeChild addChild addChildAndText );

# this key will not be used by user, chose an rare one 
our $content_key = 'NeverUsedKey_XoNU9yOqFW';

sub readXML{
    my $file = $_[0];
    my $info = XML::Simple->new()->XMLin(
        $file, 
        ForceArray=>1, 
        KeyAttr=>'', 
        KeepRoot=>1, 
        ContentKey=>"$content_key"
        );
    return $info;
}

sub writeXML{
    my ($info, $file) = @_;
    XML::Simple->new()->XMLout(
        $info, 
        OutputFile=>"$file", 
        KeepRoot=>1,
        KeyAttr=>'',
        NoSort=>1,
        ContentKey=>"$content_key"
    );
    return 0;
}

sub getRoot{
    my ($info) = @_;
    my @keys = keys %{$info};
    if(@keys == 0){ return undef; }
    my $root = $info->{$keys[0]};
    if(@{$root} == 0 ){ return undef; }
    return ${$root}[0]; 
}

sub getChildren{
    my ($node, $tag) = @_;
    my $children = undef;
    if( exists $node->{$tag} ){
        $children = $node->{$tag};
    }
    return $children;
}

sub getChild{
    my ($node, $tag) = @_;
    my $children = getChildren($node, $tag);
    if(! defined $children){ return undef; }
    if( @{$children} == 0){ return undef; }
    return ${$children}[0];
}

sub getNodeText{
    my ($node) = @_;
    if(ref($node) eq ''){ return $node; }
    if(ref($node) ne 'HASH'){ return undef; }
    if( exists $node->{$content_key} ){
        return $node->{$content_key};
    }
    return undef;
}

sub getChildText{
    my ($node, $tag) = @_;
    my $child = getChild($node, $tag);
    if(! defined $child ){ return undef; }
    return getNodeText($child);
}

sub removeChildren{
    my ($node, $tag) = @_;
    if( exists $node->{$tag} ){
        delete $node->{$tag};
    }
}

sub removeChild{
    my ($node, $tag, $content) = @_;
    my $children = getChildren($node, $tag);
    if(!defined $children){ return; }
    for(my $i = 0; $i < @{$children}; $i++){
        my $text = getNodeText(${$children}[$i]);
        if(!defined $text){ next; }
        if( $text eq $content){
            splice(@{$children}, $i, 1);
            last;
        }
    }
}

sub addChild{
    my ($node, $tag) = @_;
    if( !exists $node->{$tag} ){
        $node->{$tag} = [];
    }
    my $nodes = $node->{$tag};
    push@{$nodes}, {};
    my $size = @{$nodes};
    return ${$nodes}[$size - 1];
}

sub addChildAndText{
    my ($node, $tag, $text) = @_;
    my $children = getChildren($node, $tag);
    if( !defined $children ){
        $node->{$tag} = [$text];
    }else{
        push@{$children}, $text;
    }
}





1;
