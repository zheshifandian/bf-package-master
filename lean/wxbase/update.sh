#!/bin/bash

set -x

export CURDIR="$(cd "$(dirname $0)"; pwd)"

function update() {
	local type="$1"
	local repo="$2"
	local res="$3"
	local tag ver sha old_hash line commit

	tag="$(curl -H "Authorization: $GITHUB_TOKEN" -sL "https://api.github.com/repos/$repo/releases/latest" | jq -r ".tag_name" | sed 's/v//')"
	[ -n "$tag" ] || return 1

        ver="$(awk -F "PKG_VERSION:=" '{print $2}' "$CURDIR/Makefile" | xargs)"

	[ "$tag" != "$ver" ] || return 2
	
	line="$(awk "/PKG_VERSION:=/ {print NR}" "$CURDIR/Makefile")"
	sed -i -e "$((line))s/PKG_VERSION:=.*/PKG_VERSION:=$tag/" "$CURDIR/Makefile"

	sha="$(curl -sL https://github.com/$repo/releases/download/v$tag/wxWidgets-$tag.tar.bz2 | sha256sum | awk '{print $1}')"
	[ -n "$sha" ] || return 1

	old_hash="$(awk -F "PKG_HASH:=" '{print $2}' "$CURDIR/Makefile" | xargs)"
	line="$(awk "/PKG_HASH:=/ {print NR}" "$CURDIR/Makefile")"	
	[ "$sha" != "$old_hash" ] || return 2
	
	   sed -i -e "$((line))s/PKG_HASH:=.*/PKG_HASH:=$sha/" "$CURDIR/Makefile"

	  commit="$(git ls-remote https://github.com/$repo.git HEAD | cut -f1)"
}

update "wxbase" "wxWidgets/wxWidgets" "wxbase-"$(awk -F "PKG_VERSION:=" '{print $2}' "$CURDIR/Makefile" | xargs)"" 
