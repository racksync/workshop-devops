# Create virtual environment if it doesn't exist
if (-not (Test-Path -Path "venv")) {
    Write-Host "Creating virtual environment..."
    python -m venv venv
}

# Activate virtual environment
Write-Host "Activating virtual environment..."
.\venv\Scripts\Activate.ps1

# Install dependencies
Write-Host "Installing dependencies..."
pip install -r requirements.txt

# Run migrations
Write-Host "Running migrations..."
python manage.py migrate

Write-Host "Setup complete! The virtual environment is now active."
Write-Host "Run 'python manage.py runserver' to start the development server."
