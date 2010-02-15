# Perl RDF experiments from Biohackathon 2010 (and beyond)

In February 2010, a bunch of fellow bioinformatics/semantic web geeks
came together in Tokyo for the
[third Biohackathon](http://hackathon3.dbcls.jp/wiki) to hack on all
things RDF, SPARQL & co for bioinformatics.

This repository is meant to be a simple starting point to collect code
and documents for the Perl people at the Biohackathon, and to keep
working on exploring and improving the use of Perl for semantic web
stuff after hackathon.

There is a website and mailing list dedicated to RDF support in Perl:
http://www.perlrdf.org. It lists the available modules.


# Notes

## Existing modules

Also see http://www.perlrdf.org!


### RDF::Trine

[RDF::Trine](http://search.cpan.org/~gwilliams/RDF-Trine-0.117/) is a
complete RDF package written in Perl. It is the only one that has
parsers for RDF serializations other than RDF/XML (including JSON),
and that has a SPARQL wrapper. It implements the
[SPARQL protocol](http://www.w3.org/TR/2008/REC-rdf-sparql-protocol-20080115/#query-bindings-http)
and can thus talk to any SPARQL endpoint.

Last release: 0.117, 2010-02-04.

I (Thomas Kappler) am in touch with the author, Gregory Williams, and
it's a pleasure to work with him. Here's some of his advice that I
intend to include in some more in-depth, step-by-step writeups.

> In general you should be using RDF::Query for retrieving patterns
> that are more complex than a single triple pattern. get_pattern
> exists mostly for RDF::Query to use when the underlying store is
> expected to be able to execute a complex join query more efficiently
> than the perl implementation (for example, the DBI-based storage
> backend). It's never been a part of the code that has felt very
> stable, so I'd suggest always using the RDF::Query interface for
> situations where get_statements doesn't do as much as you need.


See the `trine-*.pl` files for code snippets.


### RDF::Redland

[RDF::Redland](http://search.cpan.org/~djbeckett/Redland-1.0.5.4/redland/docs/redland.pod)
is a wrapper for the [Redland C library](http://librdf.org/). Looks
pretty complete.

I couldn't build it as I have the new version 0.9.17 of librasqal, the
query library for Redland, which is API incompatible with its
predecessor on which RDF::Redland apparently depends.


### Test::RDF

[Test::RDF](http://search.cpan.org/~mndrix/Test-RDF-0.0.3/lib/Test/RDF.pm)
supports checking for data validity, and comparing two graphs for
equivalence. It does not explain the differences when they are not
equal, however. Builds on RDF::Redland.


### RDF::Core

Another pure Perl RDF
framework. [CPAN](http://search.cpan.org/~dpokorny/RDF-Core/). Last
release: 0.51, 2007-02-19, which probably means that it's not very
much used or supported. Use RDF::Trine unless you have a good reason
not to.

## Notes 

- A pretty complete RDF package written in Perl, including parser and
  serializer, model with its own query language, and storage with
  either Berkeley DB, in-memory, or PostgreSQL as backend.
- It's unfortunate that it has its own query language, should be
  SPARQL.
- RDF/XML serialization and parsing only.
- Has a Schema module to work with RDFS, didn't try it.
- Greg Williams of RDF::Trine, the other, more complete and up-to-date
  RDF framework, tried to contribute to RDF::Core but was
  "[met with resistance, rejection, or frustratingly long delays](http://kasei.us/archives/2006/09/23/perl_performance)". Not
  good.
  

### Onto-Perl

[ONTO-PERL](http://search.cpan.org/~easr/ONTO-PERL-1.14/) by fellow
Biohackathoner Erick Antezana can translate between OBO, OBO-in-OWL,
and RDF (among other things).


### Wrappers

- [RDF-Sesame](http://search.cpan.org/~mndrix/RDF-Sesame-0.17/lib/RDF/Sesame.pm)
  is a wrapper for the REST API of [Sesame](http://openrdf.org/), to
  ask [SerQL](http://www.openrdf.org/doc/sesame/users/ch06.html)
  queries and get the results in tabular form.

- [MOBY](http://search.cpan.org/~ekawas/MOBY-1.12/), a BioMoby client,
  has MOBY::RDF.
