# $Id: Smartphone.pm,v 1.1.2.3 2013/04/15 04:20:53 ak Exp $
# Copyright (C) 2011,2013 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Group::IT::
                                                                        
  #####                        ##          ##                           
 ###     ##  ##  ####  ##### ###### #####  ##      ####  #####   ####   
  ###    ######     ## ##  ##  ##   ##  ## #####  ##  ## ##  ## ##  ##  
   ###   ######  ##### ##      ##   ##  ## ##  ## ##  ## ##  ## ######  
    ###  ##  ## ##  ## ##      ##   #####  ##  ## ##  ## ##  ## ##      
 #####   ##  ##  ##### ##       ### ##     ##  ##  ####  ##  ##  ####   
                                    ##                                  
package Kanadzuchi::Mail::Group::IT::Smartphone;
use base 'Kanadzuchi::Mail::Group';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
# Major company's smaprtphone domains in Italian Republic/Repubblica Italiana
sub communisexemplar { return qr{[.]com\z}; }
sub nominisexemplaria
{
	my $class = shift;
	return {
		'three' => [
			# 3 Italia; http://www.tre.it/
			qr{\Atreitalia[.]blackberry[.]com\z},
		],
		'tim' => [
			# TIM.it; http://www.tim.it/
			qr{\Atim[.]blackberry[.]com\z},
		],
	};
}

sub classisnomina
{
	my $class = shift;
	return {
		'three'		=> 'Generic',
		'tim'		=> 'Generic',
	};
}

1;
__END__
