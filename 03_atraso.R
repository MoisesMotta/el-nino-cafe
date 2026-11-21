# =============================================================
# 03 - Com quantos meses de atraso o preço do café reage ao El Niño?
# Entrada: dados/base_cafe_oni.csv
# Saída:   figuras/correlacao_atraso.png
# =============================================================

base <- read.csv("dados/base_cafe_oni.csv")
base$DATA <- as.Date(base$DATA)
base <- base[order(base$DATA), ]

# Preço "k" meses depois de cada mês
adiantar <- function(x, k) c(x[-(1:k)], rep(NA, k))

# Variação do preço (US$) nos 6 e 12 meses seguintes, por fase do mês de partida
base$VAR_6M  <- (adiantar(base$PRECO_USD, 6)  / base$PRECO_USD - 1) * 100
base$VAR_12M <- (adiantar(base$PRECO_USD, 12) / base$PRECO_USD - 1) * 100
print(aggregate(cbind(VAR_6M, VAR_12M) ~ FASE, data = base, FUN = mean))

# Correlação entre o ONI e a variação do preço k meses depois (k = 1 a 36)
atrasos <- 1:36
correl <- sapply(atrasos, function(k) {
  var_k <- (adiantar(base$PRECO_USD, k) / base$PRECO_USD - 1) * 100
  cor(base$ANOM, var_k, use = "complete.obs")
})

cat("Maior correlação:", round(max(correl), 3),
    "com", atrasos[which.max(correl)], "meses de atraso\n")

desenhar <- function() {
  barplot(correl, names.arg = atrasos, col = "darkorange",
          main = "El Niño x variação do preço do café nos meses seguintes",
          xlab = "Meses depois", ylab = "Correlação")
}
desenhar()
png("figuras/correlacao_atraso.png", width = 1600, height = 900, res = 200)
desenhar()
dev.off()
