# $Id: Cellphone.pm,v 1.1.2.2 2013/04/15 04:20:53 ak Exp $
# Copyright (C) 2009-2010,2013 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Group::NI::
                                                            
  ####        ###  ###         ##                           
 ##  ##  ####  ##   ##  #####  ##      ####  #####   ####   
 ##     ##  ## ##   ##  ##  ## #####  ##  ## ##  ## ##  ##  
 ##     ###### ##   ##  ##  ## ##  ## ##  ## ##  ## ######  
 ##  ## ##     ##   ##  #####  ##  ## ##  ## ##  ## ##      
  ####   #### #### #### ##     ##  ##  ####  ##  ##  ####   
                        ##                                  
package Kanadzuchi::Mail::Group::NI::Cellphone;
use base 'Kanadzuchi::Mail::Group';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
# Cellular phone domains in Nicaragua
# See http://en.wikipedia.org/wiki/List_of_SMS_gateways
# sub communisexemplar { return qr{[.]ni\z}; }
sub nominisexemplaria
{
	# *** NOT TESTED YET ***
	my $self = shift;
	return {
		'claro' => [
			# Claro; http://www.americamovil.com/
			qr{\Aideasclaro-ca[.]com\z},
		],
	};
}

sub classisnomina
{
	my $class = shift;
	return {
		'claro'		=> 'Generic',
	};
}

1;
__END__
