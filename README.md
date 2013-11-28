puppetdb-dokuwiki
=================

Generates wikipages for dokuwiki out of puppetdb's facts

This script connects to puppetdb and generates a wikipage for every host.
For now this script uses many custom facts that I haven't published yet but you should get a good idea what it does.

The script creates two files:
  - /server/#{fqdn}
  - /facts/#{fqdn}
where the facts directory will always be overwritten by the current facts and the server directory only initially places the file.
Therefore you can write documentation in the server namespace and see the facts through the include plugin.

Plugins used in Dokuwiki:
  - include ( http://dokuwiki.org/plugin:include )
  - indexmenu ( https://www.dokuwiki.org/plugin:indexmenu )
  - tag ( http://dokuwiki.org/plugin:tag )
  - wrap ( http://dokuwiki.org/plugin:wrap )
