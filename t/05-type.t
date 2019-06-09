use v6;
use Test;

use Perl6::Type;

plan *;

#    A
#  /   \
# B     C
# | \ / |   
# | / \ |
# D     E
#   \ /
#    F

my $A = Perl6::Type.new(:name("A"));
   $A.super = [];

my $B = Perl6::Type.new(:name("B"));
   $B.super = [$A];
my $C = Perl6::Type.new(:name("C"));
   $C.super = [$A];

my $D = Perl6::Type.new(:name("D"));
   $D.super = [$B, $C];
my $E = Perl6::Type.new(:name("E"));
   $E.super = [$B, $C];

my $F = Perl6::Type.new(:name("F"));
   $F.super = [$D, $E];

subtest {
    is $A.mro».name, ["A"]                         , "No inheritance";
    is $B.mro».name, ["B", "A"]                    , "Single inheritance";
    is $C.mro».name, ["C", "A"]                    , "Single inheritance 2";
    is $D.mro».name, ["D", "B", "C", "A"]          , "Double inheritance";
    is $E.mro».name, ["E", "B", "C", "A"]          , "Double inheritance 2";
    is $F.mro».name, ["F", "D", "E", "B", "C", "A"], "All in one";
}, "Mro and c3 merge algorithm";

done-testing;
