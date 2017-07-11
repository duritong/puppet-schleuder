# schleuder puppet module

Puppet module for [schleuder](https://schleuder.nadir.org), a gpg-enabled mailing list manager with resending-capabilities.

#### Table of Contents

1. [Description](#description)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description


Manages the installation, configuration of [schleuder](https://schleuder.nadir.org), the schleuder-api-daemon and cli tool `schleuder-cli`.

Furthermore, you are able to create and delete list instances.

For CentOS 7, it can also manage the installation of [schleuder-web](https://0xacab.org/schleuder/schleuder-web).


## Usage

Most people will be fine using the [schleuder](README.md#schleuder) class, which setups schleuder in a ready to be used
manner.

Further usage examples are explained in the different parts. See [examples](README.md#examples) for specific code details.

### Requirements

This module requires a set of other modules to work. See [Puppetfile](Puppetfile) for a detailed dependency list.

Most notably it requires:

* puppetlabs/stdlib
* puppetlabs/concat
* puppet/healthcheck

For CentOS it requires additional modules to manage SCL and SELinux.

Furthermore, the module assumes, that the distributions package manager is ready to install the packages. This
module does not manage any special repositories or priorities of package sources.

### schleuder

The main class to be used, it allows to install and configure schleuder, schleuder-api-daemon and optionally schleuder-cli.

Parameters are managing configuration of schleuder. See schleuder's [documentation](https://schleuder.nadir.org/docs/#configuration) or its [config directory](https://0xacab.org/schleuder/schleuder/tree/master/etc) for the different configuration options and this [puppet-module's templates](templates/)

#### Parameters

* `valid_api_keys`: An array of api keys for the `schleuder-api-daemon. Use this one if you have static api keys on other systems.
* `cli_api_key`: An api key for schleuder-cli. If set puppet will install `schleuder-cli` configured for the root user. Required to use `schleuder::cli`.
* `tls_fingerprint`: The tls fingerprint of schleuder-api-daemon's certificate. Required for cli, defaults the fact `schleuder_tls_fingerprint`.
* `export_tls_fingerprint`: Whether the module should export the `schleuder_tls_fingerprint` in a concat::fragment snippet using exported resources, ready to be consumed by a client node.
* `api_host`: On which ipaddress the `schleuder-api-daemon` should listen. Defaults to `localhost`
* `api_port`: Port of the `schleuder-api-daemon`. Default: 4443
* `use_shorewall`: Whether the `api_port` should be opened externally using the [shorewall-module](https://git-ipuppet.immerda.ch/module-shorewall). See [schleuder::shorewall](manifests/shorewall.pp) for more Information.
* `database_config`: A possible hash of an activerecord-based database configuration. Defaults: `{}` -> schleuder uses sqlite
* `superadmin`: The administrator of the schleuder server. Defaults to `root@localhost`. Must not be another schleuder list.
* `adminkeys_path`: A default `puppet:///` source for public keys of list administrators, when creating lists through `schleuder::list`. Defaults to `modules/site_schleuder/adminkeys`.
* `lists`: A hash of `schleuder::list` instances to be managed.
* `web_api_key`: A dedicated api_key for a `schleuder::web` installation. Does not automatically install `schleuder::web` but prepares a `concat::fragment` to be exported.
* `export_web_api_key`: Whether to export the configured web_api_key or not.

### schleuder::client

Manages installation and configuration of `schleuder-cli`. In most cases this class is used through the `schleuder` class.

Besides managing the packages, it configures the schleuder-cli config file for user `root`.

#### Parameters

* `api_key`: For the configuration file
* `tls_fingerprint`: Of the `schleuder-api-daemon`.
* `host`: to connect to
* `port`: Of the `schleuder-api-daemon`.

### schleuder::web

Manages the installation of [schleuder-web](https://0xacab.org/schleuder/schleuder-web).

Parameters are managing configuration of schleuder-web. See [schleuder-web's config directory](https://0xacab.org/schleuder/schleuder-web/tree/master/config) for the different configuration options and this [puppet-module's templates](templates/web/)

* `api_key`: Of the `schleuder-api-daemon`.
* `api_tls_fingerprint`:  Of the `schleuder-api-daemon`. Defaults to the fact `schleuder_tls_fingerprint`
* `api_host`: Of the `schleuder-api-daemon`. Default: `localhost`
* `api_port`: Of the `schleuder-api-daemon`. Default: `4443`
* `web_hostname`: Hostname of the vhost, serving this schleuder installation. Default: `example.org`. Will be used in emails sent by [schleuder-web](https://0xacab.org/schleuder/schleuder-web).
* `mailer_from`: Sender of the sign-up emails. Default: `noreply@example.org`
* `database_config`A possible hash of an activerecord-based database configuration. Defaults: `{}` -> schleuder-web uses sqlite.
* `ruby_scl`: Which scl version it uses. Default: `ruby23`.
* `use_shorewall`: Whether or not to open up connectivity TO a `schleuder-api-daemon`.

### schleuder::list

This is a define, that wrapps the native type `schleuder_list`, mainly for convenience in deploying a public key for the admin of a list.

#### Parameters

* `ensure`: Whether list should be present or absent. Default: `present`
* `admin`: Emailaddress of the initial administrator of a list. Must be present if lists' ensure is set to `present`.
* `admin_publickey`: A source of a public key of the lists' admin. Used to subscribe the admin properly. Can be a string containing the armored public key, a full `puppet://` or local path. If not set, puppet will try to fetch it from `puppet:///${schleuder::adminkeys_path}/${admin}.pub`.

### schleuder_list

Native type to create and destroy a schleuder list. Doesn't do much more than what `schleuder-cli lists new` and `schleuder-cli lists delete` does.

It is possible to purge all unmanaged schleuder lists using puppet's [resources-type](https://docs.puppet.com/puppet/latest/type.html#resources).

#### Parameters

* `name`: The lists address. Is schleuder_list's namevar.
* `ensure`: `present` or `absent`. Default: `present`
* `admin`: The initial adminaddress of a list. Won't be enforced, once the list is created.
* `admin_publickey`: A local path to a file containing an armored public key of the `admin`.

### Facts

* `schleuder_tls_fingerprint`: Output of `schleuder cert fingerprint`.

### Examples

A simple fully functional installation of schleuder, with `schleuder-api-daemon` running:

    include schleuder

An installation of schleuder, with `schleuder-api-daemon` running and `schleuder-cli` configured (required to manage lists!). It uses a semi-random cli api key based on the node's fqdn:

    class{'schleuder':
      cli_api_key => sha1("${fqdn_rand(1204,'cli')}"),
    }

Same setup, but with 2 lists configured:

    class{'schleuder':
      cli_api_key => sha1("${fqdn_rand(1204,'cli')}"),
      lists       => {
        list1@example.com => {
          admin => admin@example.com,
        },
        list2@example2.com => {
          admin => user@example.com,
        },
      },
    }

We recommend you to use [Hiera](https://docs.puppet.com/hiera/) to do further configuration.


See [schleuder-vagrant](https://0xacab.org/schleuder/schleuder-vagrant) as an example on how it can be used.

## Limitations

Tested on CentOS 7 and Debian stretch. `schleuder::web` so far only works on CentOS 7.

## Development

Contributing
------------

Please see [CONTRIBUTING.md](CONTRIBUTING.md).


Code of Conduct
---------------

We adopted a code of conduct. Please read [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).


License
-------

GNU GPL 3.0. Please see [LICENSE.txt](LICENSE.txt).

