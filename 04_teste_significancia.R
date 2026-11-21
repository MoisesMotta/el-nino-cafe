# =============================================================
# 04 - O padrão é real ou sorte? Teste com "calendários girados"
# Entrada: dados/base_cafe_oni.csv
# Saída:   figuras/teste_significancia.png
# =============================================================

base <- read.csv("dados/base_cafe_oni.csv")
base$DATA <- as.Date(base$DATA)
base <- base[order(base$DATA), ]
adiantar <- function(x, k) c(x[-(1:k)], rep(NA, k))

# Variações do preço para cada atraso de 1 a 36 meses
atrasos <- 1:36
variacoes <- sapply(atrasos, function(k)
  (adiantar(base$PRECO_USD, k) / base$PRECO_USD - 1) * 100)

# Maior correlação entre um índice e as variações
maior_correl <- function(indice) {
  max(apply(variacoes, 2, function(v) cor(indice, v, use = "complete.obs")))
}

real <- maior_correl(base$ANOM)

# Giramos o calendário do El Niño 1000 vezes (mesmo formato, datas erradas)
set.seed(42)
n <- length(base$ANOM)
falsos <- replicate(1000, {
  desloc <- sample(36:(n - 36), 1)
  girado <- c(base$ANOM[(desloc + 1):n], base$ANOM[1:desloc])
  maior_correl(girado)
})

p_valor <- mean(falsos >= real)
cat("Correlação real:", round(real, 3), "\n")
cat("Correlação típica no acaso:", round(median(falsos), 3), "\n")
cat("p-valor:", round(p_valor, 3), "\n")

desenhar <- function() {
  hist(falsos, breaks = 30, col = "grey80",
       main = "Correlação real x 1000 calendários aleatórios",
       xlab = "Maior correlação encontrada")
  abline(v = real, col = "darkorange", lwd = 3)
}
desenhar()
png("figuras/teste_significancia.png", width = 1600, height = 900, res = 200)
desenhar()
dev.off()
