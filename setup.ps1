param(
    [Parameter(Mandatory=$true)]
    [string]$SupabaseUrl,
    
    [Parameter(Mandatory=$true)]
    [string]$SupabaseAnonKey
)

Write-Host "Setting up Notes App with Supabase..." -ForegroundColor Green

# Update the config file
$configPath = Join-Path $PSScriptRoot "lib\config\supabase_config.dart"
(Get-Content $configPath) -replace "YOUR_SUPABASE_URL", $SupabaseUrl -replace "YOUR_SUPABASE_ANON_KEY", $SupabaseAnonKey | Set-Content $configPath

Write-Host "Supabase configuration updated!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:"
Write-Host "1. Run the SQL in supabase_setup.sql in your Supabase SQL Editor"
Write-Host "2. Run: flutter pub get"
Write-Host "3. Run: flutter build apk --debug"
