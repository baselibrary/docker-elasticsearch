#!/bin/bash
set -e

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

versions=( "$@" )
if [ ${#versions[@]} -eq 0 ]; then
	versions=( */ )
fi
versions=( "${versions[@]%/}" )


for version in "${versions[@]}"; do	
  if [ "${version%%.*}" -ge 2 ]; then
  	repoVersion="${version%%.*}.x"
  	repoPackage="http://packages.elastic.co/elasticsearch/${repoVersion}/debian/dists/stable/main/binary-amd64/Packages.gz"
  	fullVersion="$(curl -fsSL "${repoPackage}" | gunzip | awk -v pkgname="elasticsearch" -F ': ' '$1 == "Package" { pkg = $2 } pkg == pkgname && $1 == "Version" { print $2 }' | grep "^$version" | sort -rV | head -n1 )"
  else
  	repoVersion="${version}"
  	repoPackage="http://packages.elastic.co/elasticsearch/${repoVersion}/debian/dists/stable/main/binary-amd64/Packages.gz"
  	fullVersion="$(curl -fsSL "${repoPackage}" | gunzip | awk -v pkgname="elasticsearch" -F ': ' '$1 == "Package" { pkg = $2 } pkg == pkgname && $1 == "Version" { print $2 }' | grep "^$version" | sort -rV | head -n1 )"
  fi
	(
		set -x
		cp docker-entrypoint.sh "$version/"
		sed '
			s/%%ELASTICSEARCH_MAJOR%%/'"$version"'/g;
			s/%%ELASTICSEARCH_VERSION%%/'"$fullVersion"'/g;
			s!%%REPO%%!'"$repoVersion"'!g;
		' Dockerfile.template > "$version/Dockerfile"
	)
done
