#!/usr/bin/env bash
set -Eeuo pipefail
shopt -s nullglob

# https://www.python.org/downloads/23Introduction (under "OpenPGP Public Keys")
declare -A gpgKeys=(
	# gpg: key 18ADD4FF: public key "Benjamin Peterson <benjamin@python.org>" imported
	[2.7]='C01E1CAD5EA2C4F0B8E3571504C367C218ADD4FF'
	# https://www.python.org/dev/peps/pep-0373/#release-manager-and-crew

	# gpg: key F73C700D: public key "Larry Hastings <larry@hastings.org>" imported
	[3.5]='97FC712E4C024BBEA48A61ED3A5CA953F73C700D'
	# https://www.python.org/dev/peps/pep-0478/#release-manager-and-crew

	# gpg: key AA65421D: public key "Ned Deily (Python release signing key) <nad@acm.org>" imported
	[3.6]='0D96DF4D4110E5C43FBFB17F2D347EA6AA65421D'
	# https://www.python.org/dev/peps/pep-0494/#release-manager-and-crew

	# gpg: key AA65421D: public key "Ned Deily (Python release signing key) <nad@acm.org>" imported
	[3.7]='0D96DF4D4110E5C43FBFB17F2D347EA6AA65421D'
	# https://www.python.org/dev/peps/pep-0537/#release-manager-and-crew

	# gpg: key B26995E310250568: public key "\xc5\x81ukasz Langa (GPG langa.pl) <lukasz@langa.pl>" imported
	[3.8]='E3FF2839C048B25C084DEBE9B26995E310250568'
	# https://www.python.org/dev/peps/pep-0569/#release-manager-and-crew

	# gpg: key B26995E310250568: public key "\xc5\x81ukasz Langa (GPG langa.pl) <lukasz@langa.pl>" imported
	[3.9]='E3FF2839C048B25C084DEBE9B26995E310250568'
	# https://www.python.org/dev/peps/pep-0596/#release-manager-and-crew

        # gpg: key 64E628F8D684696D: public key "Pablo Galindo Salgado <pablogsal@gmail.com>" imported
	[3.10]='A035C8C19219BA821ECEA86B64E628F8D684696D'
	# https://www.python.org/dev/peps/pep-0619/#release-manager-and-crew
)

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

versions=( "$@" )
if [ ${#versions[@]} -eq 0 ]; then
	versions=( */ )
fi
versions=( "${versions[@]%/}" )

# PIP_VERSION
pipVersion="22.3.1"

generated_warning() {
	cat <<-EOH
		# EXPERIMENTAL_SYNTAX
		#
		# NOTE: THIS DOCKERFILE IS GENERATED VIA "update.sh"
		#
		# PLEASE DO NOT EDIT IT DIRECTLY.
		#

	EOH
}

travisEnv=
appveyorEnv=
for version in "${versions[@]}"; do
	rcVersion="${version%-rc}"
	rcGrepV='-v'
	if [ "$rcVersion" != "$version" ]; then
		rcGrepV=
	fi

	possibles=( $(
		{
			git ls-remote --tags https://github.com/python/cpython.git "refs/tags/v${rcVersion}.*" \
				| sed -r 's!^.*refs/tags/v([0-9a-z.]+).*$!\1!' \
				| grep $rcGrepV -E -- '[a-zA-Z]+' \
				|| :

			# this page has a very aggressive varnish cache in front of it, which is why we also scrape tags from GitHub
			curl -fsSL 'https://www.python.org/ftp/python/' \
				| grep '<a href="'"$rcVersion." \
				| sed -r 's!.*<a href="([^"/]+)/?".*!\1!' \
				| grep $rcGrepV -E -- '[a-zA-Z]+' \
				|| :
		} | sort -ruV
	) )
	fullVersion=
	declare -A impossible=()
	for possible in "${possibles[@]}"; do
		rcPossible="${possible%[a-z]*}"

		# varnish is great until it isn't
		if wget -q -O /dev/null -o /dev/null --spider "https://www.python.org/ftp/python/$rcPossible/Python-$possible.tar.xz"; then
			fullVersion="$possible"
			break
		fi

		if [ -n "${impossible[$rcPossible]:-}" ]; then
			continue
		fi
		impossible[$rcPossible]=1
		possibleVersions=( $(
			wget -qO- -o /dev/null "https://www.python.org/ftp/python/$rcPossible/" \
				| grep '<a href="Python-'"$rcVersion"'.*\.tar\.xz"' \
				| sed -r 's!.*<a href="Python-([^"/]+)\.tar\.xz".*!\1!' \
				| grep $rcGrepV -E -- '[a-zA-Z]+' \
				| sort -rV \
				|| true
		) )
		if [ "${#possibleVersions[@]}" -gt 0 ]; then
			fullVersion="${possibleVersions[0]}"
			break
		fi
	done

	if [ -z "$fullVersion" ]; then
		{
			echo
			echo
			echo "  error: cannot find $version (alpha/beta/rc?)"
			echo
			echo
		} >&2
		exit 1
	fi

	echo "$version: $fullVersion"

	for v in \
		alpine{3.9,3.10} \
                {bullseye,stretch,buster}/slim \
		windows/windowsservercore-{1809,1803,ltsc2016} \
	; do
		dir="$version/$v"
		variant="$(basename "$v")"

		[ -d "$dir" ] || continue

		case "$variant" in
			slim) template="$variant"; tag="$(basename "$(dirname "$dir")")" ;;
			windowsservercore-*) template='windowsservercore'; tag="${variant#*-}" ;;
			alpine*) template='alpine'; tag="${variant#alpine}" ;;
			*) template='debian'; tag="$variant" ;;
		esac
		if [ "$variant" = 'slim' ]; then
			# use "debian:*-slim" variants for "python:*-slim" variants
			tag+='-slim'
		fi
		if [[ "$version" == 2.* ]]; then
			template="caveman-${template}"
		fi
		template="Dockerfile-${template}.template"

		{ generated_warning; cat "$template"; } > "$dir/Dockerfile"

		sed -ri \
			-e 's/^(ENV GPG_KEY) .*/\1 '"${gpgKeys[$version]:-${gpgKeys[$rcVersion]}}"'/' \
			-e 's/^(ENV PYTHON_VERSION) .*/\1 '"$fullVersion"'/' \
			-e 's/^(ENV PYTHON_RELEASE) .*/\1 '"${fullVersion%%[a-z]*}"'/' \
			-e 's/^(ENV PYTHON_PIP_VERSION) .*/\1 '"$pipVersion"'/' \
			-e 's/^(FROM python):.*/\1:'"$version-$tag"'/' \
			-e 's!^(FROM (debian|buildpack-deps|alpine|mcr[.]microsoft[.]com/[^:]+)):.*?( as.*|$)!\1:'"$tag"'\3!' \
			"$dir/Dockerfile"

		case "$version/$v" in
			# Libraries to build the nis module only available in Alpine 3.7+.
			# Also require this patch https://bugs.python.org/issue32521 only available in Python 2.7, 3.6+.
			3.5*/alpine*)
				sed -ri -e '/libnsl-dev/d' -e '/libtirpc-dev/d' "$dir/Dockerfile"
				;;& # (3.5*/alpine* needs to match the next blocks too)

			# https://bugs.python.org/issue11063, https://bugs.python.org/issue20519 (Python 3.7.0+)
			# A new native _uuid module improves uuid import time and avoids using ctypes.
			# This requires the development libuuid headers.
			3.[5-6]*/alpine*)
				sed -ri -e '/util-linux-dev/d' "$dir/Dockerfile"
				;;
			3.[5-6]*)
				sed -ri -e '/uuid-dev/d' "$dir/Dockerfile"
				;;& # (other Debian variants need to match later blocks)
			*/buster | */stretch | */jessie)
				# buildpack-deps already includes libssl-dev
				sed -ri -e '/libssl-dev/d' "$dir/Dockerfile"
				;;
		esac

		case "$v" in
			windows/*-1803)
				travisEnv='\n    - os: windows\n      dist: 1803-containers\n      env: VERSION='"$version VARIANT=$v$travisEnv"
				;;

			windows/*-1809) ;; # no AppVeyor support for 1809 yet: https://github.com/appveyor/ci/issues/1885 and https://github.com/appveyor/ci/issues/2676

			windows/*)
				appveyorEnv='\n    - version: '"$version"'\n      variant: '"$variant$appveyorEnv"
				;;

			*)
				travisEnv='\n    - os: linux\n      env: VERSION='"$version VARIANT=$v$travisEnv"
				;;
		esac
	done
done
