using BinaryBuilder

# Collection of sources required to build WCSLIB
sources = [
    "ftp://ftp.atnf.csiro.au/pub/software/wcslib/wcslib-5.18.tar.bz2" =>
    "b693fbf14f2553507bc0c72bca531f23c59885be8f7d3c3cb889a5349129509a",

]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir
cd wcslib-5.18
# configure.ac uses the AC_CANONICAL_BUILD macro when it really should be using AC_CANONICAL_TARGET
chmod +w configure.ac
patch configure.ac <<EOF 
23,24c23,24
< AC_CANONICAL_BUILD
< ARCH="\${build_cpu}-\$build_os"
---
> AC_CANONICAL_TARGET
> ARCH="\${target_cpu}-\$target_os"
241c241
<   case "\$build_os" in
---
>   case "\$target_os" in
249c249
<     case "\$build_cpu" in
---
>     case "\$target_cpu" in
EOF
autoconf
# mingw defines a wcsset function that clashes with a definition in libwcs, setting -DNO_OLDNAMES deletes the mingw one
if [[ "${target}" == *mingw* ]]; then
    ./configure --prefix=$prefix --host=$target --disable-fortran --without-cfitsio --without-pgplot --disable-utils CFLAGS=-DNO_OLDNAMES
else
    ./configure --prefix=$prefix --host=$target --disable-fortran --without-cfitsio --without-pgplot --disable-utils
fi
make install

"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    BinaryProvider.Linux(:i686, :glibc, :blank_abi),
    BinaryProvider.Linux(:x86_64, :glibc, :blank_abi),
    BinaryProvider.Linux(:aarch64, :glibc, :blank_abi),
    BinaryProvider.Linux(:armv7l, :glibc, :eabihf),
    BinaryProvider.Linux(:powerpc64le, :glibc, :blank_abi),
    BinaryProvider.Linux(:i686, :musl, :blank_abi),
    BinaryProvider.Linux(:x86_64, :musl, :blank_abi),
    BinaryProvider.Linux(:aarch64, :musl, :blank_abi),
    BinaryProvider.Linux(:armv7l, :musl, :eabihf),
    BinaryProvider.MacOS(:x86_64, :blank_libc, :blank_abi),
    BinaryProvider.Windows(:i686, :blank_libc, :blank_abi),
    BinaryProvider.Windows(:x86_64, :blank_libc, :blank_abi)
]

# The products that we will ensure are always built
products(prefix) = [
    LibraryProduct(prefix, "libwcs", :libwcs)
]

# Dependencies that must be installed before this package can be built
dependencies = [
    
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, "WCSLIB", sources, script, platforms, products, dependencies)

