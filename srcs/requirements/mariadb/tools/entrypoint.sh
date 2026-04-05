#!/bin/bash
set -e

# Ici, vous pouvez mettre votre logique de configuration
echo "Initialisation du service..."

# À la fin, on lance le sleep infinity pour garder le conteneur ouvert
echo "Configuration terminée. Mise en veille infinie..."
exec sleep infinity