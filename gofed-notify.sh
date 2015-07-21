#!/bin/bash
#
# gofed-notify.sh - a simple notify script for gofed
# Copyright (C) 2015 Fridolin Pokorny, <fpokorny@redhat.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301,
# USA.
# ####################################################################
#set -x

VERSION="v0.1"

# Output file
FOUT="/dev/stdout"
# Recipients
declare -A EMAIL
# Subject used in email; adjust if needed or run with:
#   GOFED_NOTIFY_SUBJECT="Custom subject" gofed-notify.sh email email@me
[ -z ${GOFED_NOTIFY_SUBJECT+x} ] && \
	SUBJECT="[gofed-notify]: Update log from `date '+%F %H:%M'`"
# My name
PROG=`basename $0`

function printHelp {
	echo "$1 - A simple notify script for gofed"
	echo "Synopsis: $1 command [arg1 [arg2 ...]]"
	echo ""
	echo "command:"
	echo "	email		notify via e-mail"
	echo "	print		print update to stdout or a file"
	echo ""
	echo "$VERSION"
}

function printHelpPrint {
	echo "Usage: $1 [FILE]"
	echo ""
	echo "  FILE"
	echo "    output file; otherwise stdout is used"
}

function printHelpEmail {
	echo "Usage: $1 OPTION [DST]"
	echo ""
	echo "Available options:"
	echo "  email"
	echo "    send e-mail report to DST, DST is list of recipients (required)"
	echo "  print"
	echo "    log report to file DST (if DST is not present, stdout is used)"
}

function doUpdate {
	echo -e ">>> New packages scan:\n" && \
		gofed scan-packages -n 2>&1 && \
		echo -e "\n>>> Add new packages to database:\n" && \
		gofed scan-packages -u 2>&1 && \
		echo -e "\n>>> Update local database:\n" && \
		gofed scan-imports -c 2>&1
	return $?
}

case "$1" in
	"help")
		shift
		printHelp "${PROG}"
		exit 0
		;;
	"email")
		shift
		[ "$1" == "-h" -o "$1" == "--help" ] && {
			printHelpEmail "${PROG}"
			exit 0
		}
		[ -z "$*" ] && { printHelp "${PROG}"; exit 1; }
		EMAIL=$@
		;;
	"print")
		shift
		[ "$1" == "-h" -o "$1" == "--help" ] && {
			printHelpPrint "${PROG}"
			exit 0
		}
		[ -n "$1" ] && { FOUT="$1"; truncate -s 0 "${FOUT}"; shift; }
		[ -n "$*" ] && { printHelp "${PROG}"; exit 1; }
		;;
	*)
		printHelp "${PROG}"
		exit 1
		;;
esac

OUTPUT="$(doUpdate)"
RET=$?

echo "${SUBJECT}" >> "${FOUT}"
echo "${OUTPUT}" >> "${FOUT}"

for rec in ${EMAIL}; do
	echo ">>> Sending log to '${rec}'"
	echo "${OUTPUT}" | mailx -s "$SUBJECT" "$rec"
done

exit ${RET} # bye!

