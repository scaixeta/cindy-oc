# Arquitetura da Base de Dados Agronômicos — Sentivis

## 1. Visão

Plataforma operacional de dados e inteligência aplicada ao campo — carga sob demanda, atualização orientada pelo uso real.

A Sentivis existe para organizar a leitura da fazenda, conectar sinais do campo a dados confiáveis e apoiar decisões com mais evidência diante do clima, do manejo, da qualidade, da rastreabilidade e do mercado.

---

## 2. Públicos e leitura de valor

| Público | Leitura de valor |
|---|---|
| **Cafeicultor** | Decisão com mais evidência. Leitura integrada de clima, manejo e mercado. Apoio à decisão — não substituição do produtor. |
| **Cooperativa** | Qualificação coletiva da base, rastreabilidade, elevação de padrão documental e inteligência coletiva — respeitando autonomia do produtor. |
| **Investidor direto** | Método, controle operacional, rastreabilidade da execução e validação disciplinada em campo. |

---

## 3. Estratégia de carga de dados

### 3.1 Princípio central

A base de dados **não é preenchida proativamente em massa**.

- Dados são carregados **sob demanda**, quando uma região/município/área entra na operação.
- Dados já existentes **não são recarregados** desnecessariamente.
- Atualização segue **periodicidade proporcional ao uso real** daquelas informações.

### 3.2 Fluxo de carga

```
Estação Cirrus entra na operação (lat/long)
  → Identifica município (IBGE)
    → Verifica se dados já existem para este município
      → Se NÃO existem: carregar zoneamento, solo, clima, produtividade
      → Se JÁ existem: nenhuma ação necessária
        → Verificar se dados precisam de atualização baseado em última carga e frequência de uso
```

### 3.3 Periodicidade de atualização

| Dados | Frequência sugerida | Gatilho |
|---|---|---|
| Zoneamento agrícola | Anual (ciclo Safra) | Uso efetivo pelo agrônomo |
| Clima histórico | Sob demanda / mensal | Nova estação ativa na região |
| Solo | Baixa atualização (anual ou menos) | Entrada de novo município |
| Produtividade | Anual pós-colheita | Uso efetivo |
| Mercado / preço | Mensal ou quinzenal | Dashboard ativo |

---

## 4. Modelo relacional proposto

### 4.1 Cadeia de relacionamento

```
Estação (lat/long)
  └── Município (IBGE)
        ├── Zoneamento (variedades, épocas, riscos)
        ├── Solo (tipo, fertilidade, relevo, altitude)
        ├── Clima histórico (série temporal)
        ├── Produtividade (série temporal por município/ano)
        └── Mercado (preço, exportação — agregado)
```

### 4.2 Tabelas principais

#### `estacoes`
| Campo | Tipo | Descrição |
|---|---|---|
| id | uuid | Identificador da estação |
| nome | varchar | Nome da estação |
| latitude | decimal | Latitude |
| longitude | decimal | Longitude |
| municipio_ibge | int | FK → municipios.ibge |
| data_instalacao | date | Data de entrada na operação |
| status | varchar | ativa/inativa/manutencao |

#### `municipios`
| Campo | Tipo | Descrição |
|---|---|---|
| ibge | int pk | Código IBGE |
| nome | varchar | Nome do município |
| estado | char(2) | UF |
| latitude | decimal | Centroide |
| longitude | decimal | Centroide |
| regiao | varchar | Sul de Minas, Cerrado, etc. |

#### `zoneamento`
| Campo | Tipo | Descrição |
|---|---|---|
| id | uuid | |
| municipio_ibge | int | FK → municipios |
| variedade | varchar | Catuaí, Mundo Novo, Bourbon... |
| epoca_plantio | varchar | Janeiro, Fevereiro... |
| epoca_colheita | varchar | Abril a Agosto... |
| risco_geada | boolean | |
| risco_seca | boolean | |
| risco_excesso_chuva | boolean | |
| altitude_min | int | metros |
| altitude_max | int | metros |

#### `solo`
| Campo | Tipo | Descrição |
|---|---|---|
| id | uuid | |
| municipio_ibge | int | FK → municipios |
| tipo_solo | varchar | Argissolo, Latossolo... |
| ph | decimal | |
| materia_organica_pct | decimal | |
| ctc | decimal | cmolc/dm³ |
| releve | varchar | Plano, ondulado... |
| altitude_min | int | |
| altitude_max | int | |

#### `clima_historico`
| Campo | Tipo | Descrição |
|---|---|---|
| id | uuid | |
| municipio_ibge | int | FK → municipios |
| ano | int | |
| precipitacao_mm | decimal | Chuva acumulada no ciclo |
| temperatura_media | decimal | °C |
| temperatura_min | decimal | °C |
| temperatura_max | decimal | °C |
| umidade_relativa | decimal | % |
| meses_secos | int | Contagem de meses secos |

#### `produtividade`
| Campo | Tipo | Descrição |
|---|---|---|
| id | uuid | |
| municipio_ibge | int | FK → municipios |
| ano | int | |
| producao_sacas | bigint | Sacas |
| area_plantada_ha | decimal | |
| area_colhida_ha | decimal | |
| produtividade_kg_ha | decimal | |
| estado | char(2) | UF (para comparativo) |

#### `mercado`
| Campo | Tipo | Descrição |
|---|---|---|
| id | uuid | |
| ano | int | |
| mes | int | |
| preco_arabica_rmm | decimal | R$/saca 60kg |
| exportar_volume_sacas | bigint | |
| exportar_receita_mi | decimal | US$ milhões |
| tipo | varchar | arabica/robusta |

---

## 5. Fontes de dados

| Dado | Fonte |
|---|---|
| Produção, produtividade, área | Embrapa / IBGE / CONAB |
| Zoneamento agrícola | Embrapa / MAPA |
| Clima histórico | INMET, Embrapa, dados históricos |
| Solo | Embrapa / RADAM |
| Exportação, preço | CONAB, MAPA, BCE |
| Tipo solo, fertilidade | Embrapa Solos |

---

## 6. Escopo Café — MVP

### 6.1 Dados включены no MVP

- Zoneamento por município (variedades, épocas, riscos)
- Clima histórico (precipitação, temperatura, umidade — ciclo)
- Produtividade por município/ano (kg/ha, sacas)
- Solo (tipo predominante, pH, altitude)

### 6.2 Fora do escopo inicial

- Genômica e melhoramento (Biorg)
- Pragas e doenças
- Adubação e nutrição
- Dados de lavoura e pós-colheita
- Aspectos econômicos detalhados (custo de produção)

---

## 7. Próximos passos

- [ ] Validar modelo de dados com agrônomo
- [ ] Definir схема de carga para Embrapa AgroAPI
- [ ] Desenhar pipeline ETL sob demanda
- [ ] Definir métricas de atualização por tabela
- [ ] Iniciar carga para primeiro município piloto
