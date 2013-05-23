# $Id: MesgTooBig.pm,v 1.2.2.1 2013/04/15 04:20:53 ak Exp $
# -Id: TooBig.pm,v 1.1 2009/08/29 07:33:28 ak Exp -
# -Id: TooBig.pm,v 1.2 2009/05/11 08:22:29 ak Exp -
# Copyright (C) 2009,2010,2013 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Why::
                                                                      
 ##  ##                      ######              #####    ##          
 ######   ####   ##### #####   ##   ####   ####  ##  ##        #####  
 ######  ##  ## ##    ##  ##   ##  ##  ## ##  ## #####   ###  ##  ##  
 ##  ##  ######  #### ##  ##   ##  ##  ## ##  ## ##  ##   ##  ##  ##  
 ##  ##  ##         ## #####   ##  ##  ## ##  ## ##  ##   ##   #####  
 ##  ##   ####  #####     ##   ##   ####   ####  #####   ####     ##  
                      #####                                   #####   
package Kanadzuchi::Mail::Why::MesgTooBig;
use base 'Kanadzuchi::Mail::Why';

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
# Regular expressions of 'Message Too Big'
sub exemplaria
{
	my $class = shift;
	return [
		qr{message file too big},
		qr{message length exceeds administrative limit},
		qr{message size exceeds fixed limit},
		qr{message size exceeds fixed maximum message size},
		qr{message size exceeds maximum value},
		qr{message too big},
	];
}

1;
__END__
