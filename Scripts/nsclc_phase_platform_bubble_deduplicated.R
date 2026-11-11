# ==============================================================================
# Clinical Phase vs Vaccine Platform Bubble Plots — NSCLC vaccine trials
# Exclude duplicate FRAME-001 registration EUCTR2021-003166-12-NL
# Retain NCT04998474 as the single FRAME-001 trial
# Expected after deduplication: 184 unique trials (145 conventional, 39 neoantigen)
# PNG export: 600 dpi; PDF export: vector
# ==============================================================================

suppressPackageStartupMessages({
  library(tidyverse)
})

args <- commandArgs(trailingOnly = FALSE)
script_arg <- grep('^--file=', args, value = TRUE)
script_dir <- if (length(script_arg)) {
  dirname(normalizePath(sub('^--file=', '', script_arg[1])))
} else {
  getwd()
}
setwd(script_dir)

meta_method <- Sys.getenv('META_METHOD', unset = 'REML')
output_dir <- file.path('figures', meta_method)
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
dir.create('figures', recursive = TRUE, showWarnings = FALSE)

# 1. Read classified trial dataset
input <- if (file.exists('nsclc_185_phase_platform_classified_curated.csv')) {
  'nsclc_185_phase_platform_classified_curated.csv'
} else {
  'nsclc_185_phase_platform_classified.csv'
}
if (!file.exists(input)) stop('Could not find either classified NSCLC trial CSV.')

df_raw <- readr::read_csv(input, show_col_types = FALSE)
required <- c('TrialID', 'Enrollment', 'Phase', 'Platform', 'Vaccine_Type')
missing <- setdiff(required, names(df_raw))
if (length(missing)) stop('Missing required columns: ', paste(missing, collapse = ', '))

# 2. Deduplicate FRAME-001 at the underlying trial level
# The European registration is a second identifier for the trial NCT04998474.
remove_id <- 'EUCTR2021-003166-12-NL'
keep_id <- 'NCT04998474'
df_raw <- df_raw %>% mutate(TrialID = trimws(as.character(TrialID)))

removed_rows <- sum(df_raw$TrialID == remove_id, na.rm = TRUE)
if (removed_rows != 1L) {
  stop('Expected exactly one ', remove_id, ' row; found ', removed_rows,
       '. Inspect TrialID values and source data before proceeding.')
}
if (!any(df_raw$TrialID == keep_id, na.rm = TRUE)) {
  stop('Cannot find retained FRAME-001 ID ', keep_id, ' in source data.')
}

df <- df_raw %>%
  filter(!is.na(TrialID), TrialID != '', TrialID != remove_id) %>%
  distinct(TrialID, .keep_all = TRUE)

# Validate counts before plotting; do not silently misstate the figure.
stopifnot(nrow(df) == 184L, n_distinct(df$TrialID) == 184L)

# 3. Prepare classifications and enrollment
phase_levels <- c('Early Phase I', 'Phase I', 'Phase I/II',
                  'Phase II', 'Phase II/III', 'Phase III')
platform_levels <- c(
  'Peptide / Synthetic Long Peptide (SLP)',
  'Dendritic Cell (DC) Vaccine',
  'mRNA / Nucleic Acid Vaccine',
  'Whole-Cell / Tumor Lysate Vaccine',
  'Viral / Bacterial Vector Vaccine',
  'Recombinant Protein / Antigen Vaccine',
  'Anti-Idiotypic / Antibody Vaccine'
)
paradigm_levels <- c('Conventional Non-Neoantigen', 'Personalized Neoantigen')

df <- df %>%
  mutate(
    Clean_Enrollment = if_else(TrialID == 'NCT04540081',
                               500, suppressWarnings(as.numeric(Enrollment))),
    Phase = factor(Phase, levels = phase_levels),
    Platform = factor(Platform, levels = rev(platform_levels)),
    Paradigm = factor(Vaccine_Type, levels = paradigm_levels)
  )

if (anyNA(df$Phase) || anyNA(df$Platform) || anyNA(df$Paradigm)) {
  print(df %>% filter(is.na(Phase) | is.na(Platform) | is.na(Paradigm)) %>%
          select(TrialID, Phase, Platform, Vaccine_Type))
  stop('Some trial classifications do not match configured labels. Resolve before plotting.')
}

n_conventional <- sum(df$Paradigm == 'Conventional Non-Neoantigen')
n_neoantigen <- sum(df$Paradigm == 'Personalized Neoantigen')
stopifnot(n_conventional == 145L, n_neoantigen == 39L)
message('Verified unique trials: ', nrow(df), ' (', n_conventional,
        ' conventional; ', n_neoantigen, ' neoantigen).')

# 4. Count unique trials at each phase-platform intersection
all_bubbles <- df %>%
  count(Platform, Phase, name = 'Trials_Count') %>%
  mutate(Label_Text = as.character(Trials_Count))

paradigm_bubbles <- df %>%
  count(Paradigm, Platform, Phase, name = 'Trials_Count') %>%
  mutate(Label_Text = as.character(Trials_Count))

# Empty matrix locations shown with small, pale guide dots.
all_grid <- tidyr::expand_grid(
  Platform = factor(rev(platform_levels), levels = rev(platform_levels)),
  Phase = factor(phase_levels, levels = phase_levels)
)
paradigm_grid <- tidyr::expand_grid(
  Paradigm = factor(paradigm_levels, levels = paradigm_levels),
  Platform = factor(rev(platform_levels), levels = rev(platform_levels)),
  Phase = factor(phase_levels, levels = phase_levels)
)

stopifnot(sum(all_bubbles$Trials_Count) == 184L,
          sum(paradigm_bubbles$Trials_Count) == 184L)

phase_colors <- c(
  'Early Phase I' = '#94A3B8', 'Phase I' = '#00468B',
  'Phase I/II' = '#0099B4', 'Phase II' = '#42B540',
  'Phase II/III' = '#FDAE61', 'Phase III' = '#E64B35'
)
paradigm_colors <- c(
  'Conventional Non-Neoantigen' = '#00468B',
  'Personalized Neoantigen' = '#E64B35'
)

base_theme <- theme_minimal(base_size = 10) +
  theme(
    text = element_text(family = 'sans'),
    plot.title = element_text(face = 'bold', color = '#0C4A6E',
                              size = 13, hjust = .5, margin = margin(b = 5)),
    plot.subtitle = element_text(color = '#475569', size = 9.5,
                                 hjust = .5, margin = margin(b = 14)),
    plot.caption = element_text(color = '#64748B', size = 8,
                                hjust = .5, margin = margin(t = 12)),
    axis.title = element_text(face = 'bold', color = '#1E293B'),
    axis.text = element_text(face = 'bold', color = '#334155', size = 9),
    panel.grid.major = element_line(color = '#F1F5F9', linewidth = .4),
    panel.grid.minor = element_blank(),
    plot.margin = margin(15, 15, 15, 15),
    plot.background = element_rect(fill = 'white', color = NA)
  )

# 5. Unified phase-platform bubble plot
p_unified <- ggplot(all_bubbles, aes(x = Phase, y = Platform)) +
  geom_point(data = all_grid, aes(x = Phase, y = Platform),
             inherit.aes = FALSE, color = '#E2E8F0', size = 2.5) +
  geom_point(aes(size = Trials_Count, fill = Phase), shape = 21,
             color = '#1E293B', stroke = .6, alpha = .85) +
  geom_text(aes(label = Label_Text), size = 3.2, fontface = 'bold', color = 'white') +
  scale_fill_manual(values = phase_colors, name = 'Clinical Phase', drop = FALSE) +
  scale_size_continuous(range = c(5, 22), name = 'Number of Trials') +
  guides(fill = guide_legend(order = 1, override.aes = list(size = 5.5)),
         size = guide_legend(order = 2)) +
  labs(
    title = 'Clinical Phase and Vaccine Platform Distribution in NSCLC',
    subtitle = sprintf('Global landscape of %d unique NSCLC vaccine trials', nrow(df)),
    x = 'Clinical Development Phase',
    y = 'Vaccine Delivery Platform / Technology',
    caption = paste('Numbers inside bubbles indicate unique trial counts.',
                    'Bubble area represents trial frequency.',
                    'Duplicate FRAME-001 EUCTR registration excluded.')
  ) +
  base_theme +
  theme(legend.position = 'right',
        axis.text.x = element_text(face = 'bold', color = '#334155', size = 9))

# 6. Side-by-side conventional vs personalized neoantigen plots
p_faceted <- ggplot(paradigm_bubbles, aes(x = Phase, y = Platform)) +
  geom_point(data = paradigm_grid, aes(x = Phase, y = Platform),
             inherit.aes = FALSE, color = '#E2E8F0', size = 2) +
  geom_point(aes(size = Trials_Count, fill = Paradigm), shape = 21,
             color = '#1E293B', stroke = .5, alpha = .85) +
  geom_text(aes(label = Label_Text), size = 2.8, fontface = 'bold', color = 'white') +
  scale_fill_manual(values = paradigm_colors, name = 'Vaccine Paradigm') +
  scale_size_continuous(range = c(4.5, 18), name = 'Number of Trials') +
  facet_wrap(~Paradigm, ncol = 2) +
  guides(fill = guide_legend(order = 1, override.aes = list(size = 5)),
         size = guide_legend(order = 2)) +
  labs(
    title = 'Platform Progression by Vaccine Paradigm',
    subtitle = sprintf('Conventional non-neoantigen (n = %d) vs personalized neoantigen (n = %d)',
                       n_conventional, n_neoantigen),
    x = 'Clinical Development Phase', y = NULL,
    caption = paste('Numbers inside bubbles indicate unique trial counts.',
                    'FRAME-001 counted once under NCT04998474.')
  ) +
  base_theme +
  theme(axis.text.x = element_text(angle = 35, hjust = 1,
                                   face = 'bold', color = '#334155', size = 8.5),
        strip.text = element_text(face = 'bold', color = 'white', size = 10),
        strip.background = element_rect(fill = '#1B365D', color = NA),
        legend.position = 'bottom', legend.box = 'horizontal')

# 7. Publication outputs; no overwriting original 185-trial figures
save_plot <- function(plot, stem, width, height) {
  for (dest in c(output_dir, 'figures')) {
    ggsave(file.path(dest, paste0(stem, '.png')), plot,
           width = width, height = height, dpi = 600, bg = 'white')
    ggsave(file.path(dest, paste0(stem, '.pdf')), plot,
           width = width, height = height, device = 'pdf', bg = 'white')
  }
}
save_plot(p_unified, 'nsclc_phase_platform_bubble_unified_184', 11, 6.8)
save_plot(p_faceted, 'nsclc_phase_platform_bubble_faceted_184', 12, 6.8)

# Preserve the reconciled dataset for audit/reproducibility.
readr::write_csv(df %>% mutate(Phase = as.character(Phase),
                                  Platform = as.character(Platform),
                                  Paradigm = as.character(Paradigm)),
                 file.path(output_dir, 'nsclc_phase_platform_deduplicated_184.csv'))
message('Saved corrected bubble plots to ', normalizePath(output_dir))
