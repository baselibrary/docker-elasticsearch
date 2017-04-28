#!/bin/bash
set -e

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

versions=( "$@" )
if [ ${#versions[@]} -eq 0 ]; then
	versions=( */ )
fi
versions=( "${versions[@]%/}" )


for version in "${versions[@]}"; do
  if [ "${version%%.*}" -eq 2 ]; then
  	repoPackage="http://packages.elastic.co/elasticsearch/2.x"
  	fullVersion="$(curl -fsSL "${repoPackage}/debian/dists/stable/main/binary-amd64/Packages.gz" | gunzip | awk -v pkgname="elasticsearch" -F ': ' '$1 == "Package" { pkg = $2 } pkg == pkgname && $1 == "Version" { print $2 }' | grep "^$version" | sort -rV | head -n1 )"
  elif [ "${version%%.*}" -eq 5 ]; then
  	repoPackage="http://artifacts.elastic.co/packages/5.x"
  	fullVersion="$(curl -fsSL "${repoPackage}/apt/dists/stable/main/binary-amd64/Packages.gz"    | gunzip | awk -v pkgname="elasticsearch" -F ': ' '$1 == "Package" { pkg = $2 } pkg == pkgname && $1 == "Version" { print $2 }' | grep "^$version" | sort -rV | head -n1 )"
	else
  	repoVersion="${version}"
  	repoPackage="http://packages.elastic.co/elasticsearch/${repoVersion}"
  	fullVersion="$(curl -fsSL "${repoPackage}/debian/dists/stable/main/binary-amd64/Packages.gz" | gunzip | awk -v pkgname="elasticsearch" -F ': ' '$1 == "Package" { pkg = $2 } pkg == pkgname && $1 == "Version" { print $2 }' | grep "^$version" | sort -rV | head -n1 )"
  fi
	(
		set -x
		cp docker-entrypoint.sh "$version/"
		sed '
			s/%%ELASTICSEARCH_MAJOR%%/'"$version"'/g;
			s/%%ELASTICSEARCH_VERSION%%/'"$fullVersion"'/g;
			s!%%ELASTICSEARCH_REPO%%!'"$repoPackage"'!g;
		' Dockerfile.template > "$version/Dockerfile"
	)
done
