#!/bin/bash
set -e

# Create directories
mkdir -p data plots

# Copy and unzip VCF
cp /data-shared/vcf_examples/luscinia_vars.vcf.gz data/
gunzip -f data/luscinia_vars.vcf.gz

# Remove meta-information lines
grep -v "^##" data/luscinia_vars.vcf > data/no_headers_luscinia_vars.vcf

# Extract CHROM, POS, QUAL
cut -f1,2,6 data/no_headers_luscinia_vars.vcf > data/SelectedCols_luscinia_vars.tsv

echo "Data processing completed."
