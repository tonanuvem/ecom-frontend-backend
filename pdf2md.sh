#!/bin/bash
#
# ♿ pdf2md_accessible.sh
# Converte PDF → Markdown acessível (.md) com descrição automática de imagens.
# Usa Pandoc se o PDF tiver texto, e OCR + BLIP (visão computacional local) se for escaneado.
# Requer: Python 3, pip, poppler-utils, tesseract, torch, transformers, pillow, pdf2image
#

set -e

if [ -z "$1" ]; then
    echo "❌ Uso: $0 arquivo.pdf"
    exit 1
fi

PDF="$1"
BASENAME=$(basename "$PDF" .pdf)
OUTPUT="${BASENAME}.md"

if [ ! -f "$PDF" ]; then
    echo "❌ Arquivo '$PDF' não encontrado!"
    exit 1
fi

echo "🔍 Verificando se o PDF contém texto..."
TEMP_TXT=$(mktemp)
pdftotext "$PDF" "$TEMP_TXT" 2>/dev/null
CHAR_COUNT=$(wc -c < "$TEMP_TXT")
rm -f "$TEMP_TXT"

# Função auxiliar para instalar dependências se necessário
install_dependencies() {
    echo "⬇️ Instalando dependências..."
    sudo apt update && sudo apt install -y poppler-utils tesseract-ocr
    pip install --user torch torchvision pillow pdf2image pytesseract transformers
}

# ============================================================
# CASO 1: PDF com texto — usar Pandoc
# ============================================================
if [ "$CHAR_COUNT" -gt 50 ]; then
    echo "✅ PDF contém texto. Convertendo via Pandoc..."

    if ! command -v pandoc &> /dev/null; then
        echo "⬇️ Instalando pandoc..."
        sudo apt update && sudo apt install -y pandoc
    fi

    pandoc "$PDF" -t markdown -o "$OUTPUT"
    echo "🎉 Conversão concluída: $OUTPUT"

# ============================================================
# CASO 2: PDF escaneado — OCR + BLIP
# ============================================================
else
    echo "⚙️ PDF parece ser escaneado (imagens). Usando OCR + BLIP..."

    install_dependencies

    # Cria script Python temporário para OCR + BLIP
    PY_SCRIPT=$(mktemp /tmp/pdf2md_blipXXXX.py)

    cat << 'EOF' > "$PY_SCRIPT"
from pdf2image import convert_from_path
from transformers import BlipProcessor, BlipForConditionalGeneration
import pytesseract
from PIL import Image
import os, sys

pdf_path = sys.argv[1]
basename = os.path.splitext(pdf_path)[0]
output_md = f"{basename}.md"

print("🧠 Carregando modelo BLIP (Salesforce/blip-image-captioning-base)...")
processor = BlipProcessor.from_pretrained("Salesforce/blip-image-captioning-base")
model = BlipForConditionalGeneration.from_pretrained("Salesforce/blip-image-captioning-base")

print("📄 Convertendo PDF em imagens...")
pages = convert_from_path(pdf_path)
texto_md = ""

for i, page in enumerate(pages):
    page_img = f"{basename}_page{i+1}.png"
    page.save(page_img, "PNG")

    # Extrai texto com OCR
    texto = pytesseract.image_to_string(page)
    texto_md += f"# Página {i+1}\n\n{texto.strip()}\n\n"

    # Gera descrição automática da imagem
    inputs = processor(Image.open(page_img), return_tensors="pt")
    out = model.generate(**inputs, max_length=40)
    caption = processor.decode(out[0], skip_special_tokens=True)

    texto_md += f"![{caption}]({page_img})\n\n"

with open(output_md, "w", encoding="utf-8") as f:
    f.write(texto_md)

print(f"✅ Markdown acessível gerado: {output_md}")
EOF

    python3 "$PY_SCRIPT" "$PDF"
    rm -f "$PY_SCRIPT"
fi
