use Test;
use Perl6::TypeGraph;

plan 1;

my $tg = Perl6::TypeGraph.new-from-file;
ok $tg.gist, "TypeGraph can be printed";

done-testing;
