# Create a Rails instance.
define rails::install($path, $dbtype = postgresql, $dbserver = false, $dbuser = false, $dbpassword = $false, $environments = [production, test, development]) {
    # Create the system
    exec { "Create $name rails site":
        command => "/usr/bin/rails --database $dbtype $path",
        creates => "$path/config"
    }

    # Now create the db config
    file { "$path/config/database.yml":
        content => template("rails/dbconfig.erb")
    }

}

# $Id$
