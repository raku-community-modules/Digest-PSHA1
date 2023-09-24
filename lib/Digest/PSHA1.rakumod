use Digest::SHA;
use Digest::HMAC;

my sub psha1(
      $clientbytes is copy,
      $serverbytes is copy,
  int $keysize = 256
) is export {
    $clientbytes = $clientbytes.encode('ascii') unless $clientbytes ~~ Blob;
    $serverbytes = $serverbytes.encode('ascii') unless $serverbytes ~~ Blob;

    my int $sizebytes           = $keysize div 8;
    my int $sha1digestsizebytes = 160 div 8; # 160 is the length of sha1 digest

    my Blob $buffer1 = $serverbytes;
    my Blob $buffer2;
    my Buf $pshabuffer = Buf.new;

    my Int $i = 0;
    my Blob $temp;

    while $i < $sizebytes {
        $buffer1 = hmac($clientbytes, $buffer1, &sha1, 64);
        $buffer2 = $buffer1.subbuf(0, $sha1digestsizebytes) ~ $serverbytes;
        $temp    = hmac($clientbytes, $buffer2, &sha1, 64);

        for 0..^$temp.elems -> $x {
            if $i < $sizebytes {
                $pshabuffer[$i] = $temp[$x];
                $i++;
            }
            else {
                last;
            }
        }
    }

    $pshabuffer
}

my sub psha1-hex($clientbytes, $serverbytes, $keysize = 64) is export {
    psha1($clientbytes, $serverbytes, $keysize).list».fmt("%02x").join;
}

=begin pod

=head1 NAME

Digest::PSHA1 - Pseudorandom hashing algorithm as per RFC5246

=head1 SYNOPSIS

=begin code :lang<raku>

use Digest::PSHA1;

=end code

=head1 DESCRIPTION

Calculates Pseudorandom SHA1 as defined in http://tools.ietf.org/html/rfc5246
(5.  HMAC and the Pseudorandom Function)

This algorithm is used for signing XML documents when the RequestedProofToken
is either http://docs.oasis-open.org/ws-sx/ws-trust/200512/CK/PSHA1 or
http://schemas.xmlsoap.org/ws/2005/02/trust/CK/PSHA1.

Thanks to Leandro Boffi (http://leandrob.com/) for the nodejs version and a great blog.

=head1 USAGE

=begin code :lang<raku>

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

=end code

=head1 FUNCTIONS

=head2 psha1-hex

=begin code :lang<raku>

sub psha1-hex($secret, $seed, $blocksize = 256 --> Str:D)

=end code

Returns the hex stringified output of psha1.  C<$secret> and C<$seed> can
either be C<Str> or C<Blob> objects; if they are C<Str> they will be encoded
as ascii.

=head2 psha1-hex

=begin code :lang<raku>

sub psha1($secret, $seed, $blocksize = 256 --> Buf:D)

=end code

Computes the PSHA1 of the passed information.  C<$secret> and C<$seed> can
either be C<Str> or C<Blob> objects; if they are C<Str> they will be encoded
as ascii.

=head1 AUTHOR

Tobias Leich (FROGGS)

Source can be located at: https://github.com/raku-community-modules/Digest-PSHA1 .
Comments and Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2014-2017 Tobias Leich, 2023 Raku Community

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

# vim: expandtab shiftwidth=4
