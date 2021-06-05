#!/usr/bin/env Doc

use v6;
use Test;
use lib 'lib';
use Doc::TypeGraph;

plan 8;

my $original-tg-file = "resources/data/type-graph.txt"??"resources/data/type-graph.txt"!!"../resources/data/type-graph.txt";
my $t = Doc::TypeGraph.new-from-file($original-tg-file);
ok $t, 'Could parse the file';
ok $t.types<Array>, 'has type Array';
ok $t.types<Array>.super.any eq 'List',
    'Array has List as a superclass';
ok $t.types<List>.roles.any eq 'Positional',
    'List does positional';
is $t.types<Str>.mro, 'Str Cool Any Mu', 'Str mro';
is $t.types<Match>.mro, 'Match Capture Cool Any Mu', 'Match mro';
is $t.types<Exception>.super.any, 'Any', 'Any as default parent works';
is $t.types<Any>.super, 'Mu', 'default-Any did not add a parent to Any';