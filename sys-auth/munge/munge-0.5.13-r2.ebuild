# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools prefix tmpfiles

DESCRIPTION="An authentication service for creating and validating credentials"
HOMEPAGE="https://github.com/dun/munge"
SRC_URI="https://github.com/dun/munge/releases/download/munge-${PV}/munge-${PV}.tar.xz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~alpha amd64 ~hppa ~ia64 ~mips ppc ppc64 ~riscv sparc x86"
IUSE="debug gcrypt static-libs"

DEPEND="
	app-arch/bzip2
	sys-libs/zlib
	gcrypt? ( dev-libs/libgcrypt:0 )
	!gcrypt? ( dev-libs/openssl:0= )
"
RDEPEND="
	${DEPEND}
	acct-group/munge
	acct-user/munge
"

src_prepare() {
	default

	hprefixify config/x_ac_path_openssl.m4

	eautoreconf
}

src_configure() {
	local myeconfargs=(
		--localstatedir=/var
		--with-crypto-lib=$(usex gcrypt libgcrypt openssl)
		$(use_enable debug)
		$(use_enable static-libs static)
	)

	econf "${myeconfargs[@]}"
}

src_install() {
	local d

	default

	if [ -d "${D}"/var ]; then
		rm -rf "${D}"/var || die
	fi

	for d in "init.d" "default" "sysconfig"; do
		if [ -d "${ED}"/etc/${d} ]; then
			rm -r "${ED}"/etc/${d} || die
		fi
	done

	if ! use static-libs; then
		find "${D}" -name '*.la' -delete || die
	fi
}

pkg_postinst() {
	tmpfiles_process munge.conf
}