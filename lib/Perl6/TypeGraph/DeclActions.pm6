

unit class Perl6::TypeGraph::DeclActions;

has $.packagetype is rw;
has $.type is rw;
has @.super is rw;
has @.role is rw;

method longname($/) { # Name::Of::The::Type
    $!type //= $/.Str;
}

method inherits($/) { # is Something
    @!super.append: $/<longname>.Str;
}

method roles($/) { # does Something
    @!role.append: $/<longname>.Str;
}

method package($/) { 
    $!packagetype = $/.Str;
}
