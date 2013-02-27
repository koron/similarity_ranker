#!/bin/sh

sh setup-data01.sh

redis-cli <<__END__ > /dev/null

LPUSH item_keys item_0000
LPUSH item_keys item_0001
LPUSH item_keys item_0002
LPUSH item_keys item_0003
LPUSH item_keys item_0004
LPUSH item_keys item_0005
LPUSH item_keys item_0006
LPUSH item_keys item_0007
LPUSH item_keys item_0008
LPUSH item_keys item_0009
LPUSH item_keys item_0010
LPUSH item_keys item_0011
LPUSH item_keys item_0012
LPUSH item_keys item_0013
LPUSH item_keys item_0014
LPUSH item_keys item_0015
LPUSH item_keys item_0016
LPUSH item_keys item_0017
LPUSH item_keys item_0018
LPUSH item_keys item_0019
LPUSH item_keys item_0020
LPUSH item_keys item_0021
LPUSH item_keys item_0022
LPUSH item_keys item_0023
LPUSH item_keys item_0024
LPUSH item_keys item_0025
LPUSH item_keys item_0026
LPUSH item_keys item_0027
LPUSH item_keys item_0028
LPUSH item_keys item_0029
LPUSH item_keys item_0030
LPUSH item_keys item_0031

__END__
