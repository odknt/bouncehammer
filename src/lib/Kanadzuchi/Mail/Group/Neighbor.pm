# $Id: Neighbor.pm,v 1.6.2.1 2013/04/15 04:20:53 ak Exp $
# Copyright (C) 2009-2010,2013 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Group::
                                                          
 ##  ##           ##         ##     ##                    
 ### ##   ####         ##### ##     ##      ####  #####   
 ######  ##  ##  ###  ##  ## #####  #####  ##  ## ##  ##  
 ## ###  ######   ##  ##  ## ##  ## ##  ## ##  ## ##      
 ##  ##  ##       ##   ##### ##  ## ##  ## ##  ## ##      
 ##  ##   ####   ####     ## ##  ## #####   ####  ##      
                      #####                               
package Kanadzuchi::Mail::Group::Neighbor;
use base 'Kanadzuchi::Mail::Group';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
my $Neighbors = '__KANADZUCHIROOT__/etc/neighbor-domains';
my $OurDomain = ( -r $Neighbors && -s _ && -T _ ) ? JSON::Syck::LoadFile($Neighbors) : {};

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub reperit 
{
	# +-+-+-+-+-+-+-+
	# |r|e|p|e|r|i|t|
	# +-+-+-+-+-+-+-+
	#
	# @Description	Detect and load the class for the domain
	# @Param <str>	(String) Domain part
	# @Return	(Ref->Hash) Class, Group, Provider name or Empty string
	my $class = shift;
	my $dpart = shift || return {};
	my $mdata = { 'class' => q(), 'group' => q(), 'provider' => q(), };

	foreach my $d ( keys %$OurDomain )
	{
		next unless grep { $dpart eq $_ } @{ $OurDomain->{$d} };

		$mdata->{'class'} = q|Kanadzuchi::Mail::Bounced::Generic|;
		$mdata->{'group'} = 'neighbor';
		$mdata->{'provider'} = $d;
		last;
	}

	return $mdata;
}

1;
__END__
