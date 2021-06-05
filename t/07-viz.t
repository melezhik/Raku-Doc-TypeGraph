#!/usr/bin/env perl6
use Test;
use Perl6::TypeGraph;
use Perl6::TypeGraph::Viz;

constant $test-graph = 'type-graph-Any.svg';

my $tg = Perl6::TypeGraph.new-from-file('test-type-graph.txt');

sub testing-roundtrip($viz, $desc, *@checks) {
    my $path = $*TMPDIR.add('viz-test-dir');
    mkdir $path;
    $viz.write-type-graph-images(:$path, :force, type-graph => $tg);

    ok $path.add($test-graph).e, "SVG was created by write-type-graph-images";
    ok $path.add("$test-graph.dot").e, "dot files are present";

    my $viz-output = $path.add("$test-graph.dot").slurp;
    subtest {
        for @checks.kv -> $i, $check {
            ok $check($viz-output), "Check {$i + 1}";
        }
    }, $desc;

    unlink $_ for dir $path;
    rmdir $path;
}

# Default colors
my $viz = Perl6::TypeGraph::Viz.new;
testing-roundtrip($viz, "Default coloring",
        *.contains('graph [truecolor=true bgcolor="#FFFFFF"]'),
        *.contains('"Proc" -> "Any" [color="#000000"];'),
        *.contains('"Setty" [color="#6666FF", fontcolor="#6666FF", href="/type/Setty", fontname="FreeSans"];'),
        *.contains('"Signal" [color="#33BB33", fontcolor="#33BB33", href="/type/Signal", fontname="FreeSans"];'));

# Custom colors
$viz = Perl6::TypeGraph::Viz.new(class-color => '#030303', role-color => '#5503B3', enum-color => '#A30031',
        bg-color => '#fafafa', node-style => 'filled margin=0.2 fillcolor="#f2f2f2" shape=rectangle fontsize=16');
testing-roundtrip($viz, "Custom coloring",
        *.contains('graph [truecolor=true bgcolor="#fafafa"]'),
        *.contains('node [style=filled margin=0.2 fillcolor="#f2f2f2" shape=rectangle fontsize=16]'),
        *.contains('"Proc" -> "Any" [color="#030303"];'),
        *.contains('"Setty" [color="#5503B3", fontcolor="#5503B3", href="/type/Setty", fontname="FreeSans"];'),
        *.contains('"Signal" [color="#A30031", fontcolor="#A30031", href="/type/Signal", fontname="FreeSans"];'));

done-testing;
