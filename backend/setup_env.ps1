# Elimina entorno anterior si existe
if (Test-Path "env") {
    Remove-Item -Recurse -Force env
    Write-Host "Entorno virtual anterior eliminado."
}

# Crea nuevo entorno virtual
python -m venv env
Write-Host "Entorno virtual creado."

# Activa el entorno virtual en este script (solo funciona si lo ejecutas manualmente, no desde VSCode por defecto)
& .\env\Scripts\Activate.ps1

# Instala requirements si existe
if (Test-Path ".\backend\requirements.txt") {
    pip install -r .\backend\requirements.txt
    Write-Host "Dependencias instaladas desde requirements.txt"
} else {
    Write-Host "No se encontró requirements.txt"
}
