# Remove previous environment if it exists
if (Test-Path "env") {
    Remove-Item -Recurse -Force env
    Write-Host "Previous virtual environment removed."
}

# Create a new virtual environment
python -m venv env
Write-Host "Virtual environment created."

# Activate the virtual environment in this script
# (only works when you run it manually, not from VS Code by default)
& .\env\Scripts\Activate.ps1

# Install requirements if the file exists
if (Test-Path ".\backend\requirements.txt") {
    pip install -r .\backend\requirements.txt
    Write-Host "Dependencies installed from requirements.txt"
} else {
    Write-Host "requirements.txt not found"
}
