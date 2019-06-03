use Perl6::Type;
use Perl6::TypeGraph::Decl;

unit class Perl6::TypeGraph;

has %.types;  # format: $name => Perl6::Type
has @.sorted; # array of names (Str)


# constructor
method new-from-file($fn) {
    my $n = self.bless;
    $n.parse-from-file($fn);
    $n;
}

method parse-from-file($fn) {
    my $f = open $fn;
    %!types{"Any"} = Perl6::Type.new(:name("Any"));
    my $get-type = -> Str $name {
        %!types{$name} //= Perl6::Type.new(:$name);
    };
    my class Actions {
        method longname($/) { # Name::Of::The::Type
            make $get-type($/.Str);
        }
        method inherits($/) { # is Something
            $*CURRENT_TYPE.super.append: $<longname>.ast;
        }
        method roles($/) { # does Something
            $*CURRENT_TYPE.roles.append: $<longname>.ast;
        }

    }

    my @categories;
    for $f.lines -> $l {
        # ignore comments
        next if $l ~~ / ^ '#' /;

        # ignore empty lines
        if $l ~~ / ^ \s* $ / {
            @categories = Empty;
            next;
        }

        # new [category] 
        if $l ~~ / :s ^ '[' (\S+) + ']' $/ {
            @categories = @0>>.lc;
            next;
        }

        # normal line
        my $m = Perl6::TypeGraph::Decl.parse($l, :actions(Actions.new));
        my $t = $m<type>.ast;
        $t.packagetype = ~$m<package>; # class module role or enum
        $t.categories = @categories;
    }
    for %!types.values -> $t {
        # roles that have a superclass actually apply that superclass
        # to the class that does them, so mimic that here, including
        # parent roles
        my @roles = $t.roles;
        while @roles {
            my $r = @roles.shift;
            $t.super.append: $r.super if $r.super;
            @roles.append: $r.roles if $r.roles;
        }

        # non-roles default to superclass Any
        if $t.packagetype ne 'role' && !$t.super && $t ne 'Mu' {
            $t.super.append: $get-type('Any');
        }
    }

    # this for loop initializes sub and doers attributes 
    # of every Perl6::Type object in %.types in order to
    # cache the inversion of all type relationships
    for %!types.values -> $t {
        $_.sub.append($t)   for $t.super;
        $_.doers.append($t) for $t.roles;
    }

    self!topo-sort;
}

# this method takes all Perl6::Type objects in %.types
# and sort them by its name. After that, recursively,
# add all roles and supers in the object to @!sorted by 
# appearance order.
method !topo-sort {
    my %seen;
    sub visit($n) {
        return if %seen{$n};
        %seen{$n} = True;
        visit($_) for flat $n.super, $n.roles;
        @!sorted.append: $n;
    }
    visit($_) for %!types.values.sort(*.name);
}


# vim: expandtab shiftwidth=4 ft=perl6
