# Buscador Vitallis

App web (Streamlit) para buscar salões de beleza no município do Rio de Janeiro por CEP, endereço ou bairro,
com lista, mapa e download em Excel/CSV. Dados da Google Places API (New).

## Rodar localmente
    pip install -r requirements.txt
    GOOGLE_MAPS_API_KEY=sua_chave streamlit run app.py

## Publicar no Streamlit Community Cloud (grátis)
1. Suba esta pasta para um repositório no GitHub.
2. Em https://share.streamlit.io clique em **Create app**, escolha o repositório e o arquivo `app.py`.
3. Em **Advanced settings > Secrets**, cole:

        GOOGLE_MAPS_API_KEY = "sua_chave"
        MAX_BUSCAS_DIA = 15
        # APP_SENHA = "opcional, exige senha para usar"

## Controle de custo
- Resultados ficam em cache por 6 horas: repetir a mesma busca não gasta cota.
- `MAX_BUSCAS_DIA` limita as buscas novas por dia, somando todos os usuários (padrão 15, cerca de 1.000 consultas/mês no pior caso, dentro da cota gratuita).
- Recomendado também: alerta de orçamento no Google Cloud e chave restrita à Places API (New).
