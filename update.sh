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
  	repository="http://packages.elastic.co/elasticsearch/${version%%.*}.x/debian"
    fullVersion="$(curl -fsSL "$repository/dists/stable/main/binary-amd64/Packages.gz" | gunzip | awk -v pkgname="elasticsearch" -F ': ' '$1 == "Package" { pkg = $2 } pkg == pkgname && $1 == "Version" { print $2 }' | sort -rV | head -n1 )"
  else
  	repository="http://packages.elastic.co/elasticsearch/$version/debian"
    fullVersion="$(curl -fsSL "$repository/dists/stable/main/binary-amd64/Packages.gz" | gunzip | awk -v pkgname="elasticsearch" -F ': ' '$1 == "Package" { pkg = $2 } pkg == pkgname && $1 == "Version" { print $2 }' | sort -rV | head -n1 )"
	fi
	(
		set -x
		cp docker-entrypoint.sh "$version/"
		sed '
			s/%%ELASTICSEARCH_MAJOR%%/'"$version"'/g;
			s/%%ELASTICSEARCH_VERSION%%/'"$fullVersion"'/g;
			s!%%ELASTICSEARCH_REPOSITORY%%!'"$repository"'!g;
		' Dockerfile.template > "$version/Dockerfile"
	)
done
