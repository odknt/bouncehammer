# $Id: 034_mta-google.t,v 1.1 2010/07/07 04:42:44 ak Exp $
#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use lib qw(./t/lib ./dist/lib ./src/lib);
use strict;
use warnings;
use Kanadzuchi::Test;
use Kanadzuchi::MTA::Google;
use Test::More ( tests => 11 );

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
my $Test = new Kanadzuchi::Test(
		'class' => q|Kanadzuchi::MTA::Google|,
		'methods' => [ 'xsmtpcommand', 'emailheaders', 'reperit' ],
		'instance' => undef(),
);
my $Head = {
	'subject' => 'Delivery Status Notification (Failure)',
	'from' => 'Mail Delivery Subsystem <mailer-daemon@googlemail.com>',
	'date' => 'Fri, 17 Jul 2009 07:24:12 -0700 (PDT)',
	'to' => 'postmaster@gmail.com',
	'x-failed-recipients' => 'userunknown@example.jp',
};

#  ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ 
# ||T |||e |||s |||t |||       |||c |||o |||d |||e |||s ||
# ||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|
#
PREPROCESS: {
	can_ok( $Test->class(), @{ $Test->methods } );
	is( $Test->class->xsmtpcommand(), 'X-SMTP-Command: ', '->xsmtpcommand() = X-SMTP-Command:' );
	isa_ok( $Test->class->emailheaders(), q|ARRAY|, '->emailheaders = []' );
	is( $Test->class->emailheaders->[0], 'X-Failed-Recipients', 'X-Failed-Recipients' );
}

REPERIT: {
	my $mesgbodypart = q();
	my $pseudoheader = q();

	$mesgbodypart .= $_ while( <DATA> );
	$pseudoheader = $Test->class->reperit( $Head, \$mesgbodypart );
	ok( $pseudoheader );
	
	foreach my $el ( split("\n", $pseudoheader) )
	{
		next() if( $el =~ m{\A\z} );
		ok( $el, $el ) if( $el =~ m{X-SMTP-Command: [A-Z]{4}} );
		ok( $el, $el ) if( $el =~ m{Arrival-Date: } );
		ok( $el, $el ) if( $el =~ m{Final-Recipient: } );
		ok( $el, $el ) if( $el =~ m{Status: } );
		ok( $el, $el ) if( $el =~ m{Diagnostic-Code: } );
		ok( $el, $el ) if( $el =~ m{From: } );
		ok( $el, $el ) if( $el =~ m{To: } );
	}
}

__DATA__

This is an automatically generated Delivery Status Notification

Delivery to the following recipient failed permanently:

     userunknown@example.jp

Technical details of permanent failure: 
Google tried to deliver your message, but it was rejected by the recipient domain. We recommend contacting the other email provider for further information about the cause of this error. The error that the other server returned was: 550 550 5.1.1 <userunknown@example.jp>... User Unknwon (state 14).

   ----- Original message -----

Received: by 10.141.36.17 with SMTP id o17mr796477rvj.190.1247840650302;
        Fri, 17 Jul 2009 07:24:10 -0700 (PDT)
Return-Path: <postmaster@gmail.com>
Received: from ?192.0.2.1? (x-y.kyoto.ocn.ne.jp [192.0.2.99])
        by mx.google.com with ESMTPS id g14sm7060009rvb.4.2009.07.17.07.24.09
        (version=TLSv1/SSLv3 cipher=RC4-MD5);
        Fri, 17 Jul 2009 07:24:09 -0700 (PDT)
Mime-Version: 1.0 (Apple Message framework v753.1)
Content-Transfer-Encoding: 7bit
Message-Id: <EF1D4A34-2625-4BAF-8B09-F1504F3BBBF2@gmail.com>
Content-Type: text/plain; charset=US-ASCII; format=flowed
To: userunknown@example.jp
From: <postmaster@gmail.com>
Subject: TEST OF BOUNCE FROM GMAIL
Date: Fri, 17 Jul 2009 23:24:14 +0900

test


   ----- End of message -----


