# $Id: MTA.pm,v 1.4 2010/11/13 19:20:47 ak Exp $
# Copyright (C) 2010 Cubicroot Co. Ltd.
# Kanadzuchi::
                     
 ##  ## ###### ##    
 ######   ##  ####   
 ######   ## ##  ##  
 ##  ##   ## ######  
 ##  ##   ## ##  ##  
 ##  ##   ## ##  ##  
package Kanadzuchi::MTA;
use strict;
use warnings;
use Kanadzuchi::RFC2822;
use Kanadzuchi::RFC3463;
use Kanadzuchi::Address;

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub emailheaders { return []; }
sub reperit { return q(); }
sub xsmtpagent
{ 
	# +-+-+-+-+-+-+-+-+-+-+
	# |x|s|m|t|p|a|g|e|n|t|
	# +-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Return pseudo-header for SMTP Agent(MTA)
	# @Param <str>	(String) SMTP agnet name
	# @Returns	(String) Pseudo-header
	my $class = shift(); 
	my $agent = shift() || 'null';
	return 'X-SMTP-Agent: '.$agent.qq(\n);
}

sub xsmtpcommand
{ 
	# +-+-+-+-+-+-+-+-+-+-+-+-+
	# |x|s|m|t|p|c|o|m|m|a|n|d|
	# +-+-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Return pseudo-header for SMTP Command
	# @Param <str>	(String) SMTP command name
	# @Returns	(String) Pseudo-header
	my $class = shift(); 
	my $smtpc = shift() || 'CONN';
	return 'X-SMTP-Command: '.$smtpc.qq(\n);
}

sub xsmtpdiagnosis
{ 
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	# |x|s|m|t|p|d|i|a|g|n|o|s|i|s|
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Return pseudo-header for Diagnostic-Code
	# @Param <str>	(String) Diagnosis message
	# @Returns	(String) Pseudo-header
	my $class = shift(); 
	my $xdiag = shift() || return q();
	return 'X-SMTP-Diagnosis: '.$xdiag.qq(\n);
}

sub xsmtpstatus
{
	# +-+-+-+-+-+-+-+-+-+-+-+
	# |x|s|m|t|p|s|t|a|t|u|s|
	# +-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Return pseudo-header for SMTP Status
	# @Param <str>	(String) SMTP Status(D.S.N.)
	# @Returns	(String) Pseudo-header
	my $class = shift(); 
	my $dstat = shift() || return q();
	return 'X-SMTP-Status: '.$dstat.qq(\n);
}

1;
__END__
