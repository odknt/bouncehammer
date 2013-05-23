# $Id: YAML.pm,v 1.13.2.1 2013/04/15 04:20:53 ak Exp $
# -Id: Serialized.pm,v 1.8 2009/12/31 16:30:13 ak Exp -
# -Id: Serialized.pm,v 1.2 2009/10/06 09:11:18 ak Exp -
# -Id: Serialized.pm,v 1.12 2009/07/16 09:05:42 ak Exp -
# Copyright (C) 2009,2010,2013 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Stored
                             
 ##  ##  ##   ##  ## ##      
 ##  ## ####  ###### ##      
  #### ##  ## ###### ##      
   ##  ###### ##  ## ##      
   ##  ##  ## ##  ## ##      
   ##  ##  ## ##  ## ######  
package Kanadzuchi::Mail::Stored::YAML;
use base 'Kanadzuchi::Mail::Stored';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub load
{
	#+-+-+-+-+
	#|l|o|a|d|
	#+-+-+-+-+
	#
	# @Description	Serialized data(YAML|JSON) -> Hash reference
	# @Param <ref>	(Ref->String|File) Serialized data(YAML|JSON)
	# @Return	(Ref->Array) Array-ref of Hash references
	my $class = shift;
	my $sdata = shift || return [];
	my $jsons = undef;	# JSON::Syck object(array)
	my $strct = [];

	eval { $jsons = Kanadzuchi::Metadata->to_object( $sdata ); };
	return [] if $@;
	return [] if ref($jsons) ne 'ARRAY';

	my $structures = [];
	my $eachrecord = {};
	my $descrfield = {};
	my $accessords = [qw(deliverystatus diagnosticcode timezoneoffset)];
	my $accessorss = [qw(
		addresser recipient senderdomain token diagnosticcode bounced
		frequency destination description hostgroup provider reason
	)];

	TO_STRUCTURE: foreach my $j ( @$jsons )
	{
		$eachrecord = { map { $_ => $j->{ $_ } || q() } @$accessorss };
		$descrfield = $j->{'description'};
		map { $eachrecord->{ $_ } => $descrfield->{ $_ } || q() } @$accessords;
		$eachrecord->{'diagnosticcode'} ||= $descrfield->{'diagnosticcode'};
		push @$structures, $eachrecord;
	}
	return $structures;
}

sub loadandnew
{
	#+-+-+-+-+-+-+-+-+-+-+
	#|l|o|a|d|a|n|d|n|e|w|
	#+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	new() by serialized data
	# @Param <str>	(String) Serialized data(YAML|JSON)
	# @Return	(Ref->Array) Kanadzuchi::Mail::Stored::YAML
	my $class = shift;
	my $sdata = shift || return [];

	my $structures = $class->load( $sdata );
	my $newobjects = [];

	map { push @$newobjects, __PACKAGE__->new(%$_) } @$structures;
	return Kanadzuchi::Iterator->new( $newobjects );
}

1;
__END__
