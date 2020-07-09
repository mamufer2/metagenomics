# Export qza aligned files:

qiime tools export --input-path ./taxonomy_SILVA_138_PE.qza --output-path ./
qiime tools export --input-path ./PE-table.qza --output-path ./

# The first one generates a tsv and the second one a biom file. 

# Convert biom to tsv:
biom convert -i feature-table.biom -o feature-table.tab --to-tsv

# Tranform the output to a Krona file:
python krona_qiime.py ./taxonomy.tsv ./feature-table.tab
ktImportText ./*.txt -o krona_influenza.html
