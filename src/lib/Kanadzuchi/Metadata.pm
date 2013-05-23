# $Id: Metadata.pm,v 1.15.2.1 2013/04/15 04:20:52 ak Exp $
# Copyright (C) 2009,2010,2013 Cubicroot Co. Ltd.
# Kanadzuchi::
                                                        
 ##  ##          ##             ##          ##          
 ######   #### ###### ####      ##   #### ###### ####   
 ######  ##  ##  ##      ##  #####      ##  ##      ##  
 ##  ##  ######  ##   ##### ##  ##   #####  ##   #####  
 ##  ##  ##      ##  ##  ## ##  ##  ##  ##  ##  ##  ##  
 ##  ##   ####    ### #####  #####   #####   ### #####  
package Kanadzuchi::Metadata;
use strict;
use warnings;
use JSON::Syck;

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
$JSON::Syck::ImplicitTyping  = 1;
$JSON::Syck::Headless        = 1;
$JSON::Syck::ImplicitUnicode = 0;
$JSON::Syck::SingleQuote     = 0;
$JSON::Syck::SortKeys        = 0;

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub to_string
{
	# +-+-+-+-+-+-+-+-+-+
	# |t|o|_|s|t|r|i|n|g|
	# +-+-+-+-+-+-+-+-+-+
	#
	# @Description	Convert from a hash ref to string
	# @Param	(Ref->Hash|Ref->Array) Object
	# @Param	(Integer) 1 = JSON format [ {...} ]
	# @Return	(Ref->Scalar) Serialized data or undef()
	my $class  = shift;
	my $object = shift || return q();
	my $isjson = shift || 0;
	my $string = q();
	my $arrayr = [];
	my $arrayc = 0;		# The numbers of elements in $arrayr
	my $retaar = 0;		# Return As Array Reference
	my $objref = ref($object) || return $object;

	eval {
		local $JSON::Syck::SortKeys = 1;
		if( $objref eq q|ARRAY| )
		{
			$arrayr = $object;
			$retaar = 1;
		}
		elsif( $objref eq q|HASH| )
		{
			push( @$arrayr, $object );
		}

		# Set the number of elements in $arrayr
		$arrayc = scalar @$arrayr;

		# Print left square bracket character for the format JSON
		$string .= '[ ' if( $isjson && ( $arrayc > 1 || $retaar ) );

		DUMP_AS_JSON: foreach my $e ( @$arrayr )
		{
			$string .= q(- )  if( $isjson == 0 && ( $arrayc > 1 || $retaar ) );
			$string .= JSON::Syck::Dump($e);
			$string =~ s{":(["\d])}{": $1}g;
			$string =~ s{,"}{, "}g;
			$string =~ s/{"/{ "/g;
			$string =~ s/"}/" }/g;
			$string =~ s/:{/: {/g;
			$string .= ',' if( $isjson && ( $arrayc > 1 || $retaar ) );
			$string .= qq(\n) if( $isjson == 0 && ( $arrayc > 1 || $retaar ) );
		}

		# Replace the ',' at the end of data with right square bracket for the format JSON
		$string =~ s{,\z}{ ]} if( $isjson && ( $arrayc > 1 || $retaar ) );
	};

	return \q() if $@;
	return \$string;
}

sub to_object
{
	# +-+-+-+-+-+-+-+-+-+
	# |t|o|_|o|b|j|e|c|t|
	# +-+-+-+-+-+-+-+-+-+
	#
	# @Description	Convert from string to a hash ref
	# @Param	(Ref->Scalar|Path::Class::File|Path string to file) YAML parsable string or file
	# @Return	(Ref->Array) Object
	my $class  = shift;
	my $string = shift || return [];
	my $object = [];
	my $strref = q();
	my $objref = q();

	eval {
		$strref = ref($string);

		if( $strref =~ m{\APath::Class::File} )
		{
			# string is a Path::Class::File object
			$object = JSON::Syck::LoadFile( $string->stringify() );
		}
		elsif( $strref eq 'GLOB' )
		{
			# string is file glob
			$object = JSON::Syck::LoadFile( $string );
		}
		elsif( $strref eq 'SCALAR' )
		{
			# string is a reference to a scalar which hold YAML/JSON data
			$object = JSON::Syck::Load( $$string );
		}
		elsif( $strref eq q() )
		{
			# string is file path?
			if( $string !~ m{[\n\r]} && -f $string && -r _ && -T _ )
			{
				# It's a file
				$object = JSON::Syck::LoadFile( $string );
			}
			else
			{
				# It's not a file, something else...
				$object = JSON::Syck::Load( $string );
			}
		}
		else
		{
			# Others
			$object = [];
		}

		$objref = ref $object;
	};
	return [] if $@;

	return [ $object ] if $objref eq 'HASH';
	return $object if $objref eq 'ARRAY';
	return [];
}

sub mergesort
{
	# +-+-+-+-+-+-+-+-+-+
	# |m|e|r|g|g|s|o|r|t|
	# +-+-+-+-+-+-+-+-+-+
	#
	# @Description	Merge sort
	# @Param <ref>	(Ref->Array) Unsorted list
	# @Param <str>	(String) Hash key name
	# @Return	(Ref->Array) Sorted list
	my $class = shift;
	my $slist = shift || return [];
	my $kname = shift || return [];
	my( $lhsln, $rhsln, $wshed );
	my $lhsar = [];
	my $rhsar = [];

	return $slist if scalar(@$slist) < 2;
	$wshed = int( scalar(@$slist) / 2 );

	$lhsar = [ map { $slist->[$_] } ( 0 .. $wshed - 1 ) ];
	$rhsar = [ map { $slist->[$_] } ( $wshed .. scalar(@$slist) - 1 ) ];
	$lhsln = scalar @$lhsar;
	$rhsln = scalar @$rhsar;

	$lhsar = $class->mergesort( $lhsar, $kname );
	$rhsar = $class->mergesort( $rhsar, $kname );

	my $dlist = [];
	my $x = 0;
	my $y = 0;

	while( $x < $lhsln || $y < $rhsln )
	{
		if( $y >= $rhsln || 
			( $x < $lhsln && $lhsar->[$x]->{ $kname } < $rhsar->[$y]->{ $kname } ) ){

			push @$dlist, $lhsar->[ $x++ ];
		}
		else
		{
			push @$dlist, $rhsar->[ $y++ ];
		}
	}

	return $dlist;
}

1;
__END__
