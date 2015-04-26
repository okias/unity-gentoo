# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
PYTHON_COMPAT=( python2_7 )
PYTHON_REQ_USE="xml"
GCONF_DEBUG="no"

URELEASE="vivid"
inherit eutils gnome2 python-single-r1 toolchain-funcs ubuntu-versionator

UVER="2.2"

DESCRIPTION="Introspection infrastructure for generating gobject library bindings for various languages"
HOMEPAGE="http://live.gnome.org/GObjectIntrospection/"
LICENSE="LGPL-2+ GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="cairo doctool test"

RDEPEND="
	>=dev-libs/gobject-introspection-common-${PV}
	>=dev-libs/glib-2.36:2
	doctool? ( dev-python/mako )
	virtual/libffi:=
	!<dev-lang/vala-0.20.0
"

# Wants real bison, not virtual/yacc
DEPEND="${RDEPEND}
	>=dev-util/gtk-doc-am-1.15
	sys-devel/bison
	sys-devel/flex
	virtual/pkgconfig
	${PYTHON_DEPS}
"
# PDEPEND to avoid circular dependencies, bug #391213
PDEPEND="cairo? ( x11-libs/cairo[glib] )"

pkg_setup() {
	ubuntu-versionator_pkg_setup
	python-single-r1_pkg_setup
}

src_prepare() {
	# To prevent crosscompiling problems, bug #414105
	CC=$(tc-getCC)

	DOCS="AUTHORS CONTRIBUTORS ChangeLog NEWS README TODO"
	gnome2_src_prepare

	# avoid GNU-isms
	sed -i -e 's/\(if test .* \)==/\1=/' configure || die

	if ! has_version "x11-libs/cairo[glib]"; then
		# Bug #391213: enable cairo-gobject support even if it's not installed
		# We only PDEPEND on cairo to avoid circular dependencies
		export CAIRO_LIBS="-lcairo -lcairo-gobject"
		export CAIRO_CFLAGS="-I${EPREFIX}/usr/include/cairo"
	fi
}
src_configure(){
	gnome2_src_configure \
		--disable-static \
		YACC=$(type -p yacc) \
		$(use_with cairo) \
		$(use_enable doctool)
}

src_install() {
	gnome2_src_install

	# Prevent collision with gobject-introspection-common
	rm -v "${ED}"usr/share/aclocal/introspection.m4 \
		"${ED}"usr/share/gobject-introspection-1.0/Makefile.introspection || die
	rmdir "${ED}"usr/share/aclocal || die
}
