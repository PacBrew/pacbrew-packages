#!/bin/bash

set -e

b() {
    scp $1/*.pkg.tar.gz cpasjuste@mydedibox.fr:/var/www/pacbrew/packages/
    pacbrew-repo-add pacbrew-repo/pacbrew.db.tar.gz $1/*.pkg.tar.gz
}

rm -rf pacbrew-repo
mkdir -p pacbrew-repo
. pacbrew-packages.sh
scp pacbrew-repo/* cpasjuste@mydedibox.fr:/var/www/pacbrew/packages/
rm -rf pacbrew-repo
