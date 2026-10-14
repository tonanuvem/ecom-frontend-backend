#!/bin/bash

set -e

echo "🔧 Instalando visualizador Markdown..."

# Ambiente virtual exclusivo para o Markdown Viewer
VENV_DIR="$HOME/.local/venvs/md-viewer"
SHELL_RC="$HOME/.bashrc"

# Verifica se o Python está disponível
if ! command -v python3 >/dev/null 2>&1; then
    echo "❌ Python 3 não encontrado."
    exit 1
fi

# Cria o ambiente virtual se necessário
if [ ! -x "$VENV_DIR/bin/python" ]; then
    echo "📦 Criando ambiente virtual em $VENV_DIR..."
    python3 -m venv "$VENV_DIR"
fi

# Instala o Rich no ambiente virtual próprio
echo "📦 Instalando rich..."
"$VENV_DIR/bin/python" -m pip install --upgrade pip
"$VENV_DIR/bin/python" -m pip install rich

# Cria um comando md independente do ambiente Python ativo
mkdir -p "$HOME/.local/bin"

cat > "$HOME/.local/bin/md" <<EOF
#!/bin/bash
exec "$VENV_DIR/bin/python" -m rich.markdown "\$@"
EOF

chmod +x "$HOME/.local/bin/md"

# Adiciona ~/.local/bin ao PATH no bashrc, se necessário
if ! grep -Fq 'export PATH="$HOME/.local/bin:$PATH"' "$SHELL_RC"; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$SHELL_RC"
fi

# Remove o alias antigo que apontava para o Python do Ansible
if grep -qE '^[[:space:]]*alias md=' "$SHELL_RC"; then
    sed -i '/^[[:space:]]*alias md=/d' "$SHELL_RC"
fi

export PATH="$HOME/.local/bin:$PATH"
unalias md 2>/dev/null || true
hash -r

echo
echo "✅ Instalação concluída!"
echo "Execute: md README.md"
