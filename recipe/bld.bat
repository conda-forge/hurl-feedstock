:: libxml Rust crate (patched, see meta.yaml) discovers libxml2 through pkg-config (no LIBXML2 env var).
set "PKG_CONFIG_PATH=%LIBRARY_PREFIX%\lib\pkgconfig"
:: bindgen (used by libxml crate) needs libclang from the build env.
set "LIBCLANG_PATH=%BUILD_PREFIX%\Library\bin"

:: Check licenses
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

:: Build
cargo install --locked --root "%LIBRARY_PREFIX%" --path packages/hurl || goto :error
cargo install --locked --root "%LIBRARY_PREFIX%" --path packages/hurlfmt || goto :error

:: Remove extra build files
del /F /Q %LIBRARY_PREFIX%\.crates.toml
del /F /Q %LIBRARY_PREFIX%\.crates2.json

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
