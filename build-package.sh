#!/bin/bash -eu

SOURCE=false
BINARY=false

VERSION="$(head -n1 debian/changelog | cut -d' ' -f2 | sed 's#(\([0-9\.]\+\).*#\1#')"

while [[ $# -gt 0 ]]
do
  case $1 in
    --version|-v)
      VERSION=$2
      shift
      ;;
    --source|-s)
      SOURCE=true
      ;;
    --binary|-b)
      BINARY=true
      ;;
    *)
      echo "error: unknown option '$1'" >&2
      exit 255
      ;;
  esac
  shift
done

echo "building tarball" 2>&1
tar --exclude-vcs --exclude='debian' -czvf ../uki-tools_${VERSION}.orig.tar.gz *

if [ "$SOURCE" = 'true' ]; then
  echo "building source package" >&2
  dpkg-buildpackage -S
fi

if [ "$BINARY" = 'true' ]; then
  echo "building binary package" >&2
  dpkg-buildpackage -B
fi

echo "done." 2>&1