# test.ps1

& .\scripts\build.ps1

if ( $LASTEXITCODE -ne 0 ) {
    exit $LASTEXITCODE
}

pytest -v .\tests\ @args