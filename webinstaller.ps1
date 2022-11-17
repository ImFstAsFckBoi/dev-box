where.exe git > nul 2> nul; $has_git = $?
where.exe docker > nul 2> nul; $has_docker = $?
where.exe docker-compose > nul 2> nul; $has_dcompose = $?

Remove-Item -Path "$env:TEMP\dev-box\" -Recurse -Force -ErrorAction SilentlyContinue > nul 2> nul

if ( !( $has_docker -and $has_dcompose ) ) {
    Write-Error "Docker and/or Docker-Compose is not installed."
    Write-Host "Install it and then run this command again."
    Write-Host "Get it here -> https://www.docker.com/products/docker-desktop/"
    Exit 1
}

$old_dir = Get-Location

New-Item -Path "$env:TEMP\dev-box\" -ItemType Directory -ErrorAction SilentlyContinue > nul 2> nul
Set-Location -Path $env:TEMP\dev-box\

if ( $has_git) {
    # Download with git
    Write-Host "Detected git installation"
    Write-Host "Cloning git repo........." -NoNewline
    git clone https://github.com/ImFstAsFckBoi/dev-box.git > nul 2>nul
    Write-Host "DONE!"
} else {
    # Download with curl
    Write-Host "No git installation detected, using curl instead"
    
    Write-Host "Downloading git repo....." -NoNewline
    curl -fsSLO "https://github.com/ImFstAsFckBoi/dev-box/archive/refs/heads/master.zip" > nul 2> nul

    if ( -not $? ) {
        Write-Host "FAILED!"
        Write-Error "Failed to download repo with command 'curl -fsSLO `"https://github.com/ImFstAsFckBoi/dev-box/archive/refs/heads/master.zip`"'"
    }

    Write-Host "DONE!"

    Write-Host "Unpacking zip-archive...." -NoNewline
    Expand-Archive -Path ".\master.zip" -Force -ErrorAction Stop
    Write-Host "DONE!"

    Set-Location -Path ".\master\" -ErrorAction Stop
    Rename-Item -Path ".\dev-box-master" -NewName "dev-box" -ErrorAction SilentlyContinue
}

Set-Location -Path ".\dev-box" -ErrorAction Stop


if ( (docker-compose ls --all | findstr "dev-box") ) {
    Write-Host "Stopping old container..." -NoNewline
    docker-compose down > nul 2> nul
    Write-Host "DONE!"
}

Write-Host "Starting container......." -NoNewline
docker-compose up --build -d > nul
Write-Host "DONE!"


if ( -not $? ) {
    Write-Host "FAILED!"
    Write-Error "Failed to bring up container with command 'docker-compose up -d'"
}

Set-Location $old_dir

