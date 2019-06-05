use v6.c;

DOC INIT

=begin pod

=head1 NAME

Pod::Load - Parse a file and returns a type graph.

=head1 SYNOPSIS

    use Perl6::TypeGraph;

    # create and initialize it
    my $tg = Perl6::TypeGraph.new-from-file("./resources/type-graph.txt");

    # and use it!
    say $tg.sorted;

=head1 DESCRIPTION

Perl6::Typegraph creates a graph of all types in a file. It gives you info
about what classes a type inherits from and the roles it does. In addition, 
it also computes the inversion of this relations, which let you know what 
types inherit a given type and the types implementing a specific role.

=head1 FILE SYNTAX

    [ Category ]
    # only one-line comments are supported
    packagetype typename[role-signature]
    packagetype typename[role-signature] is typename[role-signature] # inheritance
    packagetype typename[role-signature] does typename[role-signature] # roles

    [ Another cateogory ]

=item Supported categories: C<Metamodel>, C<Domain-specific>, C<Basic>, C<Composite>, 
C<Exceptions> and C<Core>.
=item Supported packagetypes: C<class>, C<module>, C<role> and C<enum>.
=item Supported typenames: whatever string following the syntax C<class1::class2::class3 ...>.
=item C<[role-signature]> is not processed, but you can add it anyway.
=item If your type inherits from more than one type or implements several roles, you can 
add more C<is> and C<does> statements (separated by spaces).

Example:

    [Metamodel]
    # Metamodel
    class Metamodel::Archetypes
    role  Metamodel::AttributeContainer
    class Metamodel::GenericHOW       does Metamodel::Naming
    class Metamodel::MethodDispatcher is Metamodel::BaseDispatcher is Another::Something
    enum  Bool                          is Int
    module Test

=head1 AUTHOR

Moritz <@moritz>
Antonio Gámiz <@antoniogamiz>

=head1 COPYRIGHT AND LICENSE

This module has been spinned off from the Official Doc repo, if you want to see the past changes go
to the L<official doc|https://github.com/perl6/doc>.

Copyright 2019 Moritz and Antonio
This library is free software; you can redistribute it and/or modify
it under the Artistic License 2.0. 

=end pod

class Perl6::Type {
    #| Name of the type.
    has Str $.name handles <Str>;
    #| All the classes of the type.
    has @.super;
    #| All classes inheriting from this type.
    has @.sub;
    #| All roles implemented by the type.
    has @.roles;
    #| If it's a role, all types implementing it.
    has @.doers;
    #| One of C<class>, C<role>, C<module> or C<enum>.
    has $.packagetype is rw = 'class';
    #| One of C<Metamodel>, C<Domain-specific>, C<Basic>, C<Composite>, C<Exceptions> or C<Core>.
    has @.categories;
    #| Method Resolution Order (MRO) of the type.
    has @.mro;

    #| Computes the MRO and store it in @.mro.
    method mro(Perl6::Type:D:) {
        return @!mro if @!mro;
        if @.super == 1 {
            @!mro = @.super[0].mro;
        } elsif @.super > 1 {
            my @merge_list = @.super.map: *.mro.item;
            @!mro = self.c3_merge(@merge_list);
        }

        @!mro.unshift: self;
        @!mro;
    }

    #| C3 linearization algorithm (L<more info|https://en.wikipedia.org/wiki/C3_linearization>).
    method c3_merge(@merge_list) {
        my @result;
        my $accepted;
        my $something_accepted = 0;
        my $cand_count = 0;
        for @merge_list -> @cand_list {
            next unless @cand_list;
            my $rejected = 0;
            my $cand_class = @cand_list[0];
            $cand_count++;
            for @merge_list {
                next if $_ === @cand_list;
                for 1..+$_ -> $cur_pos {
                    if $_[$cur_pos] === $cand_class {
                        $rejected = 1;
                        last;
                    }
                }
            }
            unless $rejected {
                $accepted = $cand_class;
                $something_accepted = 1;
                last;
            }
        }
        return () unless $cand_count;
        unless $something_accepted {
            die("Could not build C3 linearization for {self}: ambiguous hierarchy");
        }
        for @merge_list.keys -> $i {
            @merge_list[$i] = [@merge_list[$i].grep: { $_ ne $accepted }] ;
        }
        @result = self.c3_merge(@merge_list);
        @result.unshift: $accepted;
        @result;
    }
}

# vim: expandtab shiftwidth=4 ft=perl6
