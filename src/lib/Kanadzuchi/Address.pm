# $Id: Address.pm,v 1.9 2010/11/13 19:19:23 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::
                                                   
   ##       ##     ##                              
  ####      ##     ##  #####   ####   ##### #####  
 ##  ##  #####  #####  ##  ## ##  ## ##    ##      
 ###### ##  ## ##  ##  ##     ######  ####  ####   
 ##  ## ##  ## ##  ##  ##     ##         ##    ##  
 ##  ##  #####  #####  ##      ####  ##### #####   
package Kanadzuchi::Address;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use base 'Class::Accessor::Fast::XS';
use strict;
use warnings;
use Email::AddressParser;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||A |||c |||c |||e |||s |||s |||o |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
__PACKAGE__->mk_accessors(
	'address',	# (String) eMail address
	'user',		# (String) local part of the email address
	'host',		# (String) domain part of the email address
);

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
	# @Return	(Kanadzuchi::Address) Object
	my $class = shift();
	my $argvs = { @_ }; 

	return undef() unless( defined($argvs->{'address'}) );

	if( $argvs->{'address'} =~ m{\A([^@]+)[@]([^@]+)\z} )
	{
		$argvs->{'user'} = lc($1);
		$argvs->{'host'} = lc($2);

		map { $_ =~ y{`'"<>}{}d } %$argvs;
		$argvs->{'address'} = $argvs->{'user'}.q{@}.$argvs->{'host'};
		return $class->SUPER::new($argvs);
	}
	else
	{
		return undef();
	}
}

sub parse
{
	# +-+-+-+-+-+
	# |p|a|r|s|e|
	# +-+-+-+-+-+
	#
	# @Description	Mail address parser
	# @Param <ref>	(Ref->Array) text include any email address
	# @Return	(Ref->Array) K::Address Objects in the array
	my $class = shift();
	my $argvs = shift() || return undef();
	my $email = undef();
	my $aobjs = [];

	return [] unless( ref($argvs) eq q|ARRAY| );

	PARSE_ARRAY: foreach my $x ( @$argvs )
	{
		next() unless( defined($x) );
		next() unless( $x =~ m{[@]} );

		PARSE_ADDRESS: foreach my $e ( Email::AddressParser->parse($x) )
		{
			next(PARSE_ADDRESS) unless( $e->address() );
			$email = __PACKAGE__->new( 'address' => $e->address() );
			next(PARSE_ADDRESS) unless( defined($email) );
			push( @$aobjs, $email );
		}
	}

	return $aobjs;
}

sub canonify
{
	# +-+-+-+-+-+-+-+-+
	# |c|a|n|o|n|i|f|y|
	# +-+-+-+-+-+-+-+-+
	#
	# @Description	Canonify a mail address(S3=canonify,S4=final)
	# @Param <str>	(String) Email address
	# @Return	(String) Canonified email address
	my $class = shift();
	my $input = shift();

	return q() unless defined $input;
	return q() if ref $input;

	my $canon = q();
	my $token = [ reverse split( q{ }, $input ) ];

	if( scalar(@$token) == 1 )
	{
		$canon = shift @$token;
	}
	else
	{
		foreach my $e ( @$token )
		{
			chomp($e);
			next() unless( $e =~ m{\A[<]?.+[@].+[.][a-z]{2,}[>]?\z} );
			$canon = $e;
			last();
		}
	}

	$canon =~ y{<>[]():;}{}d;	# Remove brackets, colons
	$canon =~ y/{}'"`//d;		# Remove brackets, quotations
	return $canon;
}

1;
__END__
