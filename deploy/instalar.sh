#!/usr/bin/env bash
# Instala ou atualiza o Buscador Vitallis na VPS. Rode como root:  sudo bash deploy/instalar.sh
set -euo pipefail

DESTINO=/opt/buscador-vitallis
ORIGEM="$(cd "$(dirname "$0")/.." && pwd)"

command -v python3 >/dev/null || { echo "Instale o Python 3.10+ primeiro."; exit 1; }
python3 -c 'import sys; sys.exit(0 if sys.version_info >= (3, 10) else 1)' \
  || { echo "Precisa de Python 3.10 ou mais novo (encontrado: $(python3 -V))."; exit 1; }

id buscador >/dev/null 2>&1 || useradd --system --home "$DESTINO" --shell /usr/sbin/nologin buscador

mkdir -p "$DESTINO"
cp "$ORIGEM"/app.py "$ORIGEM"/buscar_saloes.py "$ORIGEM"/requirements.txt "$ORIGEM"/*.png "$DESTINO"/
mkdir -p "$DESTINO/.streamlit" && cp "$ORIGEM"/.streamlit/config.toml "$DESTINO/.streamlit/"

[ -d "$DESTINO/venv" ] || python3 -m venv "$DESTINO/venv"
"$DESTINO/venv/bin/pip" install -q --upgrade pip
"$DESTINO/venv/bin/pip" install -q -r "$DESTINO/requirements.txt"
chown -R buscador:buscador "$DESTINO"

if [ ! -f /etc/buscador-vitallis.env ]; then
  cp "$ORIGEM/deploy/buscador-vitallis.env.exemplo" /etc/buscador-vitallis.env
  chmod 600 /etc/buscador-vitallis.env
  echo ">> Edite /etc/buscador-vitallis.env e coloque a GOOGLE_MAPS_API_KEY, depois rode de novo este script."
fi

cp "$ORIGEM/deploy/buscador-vitallis.service" /etc/systemd/system/
systemctl daemon-reload
systemctl enable --now buscador-vitallis
systemctl restart buscador-vitallis
sleep 3
systemctl --no-pager --lines=5 status buscador-vitallis || true
curl -fsS http://127.0.0.1:8501/buscador/_stcore/health && echo "  <- serviço respondendo"
echo ">> Falta só configurar o nginx ou Apache (veja deploy/LEIAME_VPS.md)."
