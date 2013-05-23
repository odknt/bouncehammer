# $Id: ContentError.pm,v 1.2 2010/12/12 06:19:35 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Why::
                                                                                    
  ####                 ##                 ##   ######                               
 ##  ##  ####  ##### ###### ####  ##### ###### ##      #####  #####   ####  #####   
 ##     ##  ## ##  ##  ##  ##  ## ##  ##  ##   ####    ##  ## ##  ## ##  ## ##  ##  
 ##     ##  ## ##  ##  ##  ###### ##  ##  ##   ##      ##     ##     ##  ## ##      
 ##  ## ##  ## ##  ##  ##  ##     ##  ##  ##   ##      ##     ##     ##  ## ##      
  ####   ####  ##  ##   ### ####  ##  ##   ### ######  ##     ##      ####  ##      
package Kanadzuchi::Mail::Why::ContentError;
use base 'Kanadzuchi::Mail::Why';

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
# Regular expressions of 'Rejected'
sub exemplaria
{
	my $class = shift();
	return [ 
		qr{blocked by policy: no spam please},
		qr{domain of sender address .+ does not exist},
		qr{message filtered},
		qr{message filtered[.] please see the faqs section on spam},
		qr{message rejected due to suspected spam content},
		qr{message header size, or recipient list, exceeds policy limit},
		qr{message mime complexity exceeds the policy maximum},
		qr{routing loop detected -- too many received: headers},
		qr{the headers in this message contain improperly-formatted binary content},
		qr{the message was rejected because it contains prohibited virus or spam content},
		qr{this message contains invalid MIME headers},
		qr{this message contains improperly-formatted binary content},
		qr{this message contains text that uses unnecessary base64 encoding},
	];
}

1;
__END__
