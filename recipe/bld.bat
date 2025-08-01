:: libxml Rust crate uses LIBXML2 env var to build.
set LIBXML2=%PREFIX%\Library\lib\libxml2.lib

:: Patch libxml 0.3.6 default_binding.rs see <https://github.com/Orange-OpenSource/hurl/issues/4288>
xcopy /E /I /Y "%RECIPE_DIR%\patch\rust-libxml-0.3.6" "%SRC_DIR%\patch\rust-libxml-0.3.6"

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
