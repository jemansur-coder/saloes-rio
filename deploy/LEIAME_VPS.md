# Instalação do Buscador Vitallis na VPS

Resultado final: o buscador fica em **https://www.vitallisprofissionalrj.com.br/buscador/**,
rodando no próprio servidor, sem depender do Streamlit Cloud.

Como funciona: o app (Python/Streamlit) roda como serviço do sistema na porta 8501, só acessível
localmente (127.0.0.1). O nginx ou Apache do site repassa o caminho `/buscador/` para ele.

## Requisitos
- Linux com systemd e acesso root (VPS da HostGator atende).
- Python 3.10 ou mais novo (`python3 -V`). Em CentOS/AlmaLinux antigos, instale `python3.11`.
- Chave da Google Places API (New). Peça ao Mansur. **Nunca coloque a chave no código ou no Git.**

## Passo a passo
1. Baixe o código no servidor:

       git clone https://github.com/jemansur-coder/saloes-rio.git /root/saloes-rio

2. Rode o instalador (cria usuário `buscador`, ambiente Python em `/opt/buscador-vitallis` e o serviço):

       sudo bash /root/saloes-rio/deploy/instalar.sh

3. Na primeira vez ele cria `/etc/buscador-vitallis.env`. Edite, coloque a chave e rode o instalador de novo:

       sudo nano /etc/buscador-vitallis.env
       sudo bash /root/saloes-rio/deploy/instalar.sh

   Deve aparecer `ok  <- serviço respondendo`.

4. Configure o servidor web do site:
   - **nginx**: cole o conteúdo de `deploy/nginx-buscador.conf` dentro do bloco `server { }` do site (o de HTTPS),
     depois `sudo nginx -t && sudo systemctl reload nginx`.
   - **Apache/cPanel**: use `deploy/apache-buscador.conf` dentro do `<VirtualHost *:443>`
     (ou em "Include" do cPanel/WHM), habilite `proxy proxy_http proxy_wstunnel rewrite` e recarregue o Apache.

5. Abra https://www.vitallisprofissionalrj.com.br/buscador/ e faça uma busca por CEP.

## Colocando no portal
- Mais simples: um item de menu ou botão "Encontre um Salão" apontando para `/buscador/`.
- Dentro de uma página existente (mesmo domínio, sem problema de bloqueio):

      <iframe src="/buscador/?embed=true" title="Buscador Vitallis"
              style="width:100%;height:1400px;border:0;border-radius:16px" loading="lazy"></iframe>

## Atualizar para uma nova versão

    cd /root/saloes-rio && git pull && sudo bash deploy/instalar.sh

## Comandos úteis
- Status: `systemctl status buscador-vitallis`
- Logs: `journalctl -u buscador-vitallis -f`
- Reiniciar: `systemctl restart buscador-vitallis`

## Custos e segurança
- A chave fica só em `/etc/buscador-vitallis.env` (permissão 600, dono root).
- `MAX_BUSCAS_DIA` (padrão 15) limita buscas novas por dia somando todos os visitantes; buscas repetidas
  ficam em cache por 6 horas e não gastam cota. O contador zera se o serviço reiniciar.
- No Google Cloud, restrinja a chave à **Places API (New)** e, se quiser, ao IP da VPS
  (Credentials > chave > Application restrictions > IP addresses).
- O Streamlit escuta só em 127.0.0.1: ninguém acessa a porta 8501 de fora.
