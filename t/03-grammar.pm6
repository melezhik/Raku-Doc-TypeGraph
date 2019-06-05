use v6;
use Test;

use Perl6::TypeGraph::Decl;
use Perl6::TypeGraph::DeclActions;

plan *;

my $g;

$g = Perl6::TypeGraph::Decl.parse("# module Test", :actions(Perl6::TypeGraph::DeclActions.new)).actions;
{ # comments
    is Any, Any, "Comments";
}

$g = Perl6::TypeGraph::Decl.parse("   ", :actions(Perl6::TypeGraph::DeclActions.new)).actions;
{ # empty lines
    is Any, Any, "Empty lines";
}

{ # supported packages
    $g = Perl6::TypeGraph::Decl.parse("class Test", :actions(Perl6::TypeGraph::DeclActions.new)).actions;
    is $g.packagetype, "class", " class package detected";
    $g = Perl6::TypeGraph::Decl.parse("module Test", :actions(Perl6::TypeGraph::DeclActions.new)).actions;
    is $g.packagetype, "module", "module package detected";
    $g = Perl6::TypeGraph::Decl.parse("role Test", :actions(Perl6::TypeGraph::DeclActions.new)).actions;
    is $g.packagetype, "role", "role package detected";
    $g = Perl6::TypeGraph::Decl.parse("enum Test", :actions(Perl6::TypeGraph::DeclActions.new)).actions;
    is $g.packagetype, "enum", "enum package detected";
}

{ # typename with and without signature
    $g = Perl6::TypeGraph::Decl.parse("class A[T::U]", :actions(Perl6::TypeGraph::DeclActions.new)).actions;
    is $g.type, "A", "Type name detected";
    $g = Perl6::TypeGraph::Decl.parse("class A[T::U]", :actions(Perl6::TypeGraph::DeclActions.new)).actions;
    is $g.type, "A", "Type name detected (and signatured ignored)";
    $g = Perl6::TypeGraph::Decl.parse("class A::B", :actions(Perl6::TypeGraph::DeclActions.new)).actions;
    is $g.type, "A::B", "Type name with :: detected";
}

{ # roles
    $g = Perl6::TypeGraph::Decl.parse("class A does B", :actions(Perl6::TypeGraph::DeclActions.new)).actions;
    is $g.role, ["B"], "Single role detected";
    $g = Perl6::TypeGraph::Decl.parse("class A does B does C", :actions(Perl6::TypeGraph::DeclActions.new)).actions;
    is $g.role.sort, ["B", "C"], "Multiple roles detected";
}

{ # inheritance
    $g = Perl6::TypeGraph::Decl.parse("class A is B", :actions(Perl6::TypeGraph::DeclActions.new)).actions;
    is $g.super, ["B"], "Single super detected";
    $g = Perl6::TypeGraph::Decl.parse("class A is B is C", :actions(Perl6::TypeGraph::DeclActions.new)).actions;
    is $g.super.sort, ["B", "C"], "Multiple supers detected";
}

done-testing;