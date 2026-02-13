# =========================================================
# PHRED quality analysis for Luscinia VCF
# =========================================================

# 1. Load required packages
library(ggplot2)
library(scales)

# 2. Load data
data <- read.delim("data/SelectedCols_luscinia_vars.tsv")
colnames(data) <- c("CHROM", "POS", "QUAL")
data$CHROM <- as.factor(data$CHROM)

# 3. Create output directories
dir.create("plots/genomewide", recursive = TRUE, showWarnings = FALSE)
dir.create("plots/chromosomes", recursive = TRUE, showWarnings = FALSE)

# 4. Automatic parameters
options(scipen = 999)
max_val <- max(data$QUAL, na.rm = TRUE)
cut <- max_val / 2

# 5. Genome-wide plot
plot_total <- ggplot(data, aes(x = POS, y = QUAL)) +
  geom_linerange(
    aes(
      ymin = ifelse(QUAL <= cut, 0, QUAL),
      ymax = ifelse(QUAL <= cut, QUAL, max_val)
    ),
    color = "grey", linewidth = 0.05
  ) +
  geom_point(color = "orange", size = 0.1) +
  scale_y_continuous(limits = c(0, max_val)) +
  scale_x_continuous(labels = label_comma()) +
  theme_light() +
  labs(
    title = "PHRED Quality Scores Across the Genome",
    subtitle = paste("Automatic cut-off:", round(cut, 2)),
    x = "Genomic position",
    y = "PHRED quality score"
  )

# 6. Save genome-wide plot
pdf("plots/genomewide/genomewide_PHRED.pdf", width = 12, height = 8)
print(plot_total)
dev.off()

# 7. Per-chromosome plots (NAMED LIST)
plots_chroms <- lapply(levels(data$CHROM), function(chr) {
  df <- subset(data, CHROM == chr)
  if (nrow(df) == 0) return(NULL)

  ggplot(df, aes(x = POS, y = QUAL)) +
    geom_linerange(
      aes(
        ymin = ifelse(QUAL <= cut, 0, QUAL),
        ymax = ifelse(QUAL <= cut, QUAL, max_val)
      ),
      color = "grey", linewidth = 0.1
    ) +
    geom_point(color = "orange", size = 0.3) +
    scale_y_continuous(limits = c(0, max_val)) +
    scale_x_continuous(labels = label_comma()) +
    theme_light() +
    labs(
      title = paste("Chromosome", chr),
      x = "Genomic position",
      y = "PHRED quality score"
    )
})

# Give names to the list (KEY STEP)
names(plots_chroms) <- levels(data$CHROM)

# Remove empty chromosomes but KEEP names
plots_chroms <- plots_chroms[!sapply(plots_chroms, is.null)]

# 8. Save one PDF per chromosome
for (chr in names(plots_chroms)) {
  pdf(
    file = paste0("plots/chromosomes/", chr, "_PHRED.pdf"),
    width = 12,
    height = 8
  )
  print(plots_chroms[[chr]])
  dev.off()
}

cat("Plots saved in plots/genomewide/ and plots/chromosomes/\n")
