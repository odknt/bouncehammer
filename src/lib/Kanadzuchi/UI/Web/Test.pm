# $Id: Test.pm,v 1.20 2010/05/25 23:54:44 ak Exp $
# -Id: Test.pm,v 1.1 2009/08/29 09:30:33 ak Exp -
# -Id: Test.pm,v 1.10 2009/08/17 12:39:31 ak Exp -
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::UI::Web::
                               
 ######                  ##    
   ##     ####   ##### ######  
   ##    ##  ## ##       ##    
   ##    ######  ####    ##    
   ##    ##         ##   ##    
   ##     ####  #####     ###  
package Kanadzuchi::UI::Web::Test;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use strict;
use warnings;
use base 'Kanadzuchi::UI::Web';
use Kanadzuchi::Mail::Stored::YAML;
use Kanadzuchi::Metadata;
use Time::Piece;

#  ____ ____ ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||I |||n |||s |||t |||a |||n |||c |||e |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub test_ontheweb
{
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+
	# |t|e|s|t|_|o|n|t|h|e|w|e|b|
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Draw test(parse) form in HTML
	# @Param	<None>
	# @Return
	my $self = shift();
	my $file = 'test.'.$self->{'language'}.'.html';
	$self->tt_params( 'maxsize' => $self->{'webconfig'}->{'upload'}->{'maxsize'} );
	$self->tt_process($file);
}

sub parse_ontheweb
{
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	# |p|a|r|s|e|_|o|n|t|h|e|w|e|b|
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Execute test parse on the web.
	# @Param	<None>
	# @Return
	my $self = shift();
	my $file = 'iframe-parseddata.'.$self->{'language'}.'.html';
	my $cgiq = $self->query();
	my $data = [];

	if( defined($cgiq->param('emailfile')) ||
		( defined($cgiq->param('emailtext')) && length($cgiq->param('emailtext'))) ){

		require Kanadzuchi::Mail::Bounced;
		require Kanadzuchi::Mbox;
		require Path::Class;
		require File::Spec;

		my $objzcimbox = undef();	# (Kanadzuchi::Mbox) Mailbox object
		my $mpiterator = undef();	# (Kanadzuchi::Iterator) Iterator for mailbox parser
		my $damnedobjs = [];		# (Ref->Array) Damned hash references 
		my $datasource = q();		# (String) Email text as data source
		my $errortitle = q();		# (String) Error string
		my $sizeofmail = 0;		# (Integer) Size of email file and text
		my $first5byte = q();		# (String) First 5bytes data of mail
		my $serialized = q();		# (String) Serialized data text(YAML|JSON)

		my $pseudofrom = q(From MAILER-DAEMON Sun Dec 31 23:59:59 2000).qq(\n);
		my $fileconfig = $self->{'sysconfig'}->{'file'}->{'templog'};
		my $maxtxtsize = $self->{'webconfig'}->{'upload'}->{'maxsize'};
		my $dataformat = $cgiq->param('format') || 'html';
		my $parseuntil = $cgiq->param('parsenmessages') || 10;

		my $registerit = ( defined($cgiq->param('register')) && $cgiq->param('register') eq 'on' ? 1 : 0 );
		my $execstatus = {
			'update' => 0, 'insert' => 0, 'tooold' => 0, 'exceed' => 0,
			'failed' => 0, 'nofrom' => 0, 'whited' => 0, };

		my $sourcelist = [];		# (Ref->Array) Data source names
		my $givenctype = q();		# (String) Content-Type of the email file
		my $givenemail = $cgiq->param('emailfile') || undef();
		my $pastedmail = $cgiq->param('emailtext') || q();

		# Read email from uploaded file
		if( ref($givenemail) && -s $givenemail )
		{
			READ_EMAIL_FILE: while(1)
			{
				push( @$sourcelist, $givenemail );
				$sizeofmail = -s $givenemail;
				$givenctype = lc $cgiq->uploadInfo( $givenemail )->{'Content-Type'} || 'text/plain';
				$errortitle = 'toobig' if( $maxtxtsize > 0 && length($sizeofmail) > $maxtxtsize );
				$errortitle = 'nottext' if( $givenctype =~ m{\A(audio|application|image|video)/}m );
				last() if( $errortitle );

				# Check first 5bytes of the email
				read( $givenemail, $first5byte, 5 );
				seek( $givenemail, 0, 0 );
				$datasource .= $pseudofrom unless( $first5byte eq 'From ' );

				READ: while( my $__thisline = <$givenemail> )
				{
					$__thisline =~ s{(\x0d\x0a|\x0d|\x0a)}{\n}gm;		# CRLF, CR -> LF
					next() if( $__thisline =~ m{\A[a-zA-Z0-9+/=]+\z}gm );	# Skip if it is Base64 encoded text
					$datasource .= $__thisline;

				} # End of while(READ)

				$datasource .= qq(\n);
				last();

			} # Enf of while(READ_EMAIL_FILE)
		}

		# Read email from pasted text
		if( length($pastedmail) )
		{
			$sizeofmail += length($pastedmail);
			$first5byte  = substr( $pastedmail, 0, 5 );
			$datasource .= $pseudofrom unless( $first5byte eq 'From ' );
			$datasource .= $pastedmail;
			push( @$sourcelist, 'Pasted email test' );
		}

		# Check the size of email text
		$errortitle = 'nosize' if( $sizeofmail == 0 );
		$errortitle = 'toobig' if( $maxtxtsize > 0 && length($datasource) > $maxtxtsize );


		SLURP_AND_EAT: while(1)
		{
			last() if( $errortitle );

			my $temporaryd = ( -w '/tmp' ? '/tmp' : File::Spec->tmpdir() );
			my $counter4id = 0;

			# Slurp , parse, and eat
			$objzcimbox = new Kanadzuchi::Mbox( 'file' => \$datasource );
			$objzcimbox->greed(1);
			$objzcimbox->slurpit() || last();
			$objzcimbox->parseit() || last();
			$mpiterator = Kanadzuchi::Mail::Bounced->eatit( 
					$objzcimbox, { 'cache' => $temporaryd, 'verbose' => 0, 'fast' => 1, } );
			last() unless( $mpiterator->count() );

			if( $mpiterator->count > $parseuntil )
			{
				splice( @{ $mpiterator->data }, $parseuntil );
				$mpiterator->count( scalar @{ $mpiterator->data } );
			}

			# Convert from object to hash reference
			if( $dataformat eq 'html' )
			{
				#      __    _   _ _____ __  __ _     
				#      \ \  | | | |_   _|  \/  | |    
				#  _____\ \ | |_| | | | | |\/| | |    
				# |_____/ / |  _  | | | | |  | | |___ 
				#      /_/  |_| |_| |_| |_|  |_|_____|
				#                                     
				LOAD_AND_DAMN: while( my $o = $mpiterator->next() )
				{
					my $eachdamned = $o->damn();
					my $tmpupdated = new Time::Piece();

					# Human readable date string
					$eachdamned->{'id'} = sprintf( "TEMP-%03d", ++$counter4id );
					$eachdamned->{'updated'}  = $tmpupdated->ymd().'('.$tmpupdated->wdayname().') '.$tmpupdated->hms();
					$eachdamned->{'bounced'}  = $o->bounced->ymd().'('.$o->bounced->wdayname().') '.$o->bounced->hms();
					$eachdamned->{'bounced'} .= ' '.$o->timezoneoffset() if( $o->timezoneoffset() );
					push( @$damnedobjs, $eachdamned );
				}
			}
			else
			{
				#      __   __   __ _    __  __ _       _       _ ____   ___  _   _ 
				#      \ \  \ \ / // \  |  \/  | |     | |     | / ___| / _ \| \ | |
				#  _____\ \  \ V // _ \ | |\/| | |     | |  _  | \___ \| | | |  \| |
				# |_____/ /   | |/ ___ \| |  | | |___  | | | |_| |___) | |_| | |\  |
				#      /_/    |_/_/   \_\_|  |_|_____| | |  \___/|____/ \___/|_| \_|
				#                                      |_|                          
				# Create serialized data for the format YAML or JSON
				require Kanadzuchi::Log;
				my $kanazcilog = Kanadzuchi::Log->new();

				$kanazcilog->count( $mpiterator->count() );
				$kanazcilog->format( $dataformat );
				$kanazcilog->entities( $mpiterator->all() );
				$serialized = $kanazcilog->dumper();
			}

			if( $registerit )
			{
				#      __    ____    _  _____  _    ____    _    ____  _____ 
				#      \ \  |  _ \  / \|_   _|/ \  | __ )  / \  / ___|| ____|
				#  _____\ \ | | | |/ _ \ | | / _ \ |  _ \ / _ \ \___ \|  _|  
				# |_____/ / | |_| / ___ \| |/ ___ \| |_) / ___ \ ___) | |___ 
				#      /_/  |____/_/   \_\_/_/   \_\____/_/   \_\____/|_____|
				#                                                            
				require Kanadzuchi::BdDR::BounceLogs;
				require Kanadzuchi::BdDR::BounceLogs::Masters;
				require Kanadzuchi::BdDR::Cache;
				require Kanadzuchi::Mail::Stored::YAML;
				require Kanadzuchi::Mail::Stored::BdDR;

				my $tablecache = undef();	# (Kanadzuchi::BdDR::Cache) Table cache object
				my $xntableobj = undef();	# (Kanadzuchi::BdDR::BounceLogs::Table) Txn table object
				my $mastertabs = {};		# (Ref->Hash) Kanadzuchi::BdDR::BounceLogs::Masters::Table objects
				my $xntabalias = q();		# (String) lower cased txn table alias
				my $recinthedb = 0;		# (Integer) The number of records in the db
				my $bddrobject = $self->{'database'};
				my $xsoftlimit = $self->{'sysconfig'}->{'database'}->{'table'}->{'bouncelogs'}->{'maxrecords'} || 0;

				$mpiterator->reset();
				$tablecache = Kanadzuchi::BdDR::Cache->new();
				$xntableobj = Kanadzuchi::BdDR::BounceLogs::Table->new( 'handle' => $bddrobject->handle() );
				$mastertabs = Kanadzuchi::BdDR::BounceLogs::Masters::Table->mastertables( $bddrobject->handle() );
				$xntabalias = lc $xntableobj->alias();
				$recinthedb = $xntableobj->count();

				DATABASECTL: while( my $o = $mpiterator->next() )
				{
					my $thiscached = {};		# (Ref->Hash) Cached data of each table
					my $thismtoken = q();		# (String) This record's message token
					my $thismepoch = 0;		# (Integer) Bounced time
					my $thisstatus = 0;		# (Integer) Returned status value
					my $execinsert = 0;		# (Integer) Flag; Exec INSERT

					bless( $o, q|Kanadzuchi::Mail::Stored::YAML| );

					# Check limit the number of records
					if( $xsoftlimit > 0 && ($execstatus->{'insert'} + $recinthedb) >= $xsoftlimit )
					{
						# Exceeds limit!
						$execstatus->{'exceed'}++;
						next();
					}

					# Check cached data
					$thismtoken = $o->token();
					$thismepoch = $o->bounced->epoch();
					$thiscached = $tablecache->getit( $xntabalias, $thismtoken );

					if( exists($thiscached->{'bounced'}) )
					{
						# Cache hit!
						# This record's bounced date is OLDER THAN the record in the cache.
						if( $thiscached->{'bounced'} >= $thismepoch )
						{
							$execstatus->{'tooold'}++;
							next();
						}
					}
					else
					{
						# No cache data of this entity
						if( $o->findbytoken($xntableobj,$tablecache) )
						{
							# The record that has same token exists in the database
							$thiscached = $tablecache->getit( $xntabalias, $thismtoken );

							if( $thiscached->{'bounced'} >= $thismepoch )
							{
								# This record's bounced date is older than the record in the database.
								$execstatus->{'tooold'}++;
								next();
							}
							elsif( $thiscached->{'reason'} eq 'whitelisted' )
							{
								# The whitelisted record is not updated without --force option.
								$execstatus->{'whited'}++;
								next();
							}
						}
						else
						{
							# Record that have same token DOES NOT EXIST in the database
							# Does the senderdomain exist in the mastertable?
							if( $mastertabs->{'senderdomains'}->getidbyname($o->senderdomain()) )
							{
								$execinsert = 1;
							}
							else
							{
								# The senderdomain DOES NOT EXIST in the mastertable
								$execstatus->{'nofrom'}++;
								next();
							}
						}
					}

					# UPDATE OR INSERT
					if( $execinsert )
					{
						# INSERT this record INTO the database
						$thisstatus = $o->insert($xntableobj,$mastertabs,$tablecache);
						$thisstatus ? $execstatus->{'insert'}++ : $execstatus->{'failed'}++;
					}
					else
					{
						$thisstatus = $o->update($xntableobj,$tablecache);
						$thisstatus ? $execstatus->{'update'}++ : $execstatus->{'failed'}++;
					}

				} # End of while(DATABASECTL)

			} # End of if(REGISTERIT)

			last(SLURP_AND_EAT);

		} # End of while(SLURP_AND_EAT)

		$self->tt_params( 
			'bouncemessages' => $damnedobjs,
			'parseddatatext' => $serialized,
			'parsedfilename' => join( ',', @$sourcelist ),
			'parsedfilesize' => $datasource ? length($datasource) : $sizeofmail,
			'parsedmessages' => defined($mpiterator) ? $mpiterator->count() : 0,
			'outputformat' => $dataformat,
			'onlineparse' => 1,
			'onlineupdate' => $registerit,
			'updateresult' => $execstatus,
			'parseerror' => $errortitle, );
	}

	$self->tt_process($file);
}

1;
__END__
