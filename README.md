# Roundcube on php:5.6-apache

[![docker hub](https://img.shields.io/badge/docker-image-blue.svg?style=flat)](https://registry.hub.docker.com/u/jnbt/roundcube/)
[![](https://images.microbadger.com/badges/version/jnbt/roundcube.svg)](https://registry.hub.docker.com/u/jnbt/roundcube/)
[![microbadger](https://images.microbadger.com/badges/image/jnbt/roundcube.svg)](https://microbadger.com/images/jnbt/roundcube)

## Docker run

    docker run --rm \
      --network backend \
      --name roundcube \
      -P \
      jnbt/roundcube

### Setup database

In case you want to automatically create the MySQL database layout run the container with `app:init`:

    docker run --rm -it \
      --network backend \
      jnbt/roundcube \
      app:init
      
**NOTE:** This must be used in iteractive mode, as you may have to answer questions of the CLI.

## Configuration

### MySQL

The typical environment variables for MySQL are available:

```
-e MYSQL_HOST=roundcube
-e MYSQL_USER=roundcube
-e MYSQL_DATABASE=roundcube
-e MYSQL_PASSWORD=roundcube
```

### Roundcube via environment variables

You can configure all simple [Roundcube configuration options](https://github.com/roundcube/roundcubemail/wiki/Configuration)
using enviroment variables **prefixed** with `RC_`.

**Example:** Using TLS to connect via IMAP, SMTP, MANAGESIEVE to a (linked) host `mail`:

```
-e RC_DEFAULT_HOST=tls://mail
-e RC_SMTP_SERVER=tls://mail
-e RC_MANAGESIEVE_HOST=tls://mail
```

### Roundcube via php files

In case you need a more complex configuration, e.g. setting `plugins`,
you can mount a directory holding further php-based configuration files:

```
-v /path/to/config/folder:/var/www/html/config/custom:ro
```

Where a custom config file could be `/path/to/config/folder/user.inc.php`:

```
<?php

// List of active plugins (in plugins/ directory)
$config['plugins'] = array('managesieve', 'archive', 'show_additional_headers');
```

## Updating

You can update the Roundcube version by using the matching tag of this docker image:

1. Shutdown the running instance:

    	docker stop roundcube

2. Use the new version to update the database.

	    docker run --rm -it \
	      --network backend \
	      jnbt/roundcube:$VERSION \
	      app:update

    **NOTE:** This must be used in iteractive mode, as you may have to answer questions of the CLI.


3. Start the new version:

	    docker run --rm \
	      --network backend \
	      --name roundcube \
	      -P \
	      jnbt/roundcube


## Software

* [php:5.6-apache](https://hub.docker.com/_/php/)
* [Roundcube 1.2.0](https://roundcube.net)

## Release

* `Makefile`: Bump `VERSION`
* `Dockerfile`: Bump `ROUNDCUBE_VERSION` and `RELEASE_DATE`
* `README.md`: Bump versions in `Software` section
* Run `make release`
