#!/bin/bash

# Exibe mensagens no terminal com destaque
echo "🔧 Instalando dependência: rich..."
pip install --user rich

# Caminho do arquivo de configuração do shell
SHELL_RC="$HOME/.bashrc"

# Cria o alias se ainda não existir
if ! grep -q "alias md=" "$SHELL_RC"; then
    echo "🔗 Criando alias 'md' no $SHELL_RC..."
    echo "alias md='python3 -m rich.markdown'" >> "$SHELL_RC"
else
    echo "✅ Alias 'md' já existe em $SHELL_RC"
fi

# Recarrega o arquivo de configuração
echo "🔄 Recarregando configuração do shell..."
source "$SHELL_RC"

echo "✅ Instalação concluída! Agora você pode usar:"
echo ""
echo "    md README.md"
echo ""
echo "para visualizar arquivos Markdown no terminal 😎"
