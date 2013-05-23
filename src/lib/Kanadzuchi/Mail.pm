# $Id: Mail.pm,v 1.18 2010/03/01 23:41:41 ak Exp $
# -Id: Message.pm,v 1.1 2009/08/29 07:32:59 ak Exp -
# -Id: BounceMessage.pm,v 1.13 2009/08/21 02:43:14 ak Exp -
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::

 ##  ##           ##  ###    
 ######   ####         ##    
 ######      ##  ###   ##    
 ##  ##   #####   ##   ##    
 ##  ##  ##  ##   ##   ##    
 ##  ##   #####  #### ####
package Kanadzuchi::Mail;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use base 'Class::Accessor::Fast::XS';
use strict;
use warnings;
use Kanadzuchi::String;
use Kanadzuchi::Address;
use Kanadzuchi::Metadata;
use Time::Piece;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||A |||c |||c |||e |||s |||s |||o |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
__PACKAGE__->mk_accessors(
	'token',		# (String) Message token/MD5 Hex digest
	'reason',		# (String) Reason of rejection, bounce
	'bounced',		# (Time::Piece) Date: in the original message
	'provider',		# (String) Provider name
	'hostgroup',		# (String) Host group name
	'addresser',		# (K::Address) From: in the original message
	'recipient',		# (K::Address) Final-Recipient:, To: in the original message
	'frequency',		# (Integer) Frequency of bounce
	'description',		# (Ref->Hash) Description
	'destination',		# (String) A domain part of recipinet
	'senderdomain',		# (String) A domain part of addresser
	'diagnosticcode',	# (String) Diagnostic-Code:
	'deliverystatus',	# (Integer) Delivery Status
	'timezoneoffset',	# (Integer) Time zone offset(seconds)
);

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
# Host Groups, See t_table.
my $HostGroups = {
	'undefined'	=> 1,
	'reserved'	=> 2,
	#'reserved'	=> 3,
	#'reserved'	=> 4,
	#'reserved'	=> 5,
	#'reserved'	=> 6,
	'cellphone'	=> 7,
	'smartphone'	=> 8,
	#'reserved'	=> 9,
	#'reserved'	=> 10,
	'pc'		=> 11,
	'webmail'	=> 12,
	#'reserved'	=> 13,
	#'reserved'	=> 14,
	#'reserved'	=> 15,
	'neighbor'	=> 16,
};

# Reasons, See t_reasons table.
my $ReasonWhy = {
	'undefined'	=> 1,
	'userunknown'	=> 2,
	'hostunknown'	=> 3,
	'hasmoved'	=> 4,
	'filtered'	=> 5,
	'suspend'	=> 6,
	# 'reserved'	=> 7,
	# 'reserved'	=> 8,
	'mailboxfull'	=> 9,
	'exceedlimit'	=> 10,
	'systemfull'	=> 11,
	'notaccept'	=> 12,
	'mesgtoobig'	=> 13,
	'mailererror'	=> 14,
	'securityerr'	=> 15,
	# 'reserved'	=> 16,
	'whitelisted'	=> 17,
	'unstable'	=> 18,
	'onhold'	=> 19,
};

my $DomainCache = {};


#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub new
{
	# +-+-+-+
	# |n|e|w|
	# +-+-+-+
	#
	# @Description	Wrapper method of new()
	# @Param	<None>
	# @Return	(K::Mail::*) Object
	my $class = shift();
	my $argvs = { @_ }; 
	my $ldmap = { 'addresser' => 'senderdomain', 'recipient' => 'destination', };

	ADDRESSER_AND_RECIPIENT: foreach my $x ( keys(%$ldmap) )
	{
		next() unless( defined($argvs->{$x}) );

		if( length($argvs->{$x}) && ref($argvs->{$x}) eq q() )
		{
			$argvs->{$x} = new Kanadzuchi::Address( 'address' => $argvs->{$x} );
		}

		next() unless( ref($argvs->{$x}) eq q|Kanadzuchi::Address| );
		# Set senderdomain or destination
		$argvs->{ $ldmap->{$x} } = $argvs->{$x}->host();
	}

	MESSAGE_TOKEN: {
		last() if( defined($argvs->{'token'}) && length($argvs->{'token'}) == 32 );
		last() unless( ref($argvs->{'addresser'}) eq q|Kanadzuchi::Address| );
		last() unless( ref($argvs->{'recipient'}) eq q|Kanadzuchi::Address| );
		$argvs->{'token'} = Kanadzuchi::String->token(
						$argvs->{'addresser'}->address(),
						$argvs->{'recipient'}->address() );
	}

	DATE_AND_TIME: {
		last() unless( defined($argvs->{'bounced'}) );
		last() if( ref($argvs->{'bounced'}) eq q|Time::Piece| );
		last() if( $argvs->{'bounced'} < 0 || $argvs->{'bounced'} > (2 ** 32) );
		$argvs->{'bounced'} = new Time::Piece( $argvs->{'bounced'} );
	}

	SET_EMPTY_VALUES: {
		foreach my $e ( 'reason', 'hostgroup', 'provider', 'diagnosticcode' )
		{
			$argvs->{$e} = q() unless( defined($argvs->{$e}) );
		}
	}

	DETECT_PROVIDER_AND_HOSTGROUP: {
		last() unless( $class =~ m{\AKanadzuchi::Mail::Bounced\z} );
		last() unless( $argvs->{'destination'} );
		eval {
			use Kanadzuchi::RFC2606;
			use Kanadzuchi::Mail::Bounced::Generic;
		};

		my $dpart = $argvs->{'destination'};
		my $klass = $class.q|::Generic|;	# Default Class = K::M::B::Generic
		my $group = 'pc';			# Default Group = PC
		my $provi = 'various';			# Default Provider = Various

		if( Kanadzuchi::RFC2606->is_reserved($dpart) )
		{
			$group = 'reserved';
			$provi = Kanadzuchi::RFC2606->is_rfc2606($dpart) ? 'rfc2606' : 'reserved';
		}
		else
		{
			if( $DomainCache->{$dpart}->{'class'} )
			{
				$klass = $DomainCache->{$dpart}->{'class'};
				$group = $DomainCache->{$dpart}->{'group'};
				$provi = $DomainCache->{$dpart}->{'provider'};
			}
			else
			{
				eval {
					require Kanadzuchi::Mail::Group::Neighbor;
					require Kanadzuchi::Mail::Group::JP::Cellphone;
					require Kanadzuchi::Mail::Group::JP::Smartphone;
					require Kanadzuchi::Mail::Group::WebMail;
				};

				my $tmpcn = q();
				my $tmpci = {};

				foreach my $c ( 'Neighbor', 'JP::Cellphone', 'JP::Smartphone', 'WebMail' )
				{
					$tmpcn = q|Kanadzuchi::Mail::Group::|.$c;
					$tmpci = $tmpcn->detectus($dpart);

					if( $tmpci->{'class'} )
					{
						$klass = $tmpci->{'class'};
						$group = $tmpci->{'group'};
						$provi = $tmpci->{'provider'};
						last();
					}
				}

				# Set cache
				$DomainCache->{$dpart}->{'class'} ||= $klass;
				$DomainCache->{$dpart}->{'group'} ||= $group;
				$DomainCache->{$dpart}->{'provider'} ||= $provi;
			}
		}

		$class = $klass;
		$argvs->{'hostgroup'} = $group;
		$argvs->{'provider'} = $provi;
	}

	PARSE_DESCRIPTION: {

		if( defined($argvs->{'description'}) )
		{
			if( ref($argvs->{'description'}) eq q|HASH| )
			{
				#  ____                        _       _   _    _    ____  _   _ 
				# |  _ \  ___  ___  ___ _ __  (_)___  | | | |  / \  / ___|| | | |
				# | | | |/ _ \/ __|/ __| '__| | / __| | |_| | / _ \ \___ \| |_| |
				# | |_| |  __/\__ \ (__| |    | \__ \ |  _  |/ ___ \ ___) |  _  |
				# |____/ \___||___/\___|_|    |_|___/ |_| |_/_/   \_\____/|_| |_|
				#                                                                
				# 'description' is not empty, Build 'description' as hash reference.
				foreach my $x ( 'deliverystatus', 'diagnosticcode', 'timezoneoffset' )
				{
					next() if( defined($argvs->{$x}) );
					$argvs->{$x} = $argvs->{'description'}->{$x};
				}
			}
			elsif( $argvs->{'description'} =~ m{\A\s*["]*[{].+[}]["]*\s*\z} )
			{
				#  ____                        _           _ ____   ___  _   _ 
				# |  _ \  ___  ___  ___ _ __  (_)___      | / ___| / _ \| \ | |
				# | | | |/ _ \/ __|/ __| '__| | / __|  _  | \___ \| | | |  \| |
				# | |_| |  __/\__ \ (__| |    | \__ \ | |_| |___) | |_| | |\  |
				# |____/ \___||___/\___|_|    |_|___/  \___/|____/ \___/|_| \_|
				#                                                              
				# 'description' is a string (JSON|YAML)?
				# Set values into 3 variables if it is empty and build 'description'
				# as a hash reference.
				my $json = shift @{ Kanadzuchi::Metadata->to_object( \$argvs->{'description'} ) };
				last() unless( ref($json) eq q|HASH| );
				$argvs->{'description'} = $json;

				foreach my $y ( 'deliverystatus', 'diagnosticcode', 'timezoneoffset' )
				{
					next() if( defined($argvs->{$y}) );
					next() unless( defined($json->{$y}) );
					$argvs->{$y} = $json->{$y};
				}
			}
			else
			{
				# 'description' is empty or unknown data format
				# Nothing To Do
				;
			}
		}
		else
		{
			#  ____                        _       _____                 _         
			# |  _ \  ___  ___  ___ _ __  (_)___  | ____|_ __ ___  _ __ | |_ _   _ 
			# | | | |/ _ \/ __|/ __| '__| | / __| |  _| | '_ ` _ \| '_ \| __| | | |
			# | |_| |  __/\__ \ (__| |    | \__ \ | |___| | | | | | |_) | |_| |_| |
			# |____/ \___||___/\___|_|    |_|___/ |_____|_| |_| |_| .__/ \__|\__, |
			#                                                     |_|        |___/ 
			# Empty 'description', Set value into it from 3 variables.
			$argvs->{'description'} = {
				'deliverystatus' => $argvs->{'deliverystatus'} || 0,
				'diagnosticcode' => $argvs->{'diagnosticcode'} || q(),
				'timezoneoffset' => $argvs->{'timezoneoffset'} || q(+0000), };
		}
	}

	SET_DEFAULT_VALUES: {

		$argvs->{'frequency'} = 1 unless( $argvs->{'frequency'} );
		$argvs->{'timezoneoffset'} = q(+0000) unless( $argvs->{'timezoneoffset'} );
		$argvs->{'diagnosticcode'} = q() unless( defined($argvs->{'diagnosticcode'}) );
		$argvs->{'deliverystatus'} = 0 unless( defined($argvs->{'deliverystatus'}) );
	}

	return( $class->SUPER::new($argvs));
}

sub id2gname
{
	# +-+-+-+-+-+-+-+-+
	# |i|d|2|g|n|a|m|e|
	# +-+-+-+-+-+-+-+-+
	#
	# @Description	Host group ID -> Host group name
	# @Param <int>	(Integer) Host group ID
	# @Return	(String) Host group name
	#		(Enpty) Does not exist
	my $class = shift();
	my $theid = shift() || return(q{});
	return(keys(%$HostGroups)) if( $theid eq q{@} );
	return(q{}) unless( $theid );
	return(q{}) unless( $theid =~ m{\A\d+\z} );
	return( 
		[grep { $HostGroups->{$_} == $theid } keys(%$HostGroups)]->[0]
		|| q{} 
	);
}

sub id2rname
{
	# +-+-+-+-+-+-+-+-+
	# |i|d|2|r|n|a|m|e|
	# +-+-+-+-+-+-+-+-+
	#
	# @Description	Reason ID -> the reason
	# @Param <int>	(Integer) Reason ID
	# @Return	(String) The reason
	#		(Enpty) Does not exist
	my $class = shift();
	my $theid = shift() || return(q{});
	return(keys(%$ReasonWhy)) if( $theid eq q{@} );
	return(q{}) unless( $theid );
	return(q{}) unless( $theid =~ m{\A\d+\z} );
	return( 
		[grep { $ReasonWhy->{$_} == $theid } keys(%$ReasonWhy)]->[0]
		|| q{} 
	);
}

sub gname2id
{
	# +-+-+-+-+-+-+-+-+
	# |g|n|a|m|e|2|i|d|
	# +-+-+-+-+-+-+-+-+
	#
	# @Description	Host group name -> Host group ID
	# @Param <str>	(String) Host group name
	# @Return	(Integer) n = Host group ID
	#		(Integer) 0 = Does not exist
	my $class = shift();
	my $gname = shift() || return(0);
	return(values(%$HostGroups)) if( $gname eq q{@} );
	return(0) unless( $gname );
	return( $HostGroups->{$gname} || 0 );
}

sub rname2id
{
	# +-+-+-+-+-+-+-+-+
	# |r|n|a|m|e|2|i|d|
	# +-+-+-+-+-+-+-+-+
	#
	# @Description	The reason -> reason ID
	# @Param <str>	(String) The reason 
	# @Return	(Integer) n = reason ID
	#		(Integer) 0 = Does not exist
	my $class = shift();
	my $rname = shift() || return(0);
	return(values(%$ReasonWhy)) if( $rname eq q{@} );
	return(0) unless( $rname );
	return( $ReasonWhy->{$rname} || 0 );
}

1;
__END__
