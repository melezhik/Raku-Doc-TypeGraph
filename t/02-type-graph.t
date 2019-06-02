use v6;
use Test;

use Perl6::TypeGraph;

plan *;

my @categories = ["basic", "composite", "core", "domain-specific", "exceptions", "metamodel"];
my @packages = ["class", "enum", "module", "role"]; 
my @types = ["Any", "Attribute", "Bool", "C", "C::A", "C::B", "C::C", "R", "R::A", "R::B", "R::C", "Seq", "Test"];

my $tg = Perl6::TypeGraph.new-from-file("./resources/test-type-graph.txt");

{ # supported values
    is $tg.types.values».categories.flat.unique.sort, 
    @categories,
    "All supported categories detected";

    is $tg.types.values».packagetype.flat.unique.sort, 
    @packages,
    "All supported packagetypes detected";

    is $tg.types.values.sort,
    @types,
    "All types detected";
}

say $tg.types.keys;

{ # inhteritance
    is $tg.types<C>.super[0].name, "Any";
}



done-testing;