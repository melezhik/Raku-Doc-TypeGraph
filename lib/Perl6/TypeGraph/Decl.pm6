
unit grammar Perl6::TypeGraph::Decl;

token ident      { <.alpha> \w*                         }
token apostrophe { <[ ' \- ]>                           }
token identifier { <.ident> [ <.apostrophe> <.ident> ]* }
token longname   { <identifier>+ % '::'                 }
token package    { class | module | role | enum         }
token rolesig    { '[' <-[ \[\] ]>* ']'                 } 
rule  inherits   { 'is' <longname>                      }
rule  roles      { 'does' <longname><rolesig>?          }

rule TOP {
    ^
    <package>
    <type=longname><rolesig>?
    :my $*CURRENT_TYPE;
    { $*CURRENT_TYPE = $<type>.ast }
    [ <inherits> | <roles> ]*
    $
}

