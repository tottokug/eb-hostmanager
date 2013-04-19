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


my @argv = @ARGV;
my %opts = ();
my %params = ();


# Parse the command line arguments and place them in the %opts hash.
sub parse_args {
    GetOptions('verbose' => \$opts{'verbose'},
               'e=s'     => \$opts{'e'},
               'k=s'     => \$opts{'k'},
               'i=s'     => \$opts{'i'},
               'n=s'     => \$opts{'n'},
               't:s'     => \$opts{'t'},
               'f=s'     => \$opts{'f'},
               'a=s'     => \$opts{'a'},
               'help'    => \$opts{'h'}) or pod2usage(-exitval => 2);
    pod2usage(-exitstatus => 0, -verbose => 2) if ($opts{'h'});
    $opts{'a'} = SES::parse_list($opts{'a'}, ',') if ($opts{'a'});
    $opts{'f'} = lc $opts{'f'} if ($opts{'f'});
}


# Validate the arguments passed on the command line.
sub validate_opts {
    pod2usage(-exitval => 2) unless (
        (defined($opts{'a'} && length($opts{'a'})) ^
        (defined($opts{'i'}) && length($opts{'i'}) && defined($opts{'n'}) && length($opts{'n'}) && grep(/^-t$/, @argv)) ^
        (defined($opts{'i'}) && length($opts{'i'}) && defined($opts{'f'}) && length($opts{'f'}))));
}


# Prepare the parameters for the service call.
sub prepare_params {
    if ($opts{'i'} && $opts{'n'}) {
        $params{'Identity'}                      = $opts{'i'};
        $params{'NotificationType'}              = $opts{'n'};
        if ($opts{'t'}) {
            $params{'SnsTopic'}                  = $opts{'t'};
        }
        $params{'Action'}                        = 'SetIdentityNotificationTopic';
    } elsif ($opts{'i'} && $opts{'f'}) {
        $params{'Identity'}                      = $opts{'i'};
        $params{'ForwardingEnabled'}             = $opts{'f'};
        $params{'Action'}                        = 'SetIdentityFeedbackForwardingEnabled';
    } elsif ($opts{'a'}) {
        my @opt_a = @{$opts{'a'}};
        for (my $i = 0; $i <= $#opt_a; $i++) {
            $params{'Identities.member.'.($i+1)} = $opt_a[$i];
        }
        $params{'Action'}                        = 'GetIdentityNotificationAttributes';
    }
}


# Prints the data returned by the service call.
sub print_response {
    my $response_content = shift;

    my $parser = XML::LibXML->new();
    my $dom = $parser->parse_string($response_content);
    my $xpath = XML::LibXML::XPathContext->new($dom);
    $xpath->registerNs('ns', $SES::aws_email_ns);

    if ($opts{'i'} && $opts{'n'}) {
    }

    if ($opts{'i'} && $opts{'f'}) {
    }

    if ($opts{'a'}) {
        my @nodes = $xpath->findnodes('/ns:GetIdentityNotificationAttributesResponse' .
                                      '/ns:GetIdentityNotificationAttributesResult' .
                                      '/ns:NotificationAttributes' .
                                      '/ns:entry');
        print "Identity,ForwardingEnabled,BounceTopic,ComplaintTopic\n";
        foreach my $node (@nodes) {
            my $identity           = ${$xpath->findnodes('ns:key', $node)}[0]->textContent();
            my $value              = ${$xpath->findnodes('ns:value', $node)}[0];
            my $forwarding_enabled = ${$xpath->findnodes('ns:ForwardingEnabled', $value)}[0]->textContent();
            my $bounce_topic       = ${$xpath->findnodes('ns:BounceTopic', $value)}[0];
            my $complaint_topic    = ${$xpath->findnodes('ns:ComplaintTopic', $value)}[0];
            if (defined($bounce_topic)) {
                $bounce_topic = $bounce_topic->textContent();
            } else {
                $bounce_topic = "";
            }
            if (defined($complaint_topic)) {
                $complaint_topic = $complaint_topic->textContent();
            } else {
                $complaint_topic = "";
            }
            my $line               = join ',', ($identity, $forwarding_enabled, $bounce_topic, $complaint_topic);
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

ses-setup-notifications.pl - Setup notifications for the Amazon Simple Email Service (SES).

=head1 SYNOPSIS

B<ses-setup-notifications.pl> [B<--help>] [B<-e> URL] [B<-k> FILE] [B<--verbose>] B<-i> IDENTITY B<-n> NOTIFICATION B<-t> [TOPIC] | B<-i> IDENTITY B<-f> FORWARD | B<-a> IDENTITY[,IDENTITY]...

=head1 DESCRIPTION

B<ses-setup-notifications.pl> Enables/Disables feedback forwarding, configures notification topics and retrieves notification attributes for identities.

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

=item B<-a> IDENTITY

Retrieve notification attributes for identity.

=item B<-i> IDENTITY

The identity for which to change settings.

=item B<-n> NOTIFICATION

The notification type for which the settings apply. Can be either 'Bounce' or 'Complaint'.

=item B<-t> [TOPIC]

The SNS topic to be used for sending notifications. Provide none to disable the corresponding notifications.

=item B<-f> FORWARD

Whether or not to forward feedback via email. Can be either 'true' or 'false'.

=back

=head1 COPYRIGHT

Amazon.com, Inc. or its affiliates

=cut
