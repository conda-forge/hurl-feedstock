#!/usr/bin/env bash
# libxml Rust crate discovers libxml2 through pkg-config (no LIBXML2 env var).
export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig${PKG_CONFIG_PATH:+:${PKG_CONFIG_PATH}}"
# Allow the pkg-config Rust crate to work when cross-compiling (osx-arm64, linux-aarch64, ...).
export PKG_CONFIG_ALLOW_CROSS=1
# bindgen (used by libxml crate) needs libclang from the build env, and the
# target sysroot to resolve system headers.
export LIBCLANG_PATH="${BUILD_PREFIX}/lib"
if [[ -n "${CONDA_BUILD_SYSROOT:-}" ]]; then
  export BINDGEN_EXTRA_CLANG_ARGS="--sysroot=${CONDA_BUILD_SYSROOT} ${BINDGEN_EXTRA_CLANG_ARGS:-}"
fi

# Check licenses
cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY.yml

# Build

# rust-lld has unresolved PPC64 relocation handling issues with curl-sys/libcurl
# on linux-ppc64le; force GNU ld.bfd instead of LLVM lld for linking.
if [[ "${target_platform}" == "linux-ppc64le" ]]; then
  export CARGO_TARGET_POWERPC64LE_UNKNOWN_LINUX_GNU_RUSTFLAGS="-C link-arg=-fuse-ld=bfd"
fi

cargo install --locked --root "$PREFIX" --path packages/hurl
cargo install --locked --root "$PREFIX" --path packages/hurlfmt

# Remove extra build files
rm -f "${PREFIX}/.crates.toml"
rm -f "${PREFIX}/.crates2.json"

# Add the man pages
mkdir -p "${PREFIX}/share/man/man1"
cp docs/manual/{hurl,hurlfmt}.1 "${PREFIX}/share/man/man1"
