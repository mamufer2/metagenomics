library("dplyr")
library("tidyr") 
library("readxl")
library("stringr")
library("ggplot2")

# Read metadata:

metadata = read.table(file="./metadatos.csv", sep="\t", header=TRUE)

# Read distance matrix and select the columns with coordinates of axis:
rarefy <- read.table(file="./stability.opti_mcc.groups.rarefaction", sep="\t", header=TRUE) %>%
  select(-contains("lci."), -contains("hci.")) %>%
  pivot_longer(cols=c(-numsampled), names_to='ID', values_to='sobs') %>%
  mutate(ID=str_replace_all(ID, pattern="X0.03.", replacement="")) %>%
  drop_na()

# Join metadata and positions in axis:
metadata_rarefy <- inner_join(metadata, rarefy)

# Plot rarefaction curves:
pdf("rarefaction_influenza.pdf")
ggplot(metadata_rarefy, aes(x=numsampled, y=sobs, group=ID)) +
  geom_line()
dev.off()

# Do the same with the chao measure:
rarefy_chao <- read.table(file="./stability.opti_mcc.groups.r_chao", sep="\t", header=TRUE) %>%
  select(-contains("lci."), -contains("hci.")) %>%
  pivot_longer(cols=c(-numsampled), names_to='ID', values_to='chao') %>%
  mutate(ID=str_replace_all(ID, pattern="X0.03.", replacement="")) %>%
  drop_na()
rarefy_chao[, c(2)] <- sapply(rarefy_chao[, c(2)], as.numeric)
metadata_rarefy_chao <- inner_join(metadata, rarefy_chao)

pdf("rarefaction_influenza_chao.pdf")
ggplot(metadata_rarefy_chao, aes(x=numsampled, y=chao, group=ID)) +
  geom_line()
dev.off()

