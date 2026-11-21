# =============================================================
# 01 - Índice ONI (NOAA): fases do El Niño mês a mês
# Saída: dados/oni_tratado.csv
# =============================================================

url <- "https://www.cpc.ncep.noaa.gov/data/indices/oni.ascii.txt"

# Ler o arquivo: colunas separadas por espaços, primeira linha é o cabeçalho
oni <- read.table(url, header = TRUE)

# Cada "estação" é uma média de 3 meses. Usamos o mês do meio.
mes_central <- c(DJF = 1, JFM = 2, FMA = 3, MAM = 4, AMJ = 5, MJJ = 6,
                 JJA = 7, JAS = 8, ASO = 9, SON = 10, OND = 11, NDJ = 12)
oni$MES  <- mes_central[oni$SEAS]
oni$DATA <- as.Date(paste(oni$YR, oni$MES, 1, sep = "-"))

# Classificar cada mês (limiar de +-0,5 °C)
oni$FASE <- ifelse(oni$ANOM >= 0.5, "El Nino",
            ifelse(oni$ANOM <= -0.5, "La Nina", "Neutro"))

oni <- oni[, c("DATA", "ANOM", "FASE")]
write.csv(oni, "dados/oni_tratado.csv", row.names = FALSE)

print(tail(oni, 10))
print(table(oni$FASE))
