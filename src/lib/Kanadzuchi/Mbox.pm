# $Id: Mbox.pm,v 1.4 2010/03/01 23:41:41 ak Exp $
# -Id: Parser.pm,v 1.10 2009/12/26 19:40:12 ak Exp -
# -Id: Parser.pm,v 1.1 2009/08/29 08:50:27 ak Exp -
# -Id: Parser.pm,v 1.4 2009/07/31 09:03:53 ak Exp -
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::
                             
 ##  ## ##                   
 ###### ##      #### ##  ##  
 ###### #####  ##  ## ####   
 ##  ## ##  ## ##  ##  ##    
 ##  ## ##  ## ##  ## ####   
 ##  ## #####   #### ##  ##  
package Kanadzuchi::Mbox;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use base 'Class::Accessor::Fast::XS';
use strict;
use warnings;
use Perl6::Slurp;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||A |||c |||c |||e |||s |||s |||o |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
__PACKAGE__->mk_accessors(
	'file',		# (String) File name to parse
	'greed',	# (Integer) Flag, 1 is greedily parse
	'emails',	# (Ref->Array) eMails, Raw test data
	'nmails',	# (Interger) The number of eMails
	'messages',	# (Ref->Array) Messages(Ref->Hash)
	'nmesgs',	# (Integer) The number of parsed messages
);

#  ____ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||o |||n |||s |||t |||a |||n |||t ||
# ||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||F |||u |||n |||c |||t |||i |||o |||n |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub ENDOF() { qq(\n__THE_END_OF_THE_EMAIL__\n); }

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
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
	# @Param
	# @Return	Kanadzuchi::Mbox Object
	my $class = shift();
	my $argvs = { @_ };

	DEFAULT_VALUES: {
		$argvs->{'greed'} = 0 unless($argvs->{'greed'});
		$argvs->{'nmails'} = 0;
		$argvs->{'emails'} = [];
		$argvs->{'nmesgs'} = 0;
		$argvs->{'messages'} = [];
	}

	return( $class->SUPER::new( $argvs ) );
}

sub _breakit
{
	# +-+-+-+-+-+-+-+-+
	# |_|b|r|e|a|k|i|t|
	# +-+-+-+-+-+-+-+-+
	#
	# @Description	Break the header of message and return its body
	# @Param <ref>	(Ref->Hash) Message entity.
	# @Param <ref>	(Ref->String) Message body
	# @Return	(String) Message body or empty string
	my $packagename = shift();
	my $thismessage = shift() || return(q());
	my $thebodypart = shift() || return(q());
	my $theheadpart = $thismessage->{'head'};

	my $parserclass = q();		# (String) Package|Class name
	my $pseudofield = q();		# (String) Pseudo headers
	my $fwdmesgbody = q();		# (String) message body of the forwarded one
	my $newmesgbody = q();		# (String) New message body
	my $isforwarded = 0;		# (Integer) Is forwarded message
	my $isirregular = 0;		# (Integer) Is irregular bounce message 
	my $irregularof = {
		'aubykddi'	=> ( 1 << 0 ),
		'accelmail'	=> ( 1 << 1 ),
		'googlemail'	=> ( 1 << 2 ),
	};

	# Check whether or not the message is a bounce mail.
	#  _____             _     _____                                _          _ 
	# |  ___|_      ____| |_  |  ___|__  _ ____      ____ _ _ __ __| | ___  __| |
	# | |_  \ \ /\ / / _` (_) | |_ / _ \| '__\ \ /\ / / _` | '__/ _` |/ _ \/ _` |
	# |  _|  \ V  V / (_| |_  |  _| (_) | |   \ V  V / (_| | | | (_| |  __/ (_| |
	# |_|     \_/\_/ \__,_(_) |_|  \___/|_|    \_/\_/ \__,_|_|  \__,_|\___|\__,_|
	#                                                                            
	# Pre-Process eMail body if it is a forwarded bounce message.
	#  Get forwarded text if a subject begins from 'fwd:' or 'fw:'
	if( lc( $theheadpart->{'subject'} ) =~ m{\A\s*fwd?:} )
	{
		$isforwarded |= 1;

		# Break quoted strings, quote symbols(>)
		$fwdmesgbody =  $$thebodypart;
		$fwdmesgbody =~ s{\A.+?[>]}{>}s;
		$fwdmesgbody =~ s{^[>]+[ ]}{}gm;
		$fwdmesgbody =~ s{^[>]$}{}gm;
		$newmesgbody =  $fwdmesgbody;
	}

	#  ___                           _                          
	# |_ _|_ __ _ __ ___  __ _ _   _| | __ _ _ __    __ _ _   _ 
	#  | || '__| '__/ _ \/ _` | | | | |/ _` | '__|  / _` | | | |
	#  | || |  | | |  __/ (_| | |_| | | (_| | |    | (_| | |_| |
	# |___|_|  |_|  \___|\__, |\__,_|_|\__,_|_|     \__,_|\__,_|
	#                    |___/                                  
	# Pre-Process eMail headers of NON-STANDARD bounce message
	# au by KDDI(ezweb.ne.jp)
	if( lc($theheadpart->{'from'}) =~ m{[<]?(?>postmaster[@]ezweb[.]ne[.]jp)[>]?} )
	{
		eval {
			use Kanadzuchi::Mbox::aubyKDDI;
			$parserclass = q(Kanadzuchi::Mbox::aubyKDDI);
			$pseudofield .= $parserclass->detectus( $theheadpart, q() );
			$isirregular |= $irregularof->{'aubykddi'} if( length( $pseudofield ) );
		};
	}

	#  ___                           _                 _    __  __ 
	# |_ _|_ __ _ __ ___  __ _ _   _| | __ _ _ __     / \  |  \/  |
	#  | || '__| '__/ _ \/ _` | | | | |/ _` | '__|   / _ \ | |\/| |
	#  | || |  | | |  __/ (_| | |_| | | (_| | |     / ___ \| |  | |
	# |___|_|  |_|  \___|\__, |\__,_|_|\__,_|_|    /_/   \_\_|  |_|
	#                    |___/                                     
	# Pre-Process eMail headers of NON-STANDARD bounce message
	# KLab's AccelMail, see http://www.klab.jp/am/
	if( $theheadpart->{'x-amerror'} )
	{
		eval {
			use Kanadzuchi::Mbox::KLab;
			$parserclass  = q(Kanadzuchi::Mbox::KLab);
			$pseudofield .= $parserclass->detectus( $theheadpart, q() );
			$isirregular |= $irregularof->{'accelmail'} if( length( $pseudofield ) );
		};
	}

	#  ___                           _               ____ __  __ 
	# |_ _|_ __ _ __ ___  __ _ _   _| | __ _ _ __   / ___|  \/  |
	#  | || '__| '__/ _ \/ _` | | | | |/ _` | '__| | |  _| |\/| |
	#  | || |  | | |  __/ (_| | |_| | | (_| | |    | |_| | |  | |
	# |___|_|  |_|  \___|\__, |\__,_|_|\__,_|_|     \____|_|  |_|
	#                    |___/                                   
	# Google Mail: GMail
	if( $theheadpart->{'x-failed-recipients'} )
	{
		eval {
			use Kanadzuchi::Mbox::Google;
			$parserclass  = q(Kanadzuchi::Mbox::Google);
			$pseudofield .= $parserclass->detectus( $theheadpart, $thebodypart );
			$isirregular |= $irregularof->{'googlemail'} if( length( $pseudofield ) );
		};
	}


	# Pre-Process eMail headers of standard bounce message
	if( $isirregular == 0 && $isforwarded == 0 )
	{
		return( q{} ) unless( $theheadpart->{'content-type'} );
		return( q{} )
			unless(	$theheadpart->{'content-type'} =~ m{^multipart/report} ||
				$theheadpart->{'content-type'} =~ m{^message/delivery-status} ||
				$theheadpart->{'content-type'} =~ m{^message/rfc822} ||
				$theheadpart->{'content-type'} =~ m{^text/rfc822-headers} );
		return($$thebodypart);
	}
	else
	{
		return( $pseudofield.$fwdmesgbody ) if( $fwdmesgbody );
		return( $pseudofield.$$thebodypart );
	}

}

#  ____ ____ ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||I |||n |||s |||t |||a |||n |||c |||e |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub slurpit
{
	# +-+-+-+-+-+-+-+
	# |s|l|u|r|p|i|t|
	# +-+-+-+-+-+-+-+
	#
	# @Description	Slurp the email
	# @Param	<None>
	# @Return	(Integer) n = The number of slurped emails
	my $self = shift();
	my $file = defined($self->{'file'}) ? $self->{'file'} : \*STDIN;

	unless( ref($file) eq q|SCALAR| )
	{
		return(0) if( $file =~ m{[\n\r]} || $file =~ m{[\x00-\x1f\x7f]} );
		return(0) if(
			! ( -f $file && -T _ && -s _ ) &&
			! ( ref($file) eq q|GLOB| && -T $file ) );
	}

	$self->{'emails'} = [];

	eval {
		# Slurp the mailbox, Convert from CRLF to LF,
		@{$self->{'emails'}} =
			map( { s{\x0d\x0a}{\n}g; y{\x0d\x0a}{\n\n}; q(From ).$_; }
				Perl6::Slurp::slurp( $file,
					{
						'irs' => qr(\nFrom ), 
						'chomp' => ENDOF
					}
				)
			);

		$self->{'emails'}->[0] =~ s{\AFrom (.+)\z}{$1}s;
		$self->{'emails'}->[ $#{$self->{'emails'}} ] .= ENDOF;
	};

	return(0) if($@);
	$self->{'nmails'} = scalar( @{$self->{'emails'}} );
	return( $self->{'nmails'} );
}

sub parseit
{
	# +-+-+-+-+-+-+-+
	# |p|a|r|s|e|i|t|
	# +-+-+-+-+-+-+-+
	#
	# @Description	Parse the email text
	# @Param	<None>
	# @Return	(Integer) n = The number of parsed messages
	my $self = shift();
	my $ends = ENDOF;
	my $seek = 0;
	my $emailheader = {
		'regular' => [ 'From', 'To', 'Date', 'Subject', 'Content-Type' ],
		'irregular' => [ 'X-SPASIGN', 'X-AMERROR', 'X-Failed-Recipients' ],
	};

	my( $_mesg, $_from, $_head, $_body );

	PARSE_EMAILS: foreach my $_email ( @{$self->{'emails'}} )
	{
		$_mesg = {};
		$_from = q();	# 'From_' of UNIX mbox
		$_head = q();	# Message header as a string
		$_body = q();	# Message body as a string

		if( $_email =~ m{\AFrom[ ](.+?)\n(.+?)\n\n(.+)$ends\z}so )
		{
			$_from = $1;
			$_head = $2;
			$_body = $3;
		}
		elsif( $_email =~ m{\A(.+?)\n\n(.+)$ends\z}so )
		{
			# There is no UNIX From line, Insert pseudo it.
			$_from = q(From MAILER-DAEMON Sun Dec 31 23:59:59 2000);
			$_head = $1;
			$_body = $2;
		}
		else
		{
			next(PARSE_EMAILS);
		}

		# 1. From_
		$_mesg->{'from'} = $_from;

		# 2. Parse email headers
		foreach my $_eh ( @{$emailheader->{'regular'}}, @{$emailheader->{'irregular'}} )
		{
			( $_mesg->{'head'}->{ lc($_eh) } ) = $_head =~ m/^${_eh}:[ ]*(.+?)$/m;
		}

		# 3. Rewrite the part of message body
		$_mesg->{'body'} = __PACKAGE__->_breakit( $_mesg, \$_body );
		$_head = q();


		# Parse message body
		# Concatenate multiple-lined headers
		next(PARSE_EMAILS) unless( $_mesg->{'body'} );
		$_mesg->{'body'} =~ s{^[Ff]rom:[ ]*([^\n\r]+)[\n\r][ \t]+([^\n\r]+)}{From: $1 $2}gm;
		$_mesg->{'body'} =~ s{^[Tt]o:[ ]*([^\n\r]+)[\n\r][ \t]+([^\n\r]+)}{To: $1 $2}gm;
		$_mesg->{'body'} =~ s{^[Dd]iagnostic-[Cc]ode:[ ]*([^\n\r]+)[\n\r][ \t]+([^\n\r]+)}{Diagnostic-Code: $1 $2}gm;

		# Delete non-required headers
		$_mesg->{'body'} =~ y{\n}{\n}s;		# Delete blank lines
		$_mesg->{'body'} =~ s{^\W.+[\r\n]}{}mg;	# Delete non-email headers

		# Parse greedy
		if( $self->{'greed'} )
		{
			# Addresser
			$_mesg->{'body'} =~ s{^Resent-Reply-To:[ ]*(.+)$}{<<<<: Resent-Reply-To: $1}m;
			$_mesg->{'body'} =~ s{^Apparently-From:[ ]*(.+)$}{<<<<: Apparently-From: $1}m;
			$_mesg->{'body'} =~ s{^Resent-Sender:[ ]*(.+)$}{<<<<: Resent-Sender: $1}m;
			$_mesg->{'body'} =~ s{^Resent-From:[ ]*(.+)$}{<<<<: Resent-From: $1}m;
			$_mesg->{'body'} =~ s{^Sender:[ ]*(.+)$}{<<<<: Sender: $1}m;

			# Recipient
			$_mesg->{'body'} =~ s{^X-Envelope-To:[ ]*(.+)$}{<<<<: X-Envelope-To: $1}m;
			$_mesg->{'body'} =~ s{^Apparently-To:[ ]*(.+)$}{<<<<: Apparently-To: $1}m;
			$_mesg->{'body'} =~ s{^Envelope-To:[ ]*(.+)$}{<<<<: Envelope-To: $1}m;
			$_mesg->{'body'} =~ s{^Resent-To:[ ]*(.+)$}{<<<<: Resent-To: $1}m;

			# Date
			$_mesg->{'body'} =~ s{^Resent-Date:[ ]*(.+)$}{<<<<: Resent-Date: $1}m;
			$_mesg->{'body'} =~ s{^Posted-Date:[ ]*(.+)$}{<<<<: Posted-Date: $1}m;
			$_mesg->{'body'} =~ s{^Posted:[ ]*(.+)$}{<<<<: Posted: $1}m;
		}

		# Mark required headers
		$_mesg->{'body'} =~ s{^Errors-To:[ ]*(.+)([;].+)?$}{<<<<: Errors-To: $1}m;
		$_mesg->{'body'} =~ s{^Delivered-To:[ ]*(.+)$}{<<<<: Delivered-To: $1}m;
		$_mesg->{'body'} =~ s{^Return-Path:[ ]*(.+)$}{<<<<: Return-Path: $1}m;
		$_mesg->{'body'} =~ s{^Final-Recipient:[ ]*[Rr][Ff][Cc]822;[ ]*(.+)$}{<<<<: Final-Recipient: $1}m;
		$_mesg->{'body'} =~ s{^Original-Recipient:[ ]*[Rr][Ff][Cc]822;[ ]*(.+)$}{<<<<: Original-Recipient: $1}m;
		$_mesg->{'body'} =~ s{^Diagnostic-Code:[ ]*(.+)$}{<<<<: Diagnostic-Code: $1}m;
		$_mesg->{'body'} =~ s{^Arrival-Date:[ ]*(.+)$}{<<<<: Arrival-Date: $1}m;
		$_mesg->{'body'} =~ s{^Last-Attempt-Date:[ ]*(.+)$}{<<<<: Last-Attempt-Date: $1}m;
		$_mesg->{'body'} =~ s{^X-Actual-Recipient:[ ]*[Rf][Ff][Cc]822;[ ]*(.+)$}{<<<<: X-Actual-Recipient: $1}m;
		$_mesg->{'body'} =~ s{^X-Actual-Recipient:[ ]*(.+)$}{<<<<: X-Actual-Recipient: $1}m;
		$_mesg->{'body'} =~ s{^X-Postfix-Sender:[ ]*(.+)$}{<<<<: X-Postfix-Sender: $1}m;
		$_mesg->{'body'} =~ s{^X-Envelope-From:[ ]*(.+)$}{<<<<: X-Envelope-From: $1}m;
		$_mesg->{'body'} =~ s{^Envelope-From:[ ]*(.+)$}{<<<<: Envelope-From: $1}m;
		$_mesg->{'body'} =~ s{^Action:[ ]*(\S+)$}{<<<<: Action: $1}m;
		$_mesg->{'body'} =~ s{^Status:[ ]*(\d[.]\d[.]\d).*$}{<<<<: Status: $1}m;
		$_mesg->{'body'} =~ s{^Date:[ ]*(.+)$}{<<<<: Date: $1}m;
		$_mesg->{'body'} =~ s{^From:[ ]*(.+)$}{<<<<: From: $1}gm;
		$_mesg->{'body'} =~ s{^Reply-To:[ ]*(.+)$}{<<<<: Reply-To: $1}m;
		$_mesg->{'body'} =~ s{^To:[ ]*(.+)$}{<<<<: To: $1}m;

		$_mesg->{'body'} =~ s{^\w.+[\r\n]}{}gm;			# Delete non-required headers
		$_mesg->{'body'} =~ s{^<<<<:\s}{}gom;			# Delete the mark

		push( @{$self->{'messages'}}, {
				'from' => $_mesg->{'from'},
				'head' => $_mesg->{'head'},
				'body' => $_mesg->{'body'}, } );

		$self->{'nmesgs'}++;
	}
	continue
	{
		# Flush the entity of the array
		$self->{'emails'}->[ $seek++ ] = {};

	} # End of foreach():PARSE_EMAILS

	$self->{'emails'} = [];
	return( $self->{'nmesgs'} );
}

1;
__END__
