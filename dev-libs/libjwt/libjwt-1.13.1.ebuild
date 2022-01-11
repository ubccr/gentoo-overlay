# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools eutils toolchain-funcs

DESCRIPTION="JWT C Library"
HOMEPAGE="https://github.com/benmcollins/libjwt"
SRC_URI="https://github.com/benmcollins/${PN}/archive/refs/tags/v${PV}.tar.gz"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64"

RDEPND="
	dev-libs/openssl:0=
"

DEPEND="
	${RDEPEND}
	dev-libs/jansson
"

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	econf
}
