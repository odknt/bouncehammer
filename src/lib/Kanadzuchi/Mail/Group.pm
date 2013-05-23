# $Id: Group.pm,v 1.28.2.7 2013/04/15 04:20:53 ak Exp $
# Copyright (C) 2009,2010,2013 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::
                                     
  ####                               
 ##  ## #####   ####  ##  ## #####   
 ##     ##  ## ##  ## ##  ## ##  ##  
 ## ### ##     ##  ## ##  ## ##  ##  
 ##  ## ##     ##  ## ##  ## #####   
  ####  ##      ####   ##### ##      
                             ##      
package Kanadzuchi::Mail::Group;
use strict;
use warnings;
use JSON::Syck;

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub communisexemplar {}
sub nominisexemplaria {}
sub classisnomina {}

sub postulat
{
	# +-+-+-+-+-+-+-+-+
	# |p|o|s|t|u|l|a|t|
	# +-+-+-+-+-+-+-+-+
	#
	# @Description	Require Kanadzuchi::Mail::Group::??::*
	# @Param	<None>
	# @Return	(Ref->Array) Loaded class names
	# @See		etc/avalable-countries
	#   <CCTLD>:
	#     <HOSTGROUP>: 1 or 0
	#       * 0 = Do not load the host group(by area) library, Then "hostgroup" is
	#             "pc", "provider" is "various" in parsed results.
	#       * 1 = Load 'Kanadzuchi::Mail::Group::<CCTLD or ISO3166>::<HOSTGROUP>',
	#             Then it correctly classify host group and provider.
	my $class = shift;
	my $iso3166list = [ qw( AE AL AR AT AU AW BE BG BM BR BS CA CH CL CN CO CR CZ DE DK DO
				EC EG ES FR GR GT HK HN HR HU ID IE IN IL IR IS IT JM JP KE KR
				LB LK LU LV MA MD ME MK MO MU MX MY NG NI NO NL NP NZ OM 
				PA PE PH PK PL PR PT PY RO RS RU SA SE SG SK SR SV TH TR TW
				UA UG UK US UY VE VN ZA) ];
	my $iso3166conf = '__KANADZUCHIROOT__/etc/available-countries';
	my $countryconf = ( -r $iso3166conf && -s _ && -T _ ) ? JSON::Syck::LoadFile($iso3166conf) : {};
	my $didfileload = keys %$countryconf ? 1 : 0;
	my $areaclasses = [];
	my $grclassname = q();
	my $grclasspath = q();

	foreach my $code ( @$iso3166list )
	{
		foreach my $hgrp ( 'Cellphone', 'Smartphone', 'WebMail' )
		{
			next if( $didfileload && ! $countryconf->{ lc($code) }->{ lc($hgrp) } );
			$grclassname =  __PACKAGE__.'::'.$code.'::'.$hgrp;
			$grclasspath =  $grclassname;
			$grclasspath =~ y{:}{/}s;
			$grclasspath .= '.pm';

			eval { require $grclasspath; };
			push @$areaclasses, $grclassname unless $@;
		}
	}

	return $areaclasses;
}

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
	my $commx = $class->communisexemplar() || undef;
	my $regex = $class->nominisexemplaria();
	my $klass = $class->classisnomina();
	my $group = lc $class;
	my $cpath = q();

	return $mdata if( $commx && $dpart !~ $commx );
	$group =~ s{(?>\A.+::)}{};

	foreach my $d ( keys %$regex )
	{
		next unless grep { $dpart =~ $_ } @{ $regex->{ $d } };

		$mdata->{'class'} = 'Kanadzuchi::Mail::Bounced::'.$klass->{ $d };
		$mdata->{'group'} = $group;
		$mdata->{'provider'} = $d;

		unless( $klass->{ $d } eq 'Generic' )
		{
			$cpath =  $mdata->{'class'};
			$cpath =~ y{:}{/}s;
			$cpath .= '.pm';

			require $cpath;
		}
		last;
	}

	return $mdata;
}

1;
__END__
