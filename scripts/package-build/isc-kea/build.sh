#!/bin/sh

SRC="isc-kea"

# Fetch debian packaging repo
# orvex: pinned (Kea-3.0.3 tag, no tag exists for 3.0.2) instead of the moving default branch
git clone https://github.com/orvexai-vyos/kea-packaging.git
git -C kea-packaging checkout --detach 86c8d951b593176cfed76dafb2930b2e50f49f67
rm -rf isc-kea/debian
cp -r kea-packaging/debian isc-kea/
rm -rf kea-packaging

cd $SRC

# Determine version from git tag
TAG=$(git describe --tags --exact-match)
VERSION="${TAG#Kea-}"

# Modify debian files, add version, remove docs/manpages and unnecessary packages
sed -i "s/{VERSION}/$VERSION/g" debian/changelog
sed -i 's/{ISC_VERSION}/vyos/g' debian/changelog
sed -i 's/{ISC_VERSION}/vyos/g' debian/rules
sed -i '/meson compile -C build doc/d' debian/rules
sed -i '/meson compile -C build sbom/d' debian/rules
sed -Ei '/^Package: isc-kea-(premium|subscriber)/,/^$/d' debian/control
sed -i '/usr\/share\/man/d' debian/*.install
sed -i '/usr\/share\/doc\/kea/d' debian/*.install
echo "usr/share/doc/kea/*" >> debian/not-installed
echo "usr/share/kea/meson-info/*" >> debian/not-installed
rm -rf debian/isc-kea-doc.install debian/isc-kea-subscriber* debian/isc-kea-premium*

sudo mk-build-deps --install --tool 'apt-get --yes --no-install-recommends'
dpkg-buildpackage -uc -us -tc -b
