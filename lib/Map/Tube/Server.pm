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
the list by providing the list in the app configuration file. The name of the app
should be  set  to  environment  variable C<MAP_APP_NAME>. The configuration file
should have something like below:

    ...
    ...

    plugins:
        "Map::Tube":
            available_maps: [ "london", "delhi", "barcelona", "kolkatta" ]
    ...
    ...

=over 2

=item Map::Tube::London

=item Map::Tube::Delhi

=item Map::Tube::Barcelona

=item Map::Tube::Kolkatta

=back

=head1 ERROR CODES

=over 2

=item 401 - Breached Threshold

=item 402 - Missing map name

=item 403 - Unsupported map

=back

=cut

hook before => sub {
    header 'Content-Type' => 'application/json';
};

=head1 ROUTES

=head2 POST /map-tube/v1/shortest-route

Request body must have the following data:

    +-------+-------------------------------------------+
    | Key   | Description                               |
    +-------+-------------------------------------------+
    | name  | Map name e.g. London,Delhi,Barcelona etc. |
    | start | Start station name.                       |
    | end   | End station name.                         |
    +-------+-------------------------------------------+

Returns ref to an array of shortest route stations list in JSON format.

For example:

    curl --data "map=london&start=Baker Street&end=Wembley Park" http://manwar.mooo.info/map-tube/v1/shortest-route

=cut

post '/shortest-route' => sub {
    my $client   = request->address;
    my $name     = body_parameters->get('map');
    my $start    = body_parameters->get('start');
    my $end      = body_parameters->get('end');
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
