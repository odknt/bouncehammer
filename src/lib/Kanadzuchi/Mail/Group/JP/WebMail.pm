# $Id: WebMail.pm,v 1.8.2.2 2013/04/15 09:33:32 ak Exp $
# Copyright (C) 2010,2013 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Group::JP::
                                                   
 ##  ##         ##     ##  ##           ##  ###    
 ##  ##   ####  ##     ######   ####         ##    
 ##  ##  ##  ## #####  ######      ##  ###   ##    
 ######  ###### ##  ## ##  ##   #####   ##   ##    
 ######  ##     ##  ## ##  ##  ##  ##   ##   ##    
 ##  ##   ####  #####  ##  ##   #####  #### ####   
package Kanadzuchi::Mail::Group::JP::WebMail;
use base 'Kanadzuchi::Mail::Group';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
# Major company's Webmail domains in Japan
sub nominisexemplaria
{
	my $class = shift;
	return {
		'aubykddi' => [
			# KDDI auone(Gmail); http://auone.jp/
			qr{\Aauone[.]jp\z},
		],
		'goo' => [
			# goo mail, http://mail.goo.ne.jp/index.html
			qr{\Amail[.]goo[.]ne[.]jp\z},
			qr{\Agoo[.]jp\z},
		],
		'infoseek' => [
			# http://infoseek.jp/ < 50MB...
			qr{\Ainfoseek[.]jp\z},
			qr{\Arakuten[.]com\z},
		],
		'livedoor' => [
			# livedoor mail(Gmail) http://mail.livedoor.com/
			qr{\Alivedoor[.]com\z},	# Until Oct 31, 2013
		],
		'nifty' => [
			# http://www.nifty.com/
			qr{\Anifty[.]com\z},
			qr{\Anifmail[.]jp\z},			# Until Sep 30, 2010
			qr{\A(?:mb|sp).+[.]nifty[.]com\z},	# http://www.nifty.com/mail/mailaccount/service.htm
			qr{\A[0-9a-z]+[.]nifty[.]jp\z},		# http://www.nifty.com/mail/plus/index.htm

			# http://www.nifty.com/mail/sanrio/domainlist.htm
			qr{\A(?:kitty|x[-]o|mymelody|usahana|mimmy|kikilala|charmmy|cinnamonroll)[.]jp\z},
			qr{\A(?:chibimaru|ayankey|mr[-]bear|pannapitta|zashikibuta|tuxedosam)[.]jp\z},
			qr{\A(?:goropikadon|marroncream|littletwinstars|pompompurin|pekkle)[.]jp\z},
			qr{\A(?:pochacco|deardaniel|badbadtz[-]maru|corocorokuririn|pattyandjimmy)[.]jp\z},
			qr{\A(?:pokopon|han[-]gyodon|shirousa|kurousa|sugar[-]bunnies)[.]jp\z},
		],
		'nttdocomo' => [
			# DoCoMo web mail powered by goo; http://dwmail.jp/
			qr{\Adwmail[.]jp\z},
		],
	};
}

sub classisnomina
{
	my $class = shift;
	return {
		'aubykddi'	=> 'Generic',
		'goo'		=> 'Generic',
		'infoseek'	=> 'Generic',
		'livedoor'	=> 'Generic',
		'nifty'		=> 'Generic',
		'nttdocomo'	=> 'Generic',
	};
}

1;
__END__
