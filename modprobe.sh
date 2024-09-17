#!/bin/sh
#
# Copyright (c) 2020 - present Cloudogu GmbH
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU Affero General Public License as published by the Free
# Software Foundation, version 3.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
# details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see https://www.gnu.org/licenses/.
#

set -eu

# "modprobe" without modprobe
# https://twitter.com/lucabruno/status/902934379835662336

# this isn't 100% fool-proof, but it'll have a much higher success rate than simply using the "real" modprobe

# Docker often uses "modprobe -va foo bar baz"
# so we ignore modules that start with "-"
for module; do
	if [ "${module#-}" = "$module" ]; then
		ip link show "$module" || true
		lsmod | grep "$module" || true
	fi
done

# remove /usr/local/... from PATH so we can exec the real modprobe as a last resort
export PATH='/usr/sbin:/usr/bin:/sbin:/bin'
exec modprobe "$@"
