# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

URELEASE="zesty"
inherit autotools eutils ubuntu-versionator

UURL="mirror://unity/pool/main/u/${PN}"

DESCRIPTION="Desktop services daemon used by the Unity desktop"
HOMEPAGE="http://upstart.ubuntu.com/"
SRC_URI="${UURL}/${PN}_${PV}.orig.tar.gz
	${UURL}/${PN}_${PV}-${UVER}.diff.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+threads"
RESTRICT="mirror"

DEPEND=">=dev-libs/json-c-0.10
	sys-devel/gettext
	sys-libs/libnih[dbus]
	virtual/pkgconfig"

S="${WORKDIR}/${PN}-${PV}"

src_prepare() {
	epatch -p1 "${WORKDIR}/${MY_P}-${UVER}.diff"	# This needs to be applied for the debian/ directory to be present #
	ubuntu-versionator_src_prepare

	# Ensure build compatibility with all current versions of sys-libs/glibc including 2.25 #
	sed -e '/#include <sys\/types.h>/a #include <sys\/sysmacros.h>' \
		-i init/{main,system}.c
	eautoreconf
}

src_configure() {
	## Gentoo does not allow /sbin or /usr/sbin to be in user's $PATH as Ubuntu does ##
	econf \
		--sbindir=/usr/bin \
		$(use_enable threads threading)
}

src_install() {
	emake DESTDIR="${ED}" install || die "emake install failed"
	dodoc AUTHORS ChangeLog HACKING NEWS README TODO

	## Remove unecessary files colliding with sysvinit, we only need 'upstart --user' to start Unity desktop services ##
	rm -rfv ${ED}usr/share/man/man5
	rm -rv ${ED}usr/share/man/man8/{halt,init,poweroff,reboot,restart,runlevel,shutdown,telinit}.8
	rm -rv ${ED}usr/share/man/man7/runlevel.7
	rm -rv ${ED}usr/bin/{halt,init,poweroff,reboot,runlevel,shutdown,telinit}

	insinto /etc/init/
	doins debian/conf/*.conf

	insinto /usr/share/upstart/sessions/
	rm debian/user-conf/logrotate.conf	# Gentoo does not run logrotate as a user process
	doins debian/user-conf/*.conf
	doins "${FILESDIR}/dbus.conf"
	doins "${FILESDIR}/notify-cgmanager.conf"

	exeinto /usr/bin
	newexe init/init upstart

	insinto /usr/share/man/man8
	newins init/man/init.8 upstart.8

	exeinto /etc/X11/xinit/xinitrc.d
	newexe "${FILESDIR}/99upstart-systemd" 99unity-session_systemd

	insinto /usr/share/upstart/systemd-session/upstart
	doins debian/systemd-graphical-session.conf

	# disable job due to Unity logout lag
	mv ${ED}usr/share/upstart/sessions/upstart-dconf-bridge.conf{,.disabled}

	prune_libtool_files --modules
}

pkg_postinst() {
	elog
	elog "Following job is disabled by default due to Unity logout lag:"
	elog
	elog "/usr/share/upstart/sessions/upstart-dconf-bridge.conf"
	elog
	elog "To enable this job, simply remove extension '.disabled'"
	elog
}
