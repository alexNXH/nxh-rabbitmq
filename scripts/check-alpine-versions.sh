#!/bin/bash
set -e

echo "🔍 Vérification des versions disponibles dans Alpine 3.19..."

# Liste des packages à vérifier
PACKAGES="curl tar xz gcc g++ make python3 perl linux-headers ncurses-dev openssl-dev coreutils bash ca-certificates procps su-exec tzdata xmlstarlet openssl ncurses"

echo "📦 Packages à vérifier:"
echo "$PACKAGES" | tr ' ' '\n'

echo ""
echo "📊 Versions disponibles dans Alpine 3.19:"

# Créer un conteneur temporaire pour vérifier les versions
docker run --rm -i alpine:3.19 sh << 'EOF'
apk update > /dev/null 2>&1
for pkg in curl tar xz gcc g++ make python3 perl linux-headers ncurses-dev openssl-dev coreutils bash ca-certificates procps su-exec tzdata xmlstarlet openssl ncurses; do
    version=$(apk search --exact "$pkg" 2>/dev/null | head -1 | cut -d'-' -f2-)
    if [ -n "$version" ]; then
        printf "%-20s: %s\n" "$pkg" "$version"
    else
        printf "%-20s: NON TROUVÉ\n" "$pkg"
    fi
done
EOF

echo ""
echo "💡 Pour épingler des versions spécifiques, utilisez:"
echo "   apk add --no-cache package=\$version"
echo ""
echo "📝 Exemple basé sur les dernières erreurs:"
echo "   curl=8.14.1-r2"
echo "   tar=1.35-r2"
echo "   xz=5.4.5-r1"
echo "   python3=3.11.14-r0"
echo "   perl=5.38.5-r0"
echo "   linux-headers=6.5-r0"
echo "   openssl-dev=3.1.8-r1"
echo "   ca-certificates=20250911-r0"
echo "   tzdata=2025b-r0"
echo "   xmlstarlet=1.6.1-r2"
echo "   openssl=3.1.8-r1"