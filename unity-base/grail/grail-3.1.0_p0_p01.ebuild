# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit autotools eutils ubuntu-versionator

UURL="mirror://ubuntu/pool/main/g/${PN}"
URELEASE="vivid"
UVER_PREFIX="daily13.06.05"

DESCRIPTION="An implementation of the GRAIL (Gesture Recognition And Instantiation Library) interface"
HOMEPAGE="https://launchpad.net/grail"
SRC_URI="${UURL}/${MY_P}${UVER_PREFIX}.orig.tar.gz"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RESTRICT="mirror"

DEPEND=">=sys-devel/gcc-4.6
	sys-libs/mtdev
	unity-base/evemu
	unity-base/frame
	>=x11-libs/libXi-1.5.99.1"

S="${WORKDIR}/${PN}-${PV}${UVER_PREFIX}"

src_prepare() {
	eautoreconf
}

src_install() {
	emake DESTDIR="${D}" install
	prune_libtool_files --modules
}
