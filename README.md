[![Build Status](https://travis-ci.org/antoniogamiz/Perl6-TypeGraph.svg?branch=master)](https://travis-ci.org/antoniogamiz/Perl6-TypeGraph)

# NAME

Pod::Load - Parse a file and returns a type graph.

# SYNOPSIS

    use Perl6::TypeGraph;

    # create and initialize it
    my $tg = Perl6::TypeGraph.new-from-file("./resources/type-graph.txt");

    # and use it!
    say $tg.sorted;

# DESCRIPTION

Perl6::Typegraph creates a graph of all types in a file. It gives you info about what classes a type inherits from and the roles it does. In addition, it also computes the inversion of this relations, which let you know what types inherit a given type and the types implementing a specific role.

All types are represented using a `Perl6::Type` objec.

# FILE SYNTAX

    [ Category ]
    # only one-line comments are supported
    packagetype typename[role-signature]
    packagetype typename[role-signature] is typename[role-signature] # inheritance
    packagetype typename[role-signature] does typename[role-signature] # roles

    [ Another cateogory ]

- Supported categories: `Metamodel`, `Domain-specific`, `Basic`, `Composite`, `Exceptions` and `Core`.

- Supported packagetypes: `class`, `module`, `role` and `enum`.

- Supported typenames: whatever string following the syntax `class1::class2::class3 ...`.

- `[role-signature]` is not processed, but you can add it anyway.

- If your type inherits from more than one type or implements several roles, you can add more `is` and `does` statements (separated by spaces).

Example:

    [Metamodel]
    # Metamodel
    class Metamodel::Archetypes
    role  Metamodel::AttributeContainer
    class Metamodel::GenericHOW       does Metamodel::Naming
    class Metamodel::MethodDispatcher is Metamodel::BaseDispatcher is Another::Something
    enum  Bool                          is Int
    module Test

# AUTHOR

Moritz <@moritz> Antonio Gámiz <@antoniogamiz>

# COPYRIGHT AND LICENSE

This module has been spinned off from the Official Doc repo, if you want to see the past changes go to the [official doc](https://github.com/perl6/doc).

Copyright 2019 Moritz and Antonio This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

### has Associative %.types

Format: \$name => Perl6::Type.

### has Positional @.sorted

Sorted array of type names.

### method new-from-file

```perl6
method new-from-file(
    $fn
) returns Mu
```

Initialize %.types from a file.

### method parse-from-file

```perl6
method parse-from-file(
    $fn
) returns Mu
```

Parse the file (using the Decl grammar) and initialize %.types and @.sorted

### method topo-sort

```perl6
method topo-sort() returns Mu
```

This method takes all Perl6::Type objects in %.types and sort them by its name. After that, recursively, add all roles and supers in the object to @!sorted
