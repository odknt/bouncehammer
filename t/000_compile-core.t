# $Id: 000_compile-core.t,v 1.50 2010/12/12 06:19:10 ak Exp $
use strict;
use warnings;
use lib qw(./t/lib ./dist/lib ./src/lib);
use Test::More;

my $Modules = [ qw{
	Kanadzuchi
	Kanadzuchi::Address
	Kanadzuchi::Archive
	Kanadzuchi::Archive::Gzip
	Kanadzuchi::BdDR
	Kanadzuchi::BdDR::BounceLogs
	Kanadzuchi::BdDR::Cache
	Kanadzuchi::BdDR::Page
	Kanadzuchi::BdDR::BounceLogs::Masters
	Kanadzuchi::BdDR::DailyUpdates
	Kanadzuchi::Config::TestRun
	Kanadzuchi::Crypt
	Kanadzuchi::Exceptions
	Kanadzuchi::ISO3166
	Kanadzuchi::Iterator
	Kanadzuchi::Log
	Kanadzuchi::Mail
	Kanadzuchi::Mail::Bounced
	Kanadzuchi::Mail::Bounced::Generic
	Kanadzuchi::Mail::Bounced::Yahoo
	Kanadzuchi::Mail::Group
	Kanadzuchi::Mail::Group::AU::WebMail
	Kanadzuchi::Mail::Group::BR::WebMail
	Kanadzuchi::Mail::Group::CA::WebMail
	Kanadzuchi::Mail::Group::CN::WebMail
	Kanadzuchi::Mail::Group::CZ::WebMail
	Kanadzuchi::Mail::Group::DE::WebMail
	Kanadzuchi::Mail::Group::EG::WebMail
	Kanadzuchi::Mail::Group::IN::WebMail
	Kanadzuchi::Mail::Group::IL::WebMail
	Kanadzuchi::Mail::Group::IR::WebMail
	Kanadzuchi::Mail::Group::JP::Cellphone
	Kanadzuchi::Mail::Group::JP::Smartphone
	Kanadzuchi::Mail::Group::JP::WebMail
	Kanadzuchi::Mail::Group::KR::WebMail
	Kanadzuchi::Mail::Group::LV::WebMail
	Kanadzuchi::Mail::Group::NO::WebMail
	Kanadzuchi::Mail::Group::NZ::WebMail
	Kanadzuchi::Mail::Group::RU::WebMail
	Kanadzuchi::Mail::Group::SG::WebMail
	Kanadzuchi::Mail::Group::TW::WebMail
	Kanadzuchi::Mail::Group::UK::Smartphone
	Kanadzuchi::Mail::Group::UK::WebMail
	Kanadzuchi::Mail::Group::US::WebMail
	Kanadzuchi::Mail::Group::ZA::WebMail
	Kanadzuchi::Mail::Group::Neighbor
	Kanadzuchi::Mail::Group::WebMail
	Kanadzuchi::Mail::Stored
	Kanadzuchi::Mail::Stored::BdDR
	Kanadzuchi::Mail::Stored::YAML
	Kanadzuchi::Mail::Why
	Kanadzuchi::Mail::Why::ContentError
	Kanadzuchi::Mail::Why::ExceedLimit
	Kanadzuchi::Mail::Why::Filtered
	Kanadzuchi::Mail::Why::HostUnknown
	Kanadzuchi::Mail::Why::MailboxFull
	Kanadzuchi::Mail::Why::MailerError
	Kanadzuchi::Mail::Why::MesgTooBig
	Kanadzuchi::Mail::Why::NotAccept
	Kanadzuchi::Mail::Why::Rejected
	Kanadzuchi::Mail::Why::RelayingDenied
	Kanadzuchi::Mail::Why::SecurityError
	Kanadzuchi::Mail::Why::SystemError
	Kanadzuchi::Mail::Why::SystemFull
	Kanadzuchi::Mail::Why::UserUnknown
	Kanadzuchi::Mbox
	Kanadzuchi::MDA
	Kanadzuchi::MIME::Parser
	Kanadzuchi::Metadata
	Kanadzuchi::MTA
	Kanadzuchi::MTA::Courier
	Kanadzuchi::MTA::Exim
	Kanadzuchi::MTA::Fallback
	Kanadzuchi::MTA::Postfix
	Kanadzuchi::MTA::qmail
	Kanadzuchi::MTA::Sendmail
	Kanadzuchi::RFC2606
	Kanadzuchi::RFC2822
	Kanadzuchi::RFC3463
	Kanadzuchi::Statistics
	Kanadzuchi::Statistics::Stored
	Kanadzuchi::Statistics::Stored::BdDR
	Kanadzuchi::Statistics::Stored::YAML
	Kanadzuchi::String
	Kanadzuchi::Time
	Kanadzuchi::UI
	Kanadzuchi::UI::CLI
} ];

my $Optionals = [ qw{
	Kanadzuchi::Archive::Bzip2
	Kanadzuchi::Archive::Zip
	Kanadzuchi::MTA::JP::aubyKDDI
	Kanadzuchi::MTA::US::Google
} ];

plan( tests => scalar(@$Modules) + scalar(@$Optionals) );
foreach my $module ( @$Modules ){ use_ok($module); }
foreach my $optmod ( @$Optionals )
{ 
	my $path = $optmod; $path =~ y{::}{/}; $path =~ s{\z}{.pm};
	my $dist = -d './dist/lib' ? './dist/lib' : './src/lib';
	ok( -f $dist.'/'.$path );
}

__END__
