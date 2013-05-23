# $Id: Smartphone.pm,v 1.1.2.4 2013/04/15 04:20:53 ak Exp $
# -Id: SmartPhone.pm,v 1.1 2009/08/29 07:33:22 ak Exp -
# Copyright (C) 2011,2013 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Group::CH::
                                                                        
  #####                        ##          ##                           
 ###     ##  ##  ####  ##### ###### #####  ##      ####  #####   ####   
  ###    ######     ## ##  ##  ##   ##  ## #####  ##  ## ##  ## ##  ##  
   ###   ######  ##### ##      ##   ##  ## ##  ## ##  ## ##  ## ######  
    ###  ##  ## ##  ## ##      ##   #####  ##  ## ##  ## ##  ## ##      
 #####   ##  ##  ##### ##       ### ##     ##  ##  ####  ##  ##  ####   
                                    ##                                  
package Kanadzuchi::Mail::Group::CH::Smartphone;
use base 'Kanadzuchi::Mail::Group';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
# Major company's smaprtphone domains in Switzerland/Swiss Confederation/Confoederatio Helvetica
# http://www.thegremlinhunt.com/2010/01/07/list-of-blackberry-internet-service-e-mail-login-sites/
# sub communisexemplar { return qr{[.]ch\z}; }
sub nominisexemplaria
{
	my $class = shift;
	return {
		# orange: see ../Smartphone.pm
		'sunrise' => [
			# Sunrise; http://www1.sunrise.ch/
			qr{\Asunrise[.]blackberry[.]com\z},
		],
		'swisscom' => [
			# Swisscom; http://en.swisscom.ch/
			qr{\Amobileemail[.]swisscom[.]ch\z},
		],
	};
}

sub classisnomina
{
	my $class = shift;
	return {
		'sunrise'	=> 'Generic',
		'swisscom'	=> 'Generic',
	};
}

1;
__END__
