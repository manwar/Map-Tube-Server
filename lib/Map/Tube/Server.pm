package Map::Tube::Server;

$Map::Tube::Server::VERSION   = '0.01';
$Map::Tube::Server::AUTHORITY = 'cpan:MANWAR';

=head1 NAME

Map::Tube::Server - Dancer2 based server for Map::Tube.

=head1 VERSION

Version 0.01

=cut

use 5.006;
use strict; use warnings;
use Data::Dumper;

use Dancer2;
use Dancer2::Plugin::Res;
use Dancer2::Plugin::Map::Tube;

=head1 DESCRIPTION

Dancer2 based framework to build the Map::Tube public facing  REST API. Currently
it is being used by manwar.org to provide the service as REST API.It's still very
much beta version v1.

=head1 SUPPORTED MAPS

The supported maps are defined in L<Dancer2::Plugin::Map::Tube>. You can override
the list by  providing  the list in the app configuration file. The configuration
should look like below:

    ...
    ...

    plugins:
        "Map::Tube":
            user_maps: [ "london", "delhi", "barcelona", "kolkatta" ]
    ...
    ...

=over 2

=item Barcelona

=item Beijing

=item Berlin

=item Bucharest

=item Budapest

=item Delhi

=item Dnipropetrovsk

=item Glasgow

=item Kazan

=item Kharkiv

=item Kiev

=item KoelnBonn

=item Kolkatta

=item KualaLumpur

=item London

=item Lyon

=item Malaga

=item Minsk

=item Moscow

=item Nanjing

=item NizhnyNovgorod

=item Novosibirsk

=item Prague

=item SaintPetersburg

=item Samara

=item Singapore

=item Sofia

=item Tbilisi

=item Vienna

=item Warsaw

=item Yekaterinburg

=back

=head1 UNSUPPORTED MAPS

The following maps do not have complete map data yet.

=over 2

=item Map::Tube::NYC

=item Map::Tube::Tokyo

=back

=head1 ERROR MESSAGES

=over 2

=item REACHED REQUEST LIMIT

=item MISSING MAP NAME

=item RECEIVED INVALID MAP NAME

=item RECEIVED UNSUPPORTED MAP NAME

=item MISSING START STATION NAME

=item RECEIVED INVALID START STATION NAME

=item MISSING END STATION NAME

=item RECEIVED INVALID END STATION NAME

=item MISSING LINE NAME

=item RECEIVED INVALID LINE NAME

=item MAP NOT INSTALLED

=back

=cut

hook before => sub {
    header 'Content-Type' => 'application/json';
};

=head1 ROUTES

=head2 GET /map-tube/v1/shortest-route/:map/:start/:end

Return the shortest route from C<$start> to C<$end> in the C<$map>.

Returns ref to an array of shortest route stations list in JSON format.

For example:

    curl http://localhost/map-tube/v1/shortest-route/london/baker%20street/wembley%20park

=cut

get '/shortest-route/:map/:start/:end' => sub {
    my $client   = request->address;
    my $name     = route_parameters->get('map');
    my $start    = route_parameters->get('start');
    my $end      = route_parameters->get('end');
    my $response = api($name)->shortest_route($client, $start, $end);

    return res($response->{error_code} => $response->{error_message})
        if (exists $response->{error_code});

    return $response->{content};
};

=head2 GET /map-tube/v1/stations/:map/:line

Returns ref to an array of stations list  in JSON format for the given C<map> and
C<line>. The C<map> can be any of the supported maps. And the  C<line> can be any
of lines within the C<map>.For more details, please look into the relevant module
for the map C<Map::Tube::*>.

    curl http://manwar.mooo.info/map-tube/v1/stations/london/metropolitan

=cut

get '/stations/:map/:line' => sub {
    my $client   = request->address;
    my $name     = route_parameters->get('map');
    my $line     = route_parameters->get('line');

    my $response = api($name)->line_stations($client, $line);

    return res($response->{error_code} => $response->{error_message})
        if (exists $response->{error_code});

    return $response->{content};
};

=head2 GET /map-tube/v1/stations/:map

Returns ref to an array of stations list in JSON format for the given C<map>.

    curl http://manwar.mooo.info/map-tube/v1/stations/london

=cut

get '/stations/:map' => sub {
    my $client   = request->address;
    my $name     = route_parameters->get('map');
    my $response = api($name)->map_stations($client);

    return res($response->{error_code} => $response->{error_message})
        if (exists $response->{error_code});

    return $response->{content};
};

=head2 GET /map-tube/v1/maps

Returns ref to an array of supported maps.

    curl http://manwar.mooo.info/map-tube/v1/maps

=cut

get '/maps' => sub {
    my $client   = request->address;
    my $response = api->available_maps($client);

    return res($response->{error_code} => $response->{error_message})
        if (exists $response->{error_code});

    return $response->{content};
};

=head1 AUTHOR

Mohammad S Anwar, C<< <mohammad.anwar at yahoo.com> >>

=head1 REPOSITORY

L<https://github.com/manwar/Map-Tube-Server>

=head1 BUGS

Please  report any bugs or feature requests to C<bug-map-tube-server at rt.cpan.org>,
or through the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Map-Tube-Server>.
I will  be notified and then you'll automatically be notified of progress on your
bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Map::Tube::Server

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Map-Tube-Server>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Map-Tube-Server>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Map-Tube-Server>

=item * Search CPAN

L<http://search.cpan.org/dist/Map-Tube-Server/>

=back

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2017 Mohammad S Anwar.

This program  is  free software; you can redistribute it and / or modify it under
the  terms  of the the Artistic License (2.0). You may obtain  a copy of the full
license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any  use,  modification, and distribution of the Standard or Modified Versions is
governed by this Artistic License.By using, modifying or distributing the Package,
you accept this license. Do not use, modify, or distribute the Package, if you do
not accept this license.

If your Modified Version has been derived from a Modified Version made by someone
other than you,you are nevertheless required to ensure that your Modified Version
 complies with the requirements of this license.

This  license  does  not grant you the right to use any trademark,  service mark,
tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge patent license
to make,  have made, use,  offer to sell, sell, import and otherwise transfer the
Package with respect to any patent claims licensable by the Copyright Holder that
are  necessarily  infringed  by  the  Package. If you institute patent litigation
(including  a  cross-claim  or  counterclaim) against any party alleging that the
Package constitutes direct or contributory patent infringement,then this Artistic
License to you shall terminate on the date that such litigation is filed.

Disclaimer  of  Warranty:  THE  PACKAGE  IS  PROVIDED BY THE COPYRIGHT HOLDER AND
CONTRIBUTORS  "AS IS'  AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES. THE IMPLIED
WARRANTIES    OF   MERCHANTABILITY,   FITNESS   FOR   A   PARTICULAR  PURPOSE, OR
NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY YOUR LOCAL LAW. UNLESS
REQUIRED BY LAW, NO COPYRIGHT HOLDER OR CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL,  OR CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE
OF THE PACKAGE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=cut

1; # End of Map::Tube::Server
