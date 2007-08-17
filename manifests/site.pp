# Handle both the rails and db configurations in one swell foop.
define rails::site($path, $server_name = $fqdn, $dbtype = postgresql, $dbserver = false, $dbpassword = $false, $environments = [production, test, development], $servers = 3) {
    # The first port to use for the mongrel clusters..
    $port_start = 8000
    $port_increment = 20

    # Figure out which port number to allocate.  Assumes an essentially infinite
    # number of free ports after the port_start.
    $port_number = template("rails/port.erb")

    if tagged(rails_server) {
        # Set up the rails application itself.
        rails::install { $name:
            path => $path,
            dbtype => $dbtype,
            dbserver => $dbserver,
            dbuser => $name, # require the user's name to match the site name
            dbpassword => $dbpassword,
            environments => $environments,
        }

        # Set up a mongrel cluster for it.  Note we're only
        # setting up a cluster for production.
        mongrel::cluster { $name:
            path => $path,
            servers => $servers,
            environment => production,
            address => "127.0.0.1",
            port => $port_number
        }

        include nginx
        nginx::config { $fqdn:
            port_number => $port_number,
            servers => $servers,
            basedir => $path
        }
    }

    if tagged(dbserver) {
        # Then create the databases
        postgres::role { $name: ensure => present, password => $dbpassword }
        postgres::database {
            ["${name}_test", "${name}_production", "${name}_development"]:
                ensure => present, owner => $name, require => Postgres::Role[$name]
        }
    }
}

# $Id$
