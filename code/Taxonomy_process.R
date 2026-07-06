# ==========================================================================
# SCRIPT FINAL: TAXONOMÍA (FAMILIA Y ESPECIE) CON ORDEN ESTRICTO
# ==========================================================================

# 1. Librerías y Configuración --------------------------------------------
packages <- c("tidyverse", "vegan", "data.table", "pheatmap")
new_packages <- packages[!(packages %in% installed.packages()[,"Package"])]
if(length(new_packages)) install.packages(new_packages)

library(tidyverse)
library(vegan)
library(data.table)
library(pheatmap)

# Limpiar cualquier dispositivo gráfico que haya quedado abierto por error
while (!is.null(dev.list())) dev.off()

# Rutas
base_dir <- "C:/Users/ac.cabreraj/Documents/Resultados_Taxonomía_Py/ResultadosCorregidos"
dir_figs <- file.path(base_dir, "Figuras_Finales")

# Crear carpeta con permisos (recursive = TRUE es clave)
if (!dir.exists(dir_figs)) dir.create(dir_figs, recursive = TRUE)

# 2. Carga de Datos y Metadatos -------------------------------------------
family_raw  <- fread(file.path(base_dir, "merged_bracken_family.tsv"))
species_raw <- fread(file.path(base_dir, "merged_bracken_species.tsv"))

data_list <- list(Family = family_raw, Species = species_raw)

# Definir orden estricto de muestras (BS 1-4, SCR 1-4, MCR 1-4)
target_order <- c(paste0("BS_", 1:4), paste0("SCR_", 1:4), paste0("MCR_", 1:4))

# Crear metadatos sincronizados con el orden
metadata <- data.frame(
  Sample = target_order,
  Group = c(rep("BS", 4), rep("SCR", 4), rep("MCR", 4))
)

# 3. Ciclo de Procesamiento ----------------------------------------------
for (level_name in names(data_list)) {
  
  message(paste("--- Procesando:", level_name, "---"))
  
  # A. Limpieza y Reordenamiento
  df_clean <- as.data.frame(data_list[[level_name]])
  rownames(df_clean) <- df_clean[[1]]
  df_clean <- df_clean[, -1]
  
  # Validar que todas las columnas existan antes de reordenar
  existing_cols <- colnames(df_clean)
  cols_to_use <- target_order[target_order %in% existing_cols]
  df_clean <- df_clean[, cols_to_use]
  
  # B. Abundancia Relativa
  df_rel <- as.data.frame(prop.table(as.matrix(df_clean), margin = 2))
  
  # C. PERMANOVA (Tabla de varianza multivariada)
  dist_bray <- vegdist(t(df_rel), method = "bray")
  # Filtrar metadatos para que coincidan con las muestras procesadas
  meta_stat <- metadata[metadata$Sample %in% cols_to_use, ]
  permanova_res <- adonis2(dist_bray ~ Group, data = meta_stat)
  write.csv(as.data.frame(permanova_res), 
            file.path(base_dir, paste0("Tabla_PERMANOVA_", level_name, ".csv")))
  
  # D. Heatmap Ordenado (Top 20)
  top_idx <- rowMeans(df_rel) %>% sort(decreasing = TRUE) %>% names() %>% .[1:20]
  h_data <- t(scale(t(df_rel[top_idx, ])))
  
  anno_col <- column_to_rownames(meta_stat, "Sample")
  
  # Nombre del archivo
  file_path_h <- file.path(dir_figs, paste0("Heatmap_Ordenado_", level_name, ".png"))
  
  # Intentar abrir el dispositivo con manejo de errores
  tryCatch({
    png(file_path_h, width = 1000, height = 1200, res = 150)
    pheatmap(h_data, 
             annotation_col = anno_col,
             cluster_cols = FALSE, # Mantiene el orden BS -> SCR -> MCR
             cluster_rows = TRUE,
             color = colorRampPalette(c("navy", "white", "firebrick3"))(50),
             main = paste("Top 20", level_name, "Z-Score"),
             fontsize_row = 9)
    dev.off()
  }, error = function(e) {
    message("Error al guardar el heatmap: Asegúrate de que el archivo no esté abierto.")
  })
  
  # E. Boxplot Shannon (Diversidad Alfa)
  alpha_df <- data.frame(
    Group = meta_stat$Group,
    Shannon = diversity(t(df_clean), index = "shannon")
  )
  
  p_alpha <- ggplot(alpha_df, aes(x = Group, y = Shannon, fill = Group)) +
    geom_boxplot(alpha = 0.7, outlier.shape = NA) +
    geom_jitter(width = 0.1, size = 2) +
    scale_fill_manual(values = c("BS"="#F8766D", "MCR"="#00BA38", "SCR"="#619CFF")) +
    labs(title = paste("Shannon Diversity -", level_name)) +
    theme_minimal()
  
  ggsave(file.path(dir_figs, paste0("Boxplot_Shannon_", level_name, ".png")), p_alpha, width = 7, height = 5)
  
  # F. PCoA (Diversidad Beta)
  pcoa_res <- cmdscale(dist_bray, k = 2, eig = TRUE)
  var_exp <- round(100 * pcoa_res$eig / sum(pcoa_res$eig), 1)
  pcoa_df <- data.frame(PCoA1 = pcoa_res$points[,1], PCoA2 = pcoa_res$points[,2], Group = meta_stat$Group)
  
  p_pcoa <- ggplot(pcoa_df, aes(x = PCoA1, y = PCoA2, color = Group, fill = Group)) +
    geom_point(size = 3) +
    stat_ellipse(geom = "polygon", alpha = 0.1) +
    scale_color_manual(values = c("BS"="#F8766D", "MCR"="#00BA38", "SCR"="#619CFF")) +
    labs(title = paste("PCoA Bray-Curtis -", level_name),
         x = paste0("PCoA1 (", var_exp[1], "%)"), y = paste0("PCoA2 (", var_exp[2], "%)")) +
    theme_bw()
  
  ggsave(file.path(dir_figs, paste0("PCoA_", level_name, ".png")), p_pcoa, width = 7, height = 6)
}

message("¡Análisis completado con éxito!")
