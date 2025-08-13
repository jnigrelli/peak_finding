# build.ps1
param (
    [switch]$annotate = $false
)

if ( $annotate )
{
    python.exe .\setup.py --annotate build_ext --inplace
}
else
{
    python.exe .\setup.py build_ext --inplace
}