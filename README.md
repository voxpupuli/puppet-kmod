# Kmod Puppet module

[![Puppet Forge Version](http://img.shields.io/puppetforge/v/camptocamp/kmod.svg)](https://forge.puppetlabs.com/camptocamp/kmod)
[![Puppet Forge Downloads](http://img.shields.io/puppetforge/dt/camptocamp/kmod.svg)](https://forge.puppetlabs.com/camptocamp/kmod)
[![Build Status](https://img.shields.io/travis/camptocamp/puppet-kmod/master.svg)](https://travis-ci.org/camptocamp/puppet-kmod)
[![Puppet Forge Endorsement](https://img.shields.io/puppetforge/e/camptocamp/kmod.svg)](https://forge.puppetlabs.com/camptocamp/kmod)
[![Gemnasium](https://img.shields.io/gemnasium/camptocamp/puppet-kmod.svg)](https://gemnasium.com/camptocamp/puppet-kmod)
[![By Camptocamp](https://img.shields.io/badge/by-camptocamp-fb7047.svg)](http://www.camptocamp.com)

## Description

This module provides definitions to manipulate modprobe.conf (5) stanzas:

 * kmod::alias
 * kmod::install
 * kmod::blacklist

It depends on Augeas with the modprobe lens.

## Usage

This module has five main defined types:

  * kmod::load
  * kmod::alias
  * kmod::option
  * kmod::install
  * kmod::blacklist

## class kmod parameters

aliases
-------
Hash of defined type kmod::aliases.

- *Default*: undef

aliases_hiera_merge
-------------------
Boolean to control merges of all found instances of types::aliases in Hiera.
This is useful for specifying kmod::alias resources at different levels of the
hierarchy and having them all included in the catalog.

- *Default*: true

blacklists
----------
Hash of defined type kmod::blacklists.

- *Default*: undef

blacklists_hiera_merge
----------------------
Boolean to control merges of all found instances of types::blacklists in Hiera.
This is useful for specifying kmod::blacklist resources at different levels of the
hierarchy and having them all included in the catalog.

- *Default*: true

installs
--------
Hash of defined type kmod::installs.

- *Default*: undef

installs_hiera_merge
--------------------
Boolean to control merges of all found instances of types::installs in Hiera.
This is useful for specifying kmod::install resources at different levels of the
hierarchy and having them all included in the catalog.

- *Default*: true

loads
-----
Hash of defined type kmod::loads.

- *Default*: undef

loads_hiera_merge
-----------------
Boolean to control merges of all found instances of types::loads in Hiera.
This is useful for specifying kmod::load resources at different levels of the
hierarchy and having them all included in the catalog.

- *Default*: true

options
-------
Hash of defined type kmod::options.

- *Default*: undef

options_hiera_merge
-------------------
Boolean to control merges of all found instances of types::options in Hiera.
This is useful for specifying kmod::option resources at different levels of the
hierarchy and having them all included in the catalog.

- *Default*: true

settings
--------
Hash of defined type kmod::settings.

- *Default*: undef

settings_hiera_merge
--------------------
Boolean to control merges of all found instances of types::settings in Hiera.
This is useful for specifying kmod::setting resources at different levels of the
hierarchy and having them all included in the catalog.

- *Default*: true

### kmod::load

Loads a module using modprobe and manages persistent modules in /etc/sysconfig/modules

```puppet
  kmod::load { 'mymodule': }
```

### kmod::alias

Adds an alias to modprobe.conf, by default `/etc/modprobe.d/<name>.conf` is assumed for a filename.

```puppet
  kmod::alias { 'bond0':
    modulename => 'bonding',
  }
```

Params:
* `modulename`: Name of the module to alias
* `aliasname`: Name of the alias (defaults to the resource title)
* `file`: File to write to (see above default)

### kmod::option

Adds an option to modprobe.conf

```puppet
  kmod::option { 'bond0 mode':
    module => 'bond0',
    option => 'mode',
    value  => '1',
  }

  kmod::option { 'bond0':
    option => 'mode',
    value  => '1',
  }
```

Params:
* `option`: Name of the parameter to add
* `value`: Value of the parameter
* `module`: Name of the module (if ommited, the resource title is used)
* `file`: File to write to (defaults to `/etc/modprobe.d/<module name>.conf`)

### kmod::blacklist

Manages modprobe blacklist entries 

```puppet
  kmod::blacklist { 'foo': }
```

Params:
* `file`: File to write to, defaults to `/etc/modprobe.d/blacklist.conf`

### kmod::install

Manage modprobe install entries

```puppet
   kmod::install { 'pcspkr': }
```

Params:
* `file`: File to write to (defaults to `/etc/modprobe.d/<module name>.conf`)
* `command`: (optional) command associated with the install, defaults to `/bin/true`



## Contributing

Please report bugs and feature request using [GitHub issue
tracker](https://github.com/camptocamp/puppet-kmod/issues).

For pull requests, it is very much appreciated to check your Puppet manifest
with [puppet-lint](https://github.com/camptocamp/puppet-kmod/issues) to follow the recommended Puppet style guidelines from the
[Puppet Labs style guide](http://docs.puppetlabs.com/guides/style_guide.html).

## License

Copyright (c) 2013 <mailto:puppet@camptocamp.com> All rights reserved.

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.
    
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
    
    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

