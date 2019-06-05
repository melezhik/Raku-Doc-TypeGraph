[![Build Status](https://travis-ci.org/antoniogamiz/Perl6-TypeGraph.svg?branch=master)](https://travis-ci.org/antoniogamiz/Perl6-TypeGraph)

# NAME

Perl6::TypeGraph - Generates a TypeGraph of Perl6 Types from a file.

# SYNOPSIS

```perl6
use Perl6::TypeGraph;

# create and initialize it
my $tg = Perl6::TypeGraph.new-from-file("./resources/type-graph.txt");

# and use it!
say $tg.sorted;

```

# DESCRIPTION

Perl6::TypeGraph - Generates a TypeGraph of Perl6 Types from a file.

### File syntax

```

[ Category ]
# only one-line comments are supported
packagetype typename[role-signature]
packagetype typename[role-signature] is typename[role-signature] # inheritance
packagetype typename[role-signature] does typename[role-signature] # roles

[ Another cateogory ]
...
```

- Supported categories: `Metamodel`, `Domain-specific`, `Basic`, `Composite`, `Exceptions` and `Core`.
- Supported packagetypes: `class`, `module`, `role` and `enum`.
- Supported typenames: whatever string following the syntax `class1::class2::class3 ...`.
- `[role-signature]` is not processed, but you can add it anyway.
- If your type inherits from more than one type or implements several roles, you can add more `is`
- and `does` statements (separated by spaces).

Example:

```
[Metamodel]
# Metamodel
class Metamodel::Archetypes
role  Metamodel::AttributeContainer
class Metamodel::GenericHOW       does Metamodel::Naming
class Metamodel::MethodDispatcher is Metamodel::BaseDispatcher is Another::Something
enum  Bool                          is Int
module Test
```

This file is parsed with the `Perl6::TypeGraph::Decl` grammar.

## Perl6::Type

All types found are represented with a `Perl6::Type` object.

#### has Str \$.name

Name of the type. Example: `Metamodel::Documenting`.

#### has @.super

All the super classes of the type.

#### has @.roles

All roles implemented by the type.

#### has @.sub

All types inheriting this type.

#### has @.doers

If it's a role, all types implementing it.

#### has Str \$.packagetype

`class`, `role`, `module` or `enum`.

#### has @.categories

`Metamodel`, `Domain-specific`, `Basic`, `Composite`, `Exceptions` or `Core`.

#### has @.mro

Method Resolution Orden (MRO) of the type.

#### method mro

```perl6
method mro (
    Perl6::Type:D:
) return Array
```

Computes the MRO of type and store it in `@.mro`.

#### method c3_merge

```perl6
method c3_merge (
    @merge_list
) return Array
```

C3 linearization algorithm ([more info](https://en.wikipedia.org/wiki/C3_linearization)).

## Perl6::TypeGraph

### has %.types

Hash of `Perl6::Type` objects. They key is the class/role name. This hash
can be initialized by calling `new-from-file` or `parse-from-file`.

### has @.sorted

List of all classes and roles found, sorted using `topo-sort`.

Example: `@.sorted = [Any, Metamodel, Mu, X::Control ]`

#### method new-from-file

```perl6
method new-from-file(
    Str $fn
) returns Perl6::TypeGraph
```

Creates a new instance of `Perl6::TypeGraph` and calls
`parse-from-file`.

#### method parse-from-file

```perl6
method parse-from-file(
    Str $fn
) returns Any
```

Use a internal grammar (`Decl`) to parse the content of `$fn` line by
line. The format that the file must follow is specified above.

#### method !topo-sort

```perl6
method !topo-sort () returns Any
```

Iterates every type in `%.types` (after sort them by name). It makes the same
with all elements in `.super` and `.roles` recursively.

# AUTHOR

Moritz Lent <@moritz>
Antonio <antoniogamiz10@gmail.com>

# COPYRIGHT AND LICENSE

This module has been spinned off from the Official Doc repo, if you want to see the past changes go
[here](https://github.com/perl6/doc).

Copyright 2019 Moritz, Antonio

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.
