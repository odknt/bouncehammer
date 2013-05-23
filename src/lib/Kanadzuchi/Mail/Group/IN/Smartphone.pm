# $Id: Smartphone.pm,v 1.1.2.2 2013/04/15 04:20:53 ak Exp $
# -Id: SmartPhone.pm,v 1.1 2009/08/29 07:33:22 ak Exp -
# Copyright (C) 2009,2010,2013 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Group::IN::
                                                                        
  #####                        ##          ##                           
 ###     ##  ##  ####  ##### ###### #####  ##      ####  #####   ####   
  ###    ######     ## ##  ##  ##   ##  ## #####  ##  ## ##  ## ##  ##  
   ###   ######  ##### ##      ##   ##  ## ##  ## ##  ## ##  ## ######  
    ###  ##  ## ##  ## ##      ##   #####  ##  ## ##  ## ##  ## ##      
 #####   ##  ##  ##### ##       ### ##     ##  ##  ####  ##  ##  ####   
                                    ##                                  
package Kanadzuchi::Mail::Group::IN::Smartphone;
use base 'Kanadzuchi::Mail::Group';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
# Major company's smaprtphone domains in India
sub communisexemplar { return qr{[.]com\z}; }
sub nominisexemplaria
{
	my $class = shift;
	return {
		'airtel' => [
			# Bharti Airtel; http://www.airtel.com/
			qr{\Aairtel[.]blackberry[.]com\z},
		],
		'vodafone' => [
			# Vodafone India; http://www.vodafone.in/
			qr{\Ahutch[.]blackberry[.]com\z},
		],
	};
}

sub classisnomina
{
	my $class = shift;
	return {
		'airtel'	=> 'Generic',
		'vodafone'	=> 'Generic',
	};
}

1;
__END__
