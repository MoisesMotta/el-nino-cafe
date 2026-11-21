# =============================================================
# 05 - Mapa: rendimento do café depois de El Niños fortes
# Entrada: dados/cafe_uf.csv (IBGE/SIDRA, tabela 1613, rendimento médio,
#          Café (em grão) Total, por UF, 1996-2025, CSV (US) com códigos)
# Saída:   figuras/mapa_cafe_elnino.png
# =============================================================

library(geobr)
library(sf)
library(ggplot2)

# Ler o CSV do IBGE: pular as 5 linhas de cabeçalho e ler só os 27 estados
cafe_uf <- read.csv("dados/cafe_uf.csv", skip = 5, header = FALSE, nrows = 27,
                    na.strings = "-", encoding = "UTF-8")
names(cafe_uf) <- c("code_state", "UF", paste0("A", 1996:2025))

# Só de 2002 em diante (até 2001 o IBGE media café "em coco", outra unidade)
anos <- 2002:2025
colunas <- paste0("A", anos)
cafe_uf <- cafe_uf[complete.cases(cafe_uf[, colunas]), ]

# Anomalia: rendimento acima/abaixo da linha de tendência do estado (%)
anom <- t(apply(cafe_uf[, colunas], 1, function(rend) {
  tendencia <- fitted(lm(rend ~ anos))
  (rend / tendencia - 1) * 100
}))

longo <- data.frame(row.names = NULL,
  code_state = rep(cafe_uf$code_state, times = length(anos)),
  ANO        = rep(anos, each = nrow(cafe_uf)),
  ANOMALIA   = as.vector(anom)
)

# Principais produtores e safras depois dos El Niños de 2015-16 e 2023-24
principais <- c(11, 29, 31, 32, 33, 35, 41, 52)  # RO, BA, MG, ES, RJ, SP, PR, GO
dados_mapa <- longo[longo$ANO %in% c(2016, 2024) &
                    longo$code_state %in% principais, ]

estados <- read_state(year = 2020, showProgress = FALSE)
mapa <- merge(estados, dados_mapa, by = "code_state")

grafico <- ggplot() +
  geom_sf(data = estados, fill = "grey92", color = "white") +
  geom_sf(data = mapa, aes(fill = ANOMALIA), color = "white") +
  scale_fill_gradient2(low = "#b2182b", mid = "white", high = "#2166ac",
                       midpoint = 0, name = "Rendimento\nvs. tendência (%)") +
  facet_wrap(~ ANO) +
  labs(title = "Rendimento do café depois de El Niños fortes",
       subtitle = "Principais estados produtores — diferença em relação à tendência (2002-2025)",
       caption = "Fonte: IBGE/PAM, tabela 1613") +
  theme_void()

print(grafico)
ggsave("figuras/mapa_cafe_elnino.png", grafico, width = 10, height = 6, dpi = 200)

print(reshape(dados_mapa, idvar = "code_state", timevar = "ANO", direction = "wide"))
