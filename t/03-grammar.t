use v6;
use Test;

use Perl6::TypeGraph::Decl;
use Perl6::TypeGraph::DeclActions;

plan *;

my $g;

is parse("# module Test"), Any, "Comments";
is parse("             "), Any, "Empty lines";

subtest {
    is parse("class Test" ).packagetype, "class" , "class package detected";
    is parse("module Test").packagetype, "module", "module package detected";
    is parse("role Test"  ).packagetype, "role"  , "role package detected";
    is parse("enum Test"  ).packagetype, "enum"  , "enum package detected";
}, "Test package types";

subtest {
    is parse("class A").type      , "A"   , "Type name detected";
    is parse("class A[T::U]").type, "A"   , "Type name detected (and signatured ignored)";
    is parse("class A::B").type   , "A::B", "Type name with :: detected";
}, "Test type parsing";

subtest {
    is parse("class A does B").role            , ["B"]     , "Single role detected";
    is parse("class A does B does C").role.sort, ["B", "C"], "Multiple roles detected";
}, "Test role parsing";

subtest {
    is parse("class A is B").super          , ["B"]     , "Single super detected";
    is parse("class A is B is C").super.sort, ["B", "C"], "Multiple supers detected";
}, "Test inheritance parsing";

done-testing;

sub parse( $str ) {
    $g = Perl6::TypeGraph::Decl.parse($str, :actions(Perl6::TypeGraph::DeclActions.new)).actions;
}
