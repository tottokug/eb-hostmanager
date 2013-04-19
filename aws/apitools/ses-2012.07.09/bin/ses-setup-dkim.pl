#!/usr/bin/perl -w

# Copyright 2010 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"). You may not 
# use this file except in compliance with the License. A copy of the License 
# is located at
#
#        http://aws.amazon.com/apache2.0/
#
# or in the "LICENSE" file accompanying this file. This file is distributed 
# on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either 
# express or implied. See the License for the specific language governing 
# permissions and limitations under the License.

# This is a code sample showing how to use the Amazon Simple Email Service from the
# command line.  To learn more about this code sample, see the AWS Simple Email
# Service Developer Guide. 


use strict;
use warnings;
use Switch;
use Getopt::Long;
use Pod::Usage;
use XML::LibXML;
use SES;


my %opts = ();
my %params = ();


# Parse the command line arguments and place them in the %opts hash.
sub parse_args {
    GetOptions('verbose' => \$opts{'verbose'},
               'e=s'     => \$opts{'e'},
               'k=s'     => \$opts{'k'},
               'v=s'     => \$opts{'v'},
               'i=s'     => \$opts{'i'},
               's=s'     => \$opts{'s'},
               'a=s'     => \$opts{'a'},
               'help'    => \$opts{'h'}) or pod2usage(-exitval => 2);
    pod2usage(-exitstatus => 0, -verbose => 2) if ($opts{'h'});
    $opts{'a'} = SES::parse_list($opts{'a'}, ',') if ($opts{'a'});
    $opts{'s'} = lc $opts{'s'} if ($opts{'s'});
}


# Validate the arguments passed on the command line.
sub validate_opts {
    pod2usage(-exitval => 2) unless (
        (defined($opts{'v'}) && length($opts{'v'})) ^
        (defined($opts{'i'}) && length($opts{'i'}) && defined($opts{'s'}) && length($opts{'s'})) ^
        (defined($opts{'a'}) && length($opts{'a'})));
}


# Prepare the parameters for the service call.
sub prepare_params {
    if ($opts{'v'}) {
        $params{'Domain'}                        = $opts{'v'};
        $params{'Action'}                        = 'VerifyDomainDkim';
    } elsif ($opts{'i'} && $opts{'s'}) {
        $params{'Identity'}                      = $opts{'i'};
        $params{'DkimEnabled'}                   = $opts{'s'};
        $params{'Action'}                        = 'SetIdentityDkimEnabled';
    } elsif ($opts{'a'}) {
        my @opt_a = @{$opts{'a'}};
        for (my $i = 0; $i <= $#opt_a; $i++) {
            $params{'Identities.member.'.($i+1)} = $opt_a[$i];
        }
        $params{'Action'}                        = 'GetIdentityDkimAttributes';
    }
}


# Prints the data returned by the service call.
sub print_response {
    my $response_content = shift;

    my $parser = XML::LibXML->new();
    my $dom = $parser->parse_string($response_content);
    my $xpath = XML::LibXML::XPathContext->new($dom);
    $xpath->registerNs('ns', $SES::aws_email_ns);

    if ($opts{'v'}) {
        my @nodes = $xpath->findnodes('/ns:VerifyDomainDkimResponse' .
                                      '/ns:VerifyDomainDkimResult' .
                                      '/ns:DkimTokens' .
                                      '/ns:member');
        print "DkimToken1,DkimToken2,DkimToken3\n";
        my @tokens = ();
        foreach my $node (@nodes) {
            my $token = $node->textContent();
            push @tokens, $token;
        }
        my $line = join ',', @tokens;
        print "$line\n";
    }

    if ($opts{'i'} && $opts{'s'}) {
    }

    if ($opts{'a'}) {
        my @nodes = $xpath->findnodes('/ns:GetIdentityDkimAttributesResponse' .
                                      '/ns:GetIdentityDkimAttributesResult' .
                                      '/ns:DkimAttributes' .
                                      '/ns:entry');
        print "Identity,DkimVerificationStatus,DkimEnabled,DkimToken1,DkimToken2,DkimToken3\n";
        foreach my $node (@nodes) {
            my $identity            = ${$xpath->findnodes('ns:key', $node)}[0]->textContent();
            my $value               = ${$xpath->findnodes('ns:value', $node)}[0];
            my $verification_status = ${$xpath->findnodes('ns:DkimVerificationStatus', $value)}[0]->textContent();
            my $enabled             = ${$xpath->findnodes('ns:DkimEnabled', $value)}[0]->textContent();
            my @token_nodes         = @{$xpath->findnodes('ns:DkimTokens/ns:member', $value)};
            my @tokens = ();
            foreach my $node (@token_nodes) {
                my $token = $node->textContent();
                push @tokens, $token;
            }
            my $line         = join ',', ($identity, $verification_status, $enabled, @tokens);
            print "$line\n";
        }
    }
}


# Main sequence of steps required to make a successful service call.
parse_args;
validate_opts;
prepare_params;
my ($response_code, $response_content, $response_flag) = SES::call_ses \%params, \%opts;
switch ($response_flag) {
    case /^THROTTLING/  { exit 75; }
}
switch ($response_code) {
    case '200' {              # OK
        print_response $response_content;
        exit  0;
    }
    case '400' { exit  1; }   # BAD_INPUT
    case '403' { exit 31; }   # SERVICE_ACCESS_ERROR
    case '500' { exit 32; }   # SERVICE_EXECUTION_ERROR
    case '503' { exit 30; }   # SERVICE_ERROR
    else       { exit -1; }
}


=head1 NAME

ses-setup-dkim.pl - Setup DKIM signing for the Amazon Simple Email Service (SES).

=head1 SYNOPSIS

B<ses-setup-dkim.pl> [B<--help>] [B<-e> URL] [B<-k> FILE] [B<--verbose>] B<-v> DOMAIN | B<-i> IDENTITY  B<-s> SIGN | B<-a> IDENTITY[,IDENTITY]...

=head1 DESCRIPTION

B<ses-setup-dkim.pl> Verifies domains for DKIM, enables, disables and retrieves DKIM attributes for identities.

=head1 OPTIONS

=over 8

=item B<--help>

Print the manual page.

=item B<-e> URL

The Amazon SES endpoint URL to use. If an endpoint is not provided then a default one will be used.
The default endpoint is "https://email.us-east-1.amazonaws.com/".

=item B<-k> FILE

The Amazon Web Services (AWS) credentials file to use. If the credentials
file is not provided the script will try to get the credentials file from the
B<AWS_CREDENTIALS_FILE> environment variable and if this fails then the script will fail
with an error message.

=item B<--verbose>

Be verbose and display detailed information about the endpoint response.

=item B<-v> DOMAIN

Verify domain to be used for DKIM signed emails.

=item B<-i> IDENTITY

The identity for which to change settings.

=item B<-s> SIGN

Whether or not to DKIM sign email. Can be either 'true' or 'false'.

=item B<-a> IDENTITY

Retrieve DKIM signing attributes for identity.

=back

=head1 COPYRIGHT

Amazon.com, Inc. or its affiliates

=cut
