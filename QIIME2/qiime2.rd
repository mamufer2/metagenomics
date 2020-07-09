# As our samples are demultiplexed, first: create the artefact:

qiime tools import \
--type 'SampleData[PairedEndSequencesWithQuality]' \
--input-path ./ \
--input-format CasavaOneEightSingleLanePerSampleDirFmt \
--output-path demux-paired-end.qza



# Then Qiime2 use DADA2 to denoise the sequences:

qiime demux summarize --i-data demux-paired-end.qza --o-visualization demux-paired-end.qzv

# To visualice our artefacts:
qiime tools view demux-paired-end.qzv

qiime dada2 denoise-paired \
--i-demultiplexed-seqs demux-paired-end.qza \
--p-trunc-len-f 230 \
--p-trunc-len-r 210 \
--o-table PE-table.qza \
--o-representative-sequences PE-rep-seqs.qza \
--o-denoising-stats PE-stats.qza

# Create qzvs:

qiime metadata tabulate \
--m-input-file PE-stats.qza \
--o-visualization PE-stats.qzv

qiime feature-table summarize \
--i-table PE-table.qza \
--o-visualization PE-table.qzv \
--m-sample-metadata-file metadatos.csv

qiime feature-table tabulate-seqs \
--i-data PE-rep-seqs.qza \
--o-visualization PE-rep-seqs.qzv

## Taxonomy Assignment:

qiime feature-classifier classify-sklearn \
--i-classifier ./silva-132-99-nb-classifier.qza \
--i-reads PE-rep-seqs.qza \
--o-classification taxonomy_SILVA_138_PE.qza

qiime metadata tabulate \
--m-input-file taxonomy_SILVA_138_PE.qza \
--o-visualization taxonomy_SILVA_138_PE.qzv

## Taxa collapse and filtering of cloroplasts and mithocondria

qiime taxa filter-table \
--i-table PE-table.qza \
--i-taxonomy taxonomy_SILVA_138_PE.qza \
--p-exclude mitochondria,chloroplast \
--o-filtered-table table-no-mitochondria-no-chloroplast_PE.qza

qiime taxa filter-seqs \
--i-sequences PE-rep-seqs.qza \
--i-taxonomy taxonomy_SILVA_138_PE.qza \
--p-exclude mitochondria,chloroplast \
--o-filtered-sequences sequences-no-mitochondria-no-chloroplast_PE.qza


# Now we are gonna create a new FeatureTable but anotated:
qiime taxa collapse \
--i-table table-no-mitochondria-no-chloroplast_PE.qza \
--i-taxonomy taxonomy_SILVA_138_PE.qza \
--p-level 7 \
--o-collapsed-table table-no-mitochondria-no-chloroplast_PE_lvl_spp.qza

## Create barplots and relative abundance:

qiime taxa barplot \
--i-table table-no-mitochondria-no-chloroplast_PE.qza \
--i-taxonomy taxonomy_SILVA_138_PE.qza \
--m-metadata-file metadatos.csv \
--o-visualization taxa-bar-plots_SILVA_138_PE_clean.qzv

# Rarefaction curves:

qiime diversity alpha-rarefaction \
--i-table PE-table.qza \
--p-max-depth 200 \
--m-metadata-file metadatos.csv \
--p-metrics chao1 \
--o-visualization alpha_rarefaction_chao1.qzv

qiime tools view alpha_rarefaction_chao1.qzv


# NMDS graph:

qiime alignment mafft   --i-sequences PE-rep-seqs.qza   --o-alignment aligned-rep-seqs.qza

qiime alignment mask \
--i-alignment aligned-rep-seqs.qza \
--o-masked-alignment masked-aligned-rep-seqs.qza

qiime phylogeny fasttree \
  --i-alignment masked-aligned-rep-seqs.qza \
  --o-tree unrooted-tree.qza

qiime phylogeny midpoint-root \
  --i-tree unrooted-tree.qza \
  --o-rooted-tree rooted-tree.qza

qiime diversity core-metrics-phylogenetic \
  --i-phylogeny rooted-tree.qza \
  --i-table PE-table.qza \
  --p-sampling-depth 1109 \
  --m-metadata-file metadatos.csv \
  --output-dir core-metrics-results

qiime diversity beta-group-significance \
  --i-distance-matrix core-metrics-results/bray_curtis_distance_matrix.qza \
  --m-metadata-file metadatos.csv \
  --m-metadata-column Type \
  --o-visualization core-metrics-results/bray_curtis_type_distance_matrix.qzv \
  --p-pairwise

qiime emperor plot \
  --i-pcoa core-metrics-results/bray_curtis_pcoa_results.qza \
  --m-metadata-file metadatos.csv \
  --p-custom-axes sex \
  --o-visualization core-metrics-results/bray_curtis_emperor.qzv

qiime tools export --input-path  bray_curtis_distance_matrix.qza   --output-path bray_curtis_tye_distance_matrix.csv



