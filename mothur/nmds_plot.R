library(ggplot2)
library(vegan) # ecological diversity analysis
library(dplyr)

# Read metadata:
metadata = read.table(file="./metadatos.csv", sep=",", header=TRUE)

# Read matrix distance:
nmds<-read.table(file="stability.opti_mcc.thetayc.0.03.lt.ave.nmds.axes", header=T)
names(nmds)[names(nmds) == "group"] <- "ID"

# Join distance matrix and metadata:
metadata_nmds <- inner_join(metadata, nmds)

# Plot NMDS:
pdf("nmds.pdf")
plot(metadata_nmds$axis2~metadata_nmds$axis1, col=c('green', 'orange', 'blue', 'pink')[metadata_nmds$TYPE], xlab="NMDS 1", ylab="NMDS 2", pch=16,
     cex=1)
legend("bottomright", legend=c("Control", "Untreated", "Interferon", "Copaxone"), pch=16, cex=0.65, col=c('green', 'orange', 'blue', 'pink'))
dev.off()
