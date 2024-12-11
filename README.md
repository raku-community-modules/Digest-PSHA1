[![Actions Status](https://github.com/raku-community-modules/Digest-PSHA1/actions/workflows/linux.yml/badge.svg)](https://github.com/raku-community-modules/Digest-PSHA1/actions) [![Actions Status](https://github.com/raku-community-modules/Digest-PSHA1/actions/workflows/macos.yml/badge.svg)](https://github.com/raku-community-modules/Digest-PSHA1/actions) [![Actions Status](https://github.com/raku-community-modules/Digest-PSHA1/actions/workflows/windows.yml/badge.svg)](https://github.com/raku-community-modules/Digest-PSHA1/actions)

NAME
====

Digest::PSHA1 - Pseudorandom hashing algorithm as per RFC5246

SYNOPSIS
========

```raku
use Digest::PSHA1;
```

DESCRIPTION
===========

Calculates Pseudorandom SHA1 as defined in http://tools.ietf.org/html/rfc5246 (5. HMAC and the Pseudorandom Function)

This algorithm is used for signing XML documents when the RequestedProofToken is either http://docs.oasis-open.org/ws-sx/ws-trust/200512/CK/PSHA1 or http://schemas.xmlsoap.org/ws/2005/02/trust/CK/PSHA1.

Thanks to Leandro Boffi (http://leandrob.com/) for the nodejs version and a great blog.

USAGE
=====

```raku
use Digest::PSHA1;
use MIME::Base64;

# Extract base64'd binary secret of a RequestSecurityToken request and a
# RequestSecurityTokenResponse, like from such a structure:
# <Entropy>
#     <BinarySecret Type="http://schemas.xmlsoap.org/ws/2005/02/trust/Nonce">
#         grrlUUfhuNwlvQzQ4bV6TT3wA8ieZPltIf4+H7nIvCE=
#     </BinarySecret>
# </Entropy>

# Obtain the decoded versions
my $client-secret = MIME::Base64.decode-str($client-binary-secret);
my $server-secret = MIME::Base64.decode-str($server-binary-secret);

# Build the key to sign an XML document
my $key     = psha1($client-secret, $server-secret);
my $key-b64 = MIME::Base64.encode($key, :oneline);
#  ^--- you usually do not need the Base64 version of the key

# To actually use this key to sign a document, do something like this
use Digest::HMAC;
use Digest;

my $canonicalized-data  = '<SignedInfo xmlns="...">...</SignedInfo>';
#  ^--- use the correct c14n version according to your XML document
my $signature-value     = hmac($key, $canonicalized-data, &sha1);
my $signature-value-b64 = MIME::Base64.encode($signature-value, :oneline);
#  ^--- this is what you would add to your XML document
```

FUNCTIONS
=========

psha1-hex
---------

```raku
sub psha1-hex($secret, $seed, $blocksize = 256 --> Str:D)
```

Returns the hex stringified output of psha1. `$secret` and `$seed` can either be `Str` or `Blob` objects; if they are `Str` they will be encoded as ascii.

psha1-hex
---------

```raku
sub psha1($secret, $seed, $blocksize = 256 --> Buf:D)
```

Computes the PSHA1 of the passed information. `$secret` and `$seed` can either be `Str` or `Blob` objects; if they are `Str` they will be encoded as ascii.

AUTHOR
======

Tobias Leich (FROGGS)

Source can be located at: https://github.com/raku-community-modules/Digest-PSHA1 . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2014-2017 Tobias Leich

Copyright 2023, 2024 Raku Community

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

