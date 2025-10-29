#!/bin/bash
#
# ♿ pdf2md_accessible_flex.sh (versão corrigida)
# Converte PDF → Markdown acessível (.md)
# Detecta automaticamente se o PDF tem texto, imagens ou ambos.
# Usa pdftotext + BLIP (visão computacional local) conforme necessário.
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

# ============================================================
# Funções auxiliares
# ============================================================
install_dependencies() {
    echo "⬇️ Instalando dependências..."
    sudo apt update && sudo apt install -y poppler-utils tesseract-ocr
    pip install --user torch torchvision pillow pdf2image pytesseract transformers
}

extract_images() {
    echo "🖼️ Extraindo imagens do PDF..."
    mkdir -p "${BASENAME}_images"
    pdfimages -png "$PDF" "${BASENAME}_images/img" 2>/dev/null || true
}

# ============================================================
# Verifica se o PDF contém texto
# ============================================================
echo "🔍 Verificando se o PDF contém texto..."
TEMP_TXT=$(mktemp)
pdftotext "$PDF" "$TEMP_TXT" 2>/dev/null
CHAR_COUNT=$(wc -c < "$TEMP_TXT")

# ============================================================
# CASO 1: PDF com texto e/ou imagens
# ============================================================
if [ "$CHAR_COUNT" -gt 50 ]; then
    echo "✅ PDF contém texto. Extraindo conteúdo com pdftotext..."

    # Extrai o texto em formato markdown básico
    pdftotext "$PDF" - | sed '/^[[:space:]]*$/d' > "$OUTPUT"

    # Extrai imagens
    extract_images

    # Se tiver imagens, gerar descrições automáticas com BLIP
    if ls "${BASENAME}_images"/*.png >/dev/null 2>&1; then
        install_dependencies

        echo "🧠 Gerando descrições automáticas das imagens com BLIP..."
        PY_SCRIPT=$(mktemp /tmp/pdf2md_blipXXXX.py)

        cat <<'EOF' > "$PY_SCRIPT"
from transformers import BlipProcessor, BlipForConditionalGeneration
from PIL import Image
import os, glob

processor = BlipProcessor.from_pretrained("Salesforce/blip-image-captioning-base")
model = BlipForConditionalGeneration.from_pretrained("Salesforce/blip-image-captioning-base")

img_dir = os.getenv("IMG_DIR")
md_path = os.getenv("MD_FILE")

with open(md_path, "a", encoding="utf-8") as f:
    f.write("\n\n---\n\n## 🖼️ Descrições automáticas de imagens\n\n")

    for img_path in sorted(glob.glob(os.path.join(img_dir, "*.png"))):
        try:
            image = Image.open(img_path)
            inputs = processor(image, return_tensors="pt")
            out = model.generate(**inputs, max_length=40)
            caption = processor.decode(out[0], skip_special_tokens=True)
            f.write(f"![{caption}]({img_path})\n\n")
            print(f"✅ {os.path.basename(img_path)} → {caption}")
        except Exception as e:
            print(f"⚠️ Erro ao processar {img_path}: {e}")
EOF

        IMG_DIR="${BASENAME}_images" MD_FILE="$OUTPUT" python3 "$PY_SCRIPT"
        rm -f "$PY_SCRIPT"
    else
        echo "ℹ️ Nenhuma imagem encontrada no PDF."
    fi

    echo "🎉 Conversão concluída: $OUTPUT"

# ============================================================
# CASO 2: PDF escaneado — OCR + BLIP
# ============================================================
else
    echo "⚙️ PDF parece ser escaneado (sem texto). Usando OCR + BLIP..."
    install_dependencies

    PY_SCRIPT=$(mktemp /tmp/pdf2md_ocr_blipXXXX.py)

    cat <<'EOF' > "$PY_SCRIPT"
from pdf2image import convert_from_path
from transformers import BlipProcessor, BlipForConditionalGeneration
import pytesseract
from PIL import Image
import os, sys

pdf_path = sys.argv[1]
basename = os.path.splitext(pdf_path)[0]
output_md = f"{basename}.md"

print("🧠 Carregando modelo BLIP...")
processor = BlipProcessor.from_pretrained("Salesforce/blip-image-captioning-base")
model = BlipForConditionalGeneration.from_pretrained("Salesforce/blip-image-captioning-base")

print("📄 Convertendo PDF em imagens...")
pages = convert_from_path(pdf_path)
texto_md = ""

for i, page in enumerate(pages):
    page_img = f"{basename}_page{i+1}.png"
    page.save(page_img, "PNG")

    texto = pytesseract.image_to_string(page)
    texto_md += f"# Página {i+1}\n\n{texto.strip()}\n\n"

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

# Limpeza
rm -f "$TEMP_TXT"
