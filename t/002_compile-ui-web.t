use strict;
use warnings;
use lib qw(./t/lib ./dist/lib ./src/lib);
use Test::More;

my $Modules = [
	q(Kanadzuchi::UI::Web),
	q(Kanadzuchi::UI::Web::Token),
	q(Kanadzuchi::UI::Web::Index),
	q(Kanadzuchi::UI::Web::MasterTables),
	q(Kanadzuchi::UI::Web::Profile),
	q(Kanadzuchi::UI::Web::Search),
	q(Kanadzuchi::UI::Web::Summary),
	q(Kanadzuchi::UI::Web::Test),
	q(Kanadzuchi::UI::Web::Update),
	q(Kanadzuchi::UI::Web::Dispatch),
];

plan( tests => $#{$Modules} + 1 );
foreach my $module ( @$Modules ){ use_ok($module); }

__END__
