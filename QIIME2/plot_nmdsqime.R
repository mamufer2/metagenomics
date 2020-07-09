library(vegan)

# Load the distance matrix:
community_matrix = read.csv("distance-matrix.tsv", sep = "\t", row.names = 1)

# Use the function metaMDS to create the object NMDS:
example_NMDS=metaMDS(community_matrix, k=2)

# Read the metadata:
metadata = read.table(file="./metadatos.csv", sep="\t", header=TRUE)

# Select a color by group of study:
color = as.vector(metadata$tipo)

# Plot the NMDS:
pdf("NMDS_qiime.pdf")
plot(example_NMDS)
points(example_NMDS, cex = 1, pch=16, col = color)
legend("bottomright", legend=c("control", "untreated", "interferon", "copaxone"), pch=16, cex=0.65, col=c('green', 'orange', 'blue', 'pink'))
dev.off()


