#!/bin/bash
set -e

# Starting amavis
DAEMON=/usr/sbin/amavisd-new
START="--start --quiet --pidfile $PIDFILE --startas ${DAEMON} --user amavis"

createdir()
{
    # $1 = user
    # $2 = group
    # $3 = permissions (octal)
    # $4 = path to directory
    [ -d "$4" ] || mkdir -p "$4"
    chown -c -h "$1:$2" "$4"
    chmod -c "$3" "$4"
}

fixdirs()
{
	dir=$(dpkg-statoverride --list /var/run/amavis) || {
		echo "You are missing a dpkg-statoverride on /var/run/amavis.  Fix it, otherwise you risk silent breakage on upgrades." >&2
		exit 1
	}
	[ -z "$dir" ] || createdir $dir
	:
}

cleanup()
{
	[ -d /var/lib/amavis ] && 
	  find /var/lib/amavis -maxdepth 1 -name 'amavis-*' -type d \
	  	-exec rm -rf "{}" \; >/dev/null 2>&1 || true
	[ -d /var/lib/amavis/tmp ] && 
	  find /var/lib/amavis/tmp -maxdepth 1 -name 'amavis-*' -type d \
	  	-exec rm -rf "{}" \; >/dev/null 2>&1 || true
	:
}

fixdirs
