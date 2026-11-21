# =============================================================
# 02 - Preço do café arábica (CEPEA/ESALQ) + índice ONI
# Entrada: dados/cafe_cepea.xlsx (baixado do CEPEA e salvo como .xlsx no Excel)
#          dados/oni_tratado.csv
# Saída:   dados/base_cafe_oni.csv
# =============================================================

library(readxl)

# Ler a planilha, pulando as 3 linhas de título do CEPEA
cafe <- read_excel("dados/cafe_cepea.xlsx", skip = 3)
names(cafe) <- c("DATA", "PRECO_RS", "PRECO_USD")

# Converter os tipos (a data pode vir como texto "dd/mm/aaaa")
if (is.character(cafe$DATA)) {
  cafe$DATA <- as.Date(cafe$DATA, format = "%d/%m/%Y")
} else {
  cafe$DATA <- as.Date(cafe$DATA)
}
cafe$PRECO_RS  <- as.numeric(cafe$PRECO_RS)
cafe$PRECO_USD <- as.numeric(cafe$PRECO_USD)
cafe <- cafe[!is.na(cafe$DATA), ]

# Preço diário -> média mensal
cafe$MES <- as.Date(format(cafe$DATA, "%Y-%m-01"))
cafe_mensal <- aggregate(cbind(PRECO_RS, PRECO_USD) ~ MES, data = cafe, FUN = mean)
names(cafe_mensal)[1] <- "DATA"

# Juntar com o ONI pela data
oni <- read.csv("dados/oni_tratado.csv")
oni$DATA <- as.Date(oni$DATA)
base <- merge(cafe_mensal, oni, by = "DATA")

write.csv(base, "dados/base_cafe_oni.csv", row.names = FALSE)

print(head(base))
print(tail(base))
