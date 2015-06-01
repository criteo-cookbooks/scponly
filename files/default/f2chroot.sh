#!/bin/bash
# Use this script to copy shared (libs) and binary files to chrooted environment
# jail server.
# ----------------------------------------------------------------------------
# Written by nixCraft <http://www.cyberciti.biz/tips/>
# (c) 2006 nixCraft under GNU GPL v2.0+
# + Added ld-linux support
# + Added error checking support
# ------------------------------------------------------------------------------
# See url for usage:
# http://www.cyberciti.biz/tips/howto-setup-lighttpd-php-mysql-chrooted-jail.html
# -------------------------------------------------------------------------------
# Set CHROOT directory name
while (($#)); do
	OPT=$1
	shift
	case $OPT in
		--*)
			case ${OPT:2} in
				root)
					BASE="$1"
					shift
					;;
			esac
			;;

		-*)
			case ${OPT:1} in
				r)
					BASE="$1"
					shift
					;;
			esac
			;;
		*)
			BIN="${OPT}"
			;;
	esac
done

if [ -z "${BIN}" ] || [ -z "${BASE}" ]; then
	echo
	echo "	Syntax : $0 -r|--root /chroot/home /path/to/executable"
	echo
	echo "	Example:"
	echo "		$0 -r /var/chroot /usr/bin/php5-cgi"
	echo
	exit 1
fi

[ ! -d "${BASE}" ] && mkdir -p "${BASE}" || :

# First copy the binary
subbindir="$(dirname ${BIN})"
if [ -e ${BIN} ]; then
	[ ! -d "${BASE}${subbindir}" ] && mkdir -p "${BASE}${subbindir}" || :
	echo "[f2chroot] ------------------------------"
	echo "[f2chroot] Copying '${BIN}' into chroot '${BASE}'..."
	/bin/cp "${BIN}" "${BASE}${BIN}"

	# iggy ld-linux* file as it is not shared one
	FILES="$(ldd "${BIN}" | awk '{ print $3 }' |egrep -v ^'\(')"

	if [ "${FILES}" == 'dynamic' ]; then
		echo "[f2chroot] No shared files/libs needed"
	else
		echo "[f2chroot] Copying shared files/libs..."
		for i in ${FILES}
		do
			d="$(dirname "${i}")"
			[ ! -d "${BASE}${d}" ] && mkdir -p "${BASE}${d}" || :
			echo "[f2chroot]   --> Copying '${i}'"
			[ -e "${i}" ] && /bin/cp "${i}" "${BASE}${d}"
		done

		# copy /lib/ld-linux* or /lib64/ld-linux* to ${BASE}/$sldlsubdir
		# get ld-linux full file location
		sldl="$(ldd "${BIN}" | grep 'ld-linux' | awk '{ print $1}')"
		# now get sub-dir
		sldlsubdir="$(dirname "${sldl}")"

		echo "[f2chroot] Copying ld-linux* libs..."
		if [ ! -f "${BASE}${sldl}" ]; then
			[ ! -d "${BASE}${sldlsubdir}" ] && mkdir -p "${BASE}${sldlsubdir}" || :
			echo "[f2chroot]   --> Copying '${sldl}'"
			/bin/cp "${sldl}" "${BASE}${sldlsubdir}"
		else
			:
		fi
	fi
	echo "[f2chroot] ------------------------------"
else
	echo "[f2chroot] Info: '${BIN}' doesn't exist, so no copy"
fi
