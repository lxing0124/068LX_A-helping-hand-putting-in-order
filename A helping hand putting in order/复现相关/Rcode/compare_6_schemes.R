# ============================================================
# Exp1: 6种预处理方案比较
# Rinaldi et al. (2016) "A helping hand putting in order"
#
# posture.D = mean_RT_supine - mean_RT_prone  (raw RT, Method B)
# correction = 减自己posture的finger.D + Supine额外减posture.D
#   Prone  corrected = RT - finger.D_prone
#   Supine corrected = RT - finger.D_supine - posture.D
# ============================================================

library(tidyverse)

data_dir <- "E:/360MoveData/Users/Lenovo/Desktop/Data_A halping hand/Author Data"

# ---- 1. Read Data ----
baseline_raw <- read_tsv(file.path(data_dir, "Baseline_Experiment 1.txt"),
                         col_types = cols(.default = col_guess()))
fm_raw <- read_tsv(file.path(data_dir, "Finger-Mapping_Experiment 1.txt"),
                   col_types = cols(.default = col_guess()))
author_corrected <- read_tsv(file.path(data_dir, "Corrected RTs_Experiment 1.txt"),
                             locale = locale(decimal_mark = ","))

# Map finger codes to names
finger_map <- c("b" = "Thumb", "h" = "Index", "j" = "Middle", "k" = "Ring", "l" = "Little")
image_to_finger <- function(img) str_extract(img, "^\\w+")

# ---- 2. Helper Functions ----

# M +/- 2SD outlier removal
remove_outliers <- function(data, ..., rt_col = "RT") {
  grps <- quos(...)
  data %>%
    group_by(!!!grps) %>%
    mutate(.lo = mean(.data[[rt_col]], na.rm = TRUE) - 2 * sd(.data[[rt_col]], na.rm = TRUE),
           .hi = mean(.data[[rt_col]], na.rm = TRUE) + 2 * sd(.data[[rt_col]], na.rm = TRUE)) %>%
    filter(.data[[rt_col]] >= .lo & .data[[rt_col]] <= .hi) %>%
    ungroup() %>%
    select(-starts_with("."))
}

# finger.D = finger_mean - fastest_finger_mean  (per Subject x Posture)
compute_finger_D <- function(bl) {
  means <- bl %>%
    group_by(Subject, Posture, Finger) %>%
    summarise(m = mean(RT), .groups = "drop")
  fastest <- means %>%
    group_by(Subject, Posture) %>%
    slice_min(m, n = 1, with_ties = FALSE) %>%
    transmute(Subject, Posture, fast = m)
  means %>%
    left_join(fastest, by = c("Subject", "Posture")) %>%
    mutate(finger_D = m - fast) %>%
    select(Subject, Posture, Finger, finger_D)
}

# posture.D = mean_RT_supine - mean_RT_prone  (raw RT, Method B)
compute_posture_D <- function(bl) {
  bl %>%
    group_by(Subject, Posture, Finger) %>%
    summarise(pm = mean(RT), .groups = "drop") %>%
    pivot_wider(names_from = Posture, values_from = pm) %>%
    mutate(posture_D = Supine - Prone) %>%
    select(Subject, Finger, posture_D)
}

# Correction: subtract own-posture finger.D + posture.D for supine
correct_fm <- function(fm, finger_D, posture_D) {
  mapping_posture <- c("A" = "Prone", "B" = "Prone", "C" = "Supine", "D" = "Supine")
  fm %>%
    mutate(Finger = recode(CorrectResponse, !!!finger_map),
           Posture = recode(Mapping, !!!mapping_posture)) %>%
    left_join(finger_D, by = c("Subject", "Posture", "Finger")) %>%
    left_join(posture_D, by = c("Subject", "Finger")) %>%
    mutate(corrected_RT = RT - finger_D,
           corrected_RT = if_else(Posture == "Supine", corrected_RT - posture_D, corrected_RT))
}

# ---- 3. Prepare Data ----
bl_raw <- baseline_raw %>%
  mutate(Posture = recode(`Hand Posture`, "Down" = "Prone", "Up" = "Supine"),
         Finger = image_to_finger(Image))

fm_prep <- fm_raw %>%
  mutate(Finger = recode(CorrectResponse, !!!finger_map),
         Posture = recode(Mapping, "A" = "Prone", "B" = "Prone", "C" = "Supine", "D" = "Supine"))

# Author corrected RTs (long format)
author_long <- author_corrected %>%
  pivot_longer(-Subject, names_to = "col", values_to = "author_RT") %>%
  mutate(Mapping = str_extract(col, "^[A-D]"),
         Stimulus = as.numeric(str_extract(col, "\\d+$"))) %>%
  filter(!is.na(Mapping), !is.na(Stimulus)) %>%
  select(Subject, Mapping, Stimulus, author_RT)

# ---- 4. Run Pipeline ----
run_scheme <- function(label, correct_first, grouping) {
  # Outlier removal function based on grouping
  rf <- switch(grouping,
    "Subject" = function(d) remove_outliers(d, Subject),
    "SubjPostFinger" = function(d) remove_outliers(d, Subject, Posture, Finger),
    "overall" = function(d) remove_outliers(d)
  )

  if (correct_first) {
    bl <- bl_raw %>% filter(Accuracy == 1) %>% rf()
    fm <- fm_prep %>% filter(Accuracy == 1) %>% rf() %>% select(-Posture)
  } else {
    bl <- bl_raw %>% rf() %>% filter(Accuracy == 1)
    fm <- fm_prep %>% rf() %>% filter(Accuracy == 1) %>% select(-Posture)
  }

  fd <- compute_finger_D(bl)
  pd <- compute_posture_D(bl)
  fm_c <- correct_fm(fm, fd, pd)

  fm_c %>%
    group_by(Subject, Mapping, Stimulus) %>%
    summarise(corrected_RT = mean(corrected_RT), .groups = "drop") %>%
    left_join(author_long, by = c("Subject", "Mapping", "Stimulus")) %>%
    mutate(diff = corrected_RT - author_RT,
           abs_diff = abs(diff),
           scheme = label)
}

# 6 schemes: 3 groupings × 2 orders
scheme_defs <- list(
  list(label = "1: correct->SD | group(Subject)",          correct_first = TRUE,  grouping = "Subject"),
  list(label = "2: SD->correct | group(Subject)",          correct_first = FALSE, grouping = "Subject"),
  list(label = "3: correct->SD | group(Subj,Post,Finger)", correct_first = TRUE,  grouping = "SubjPostFinger"),
  list(label = "4: SD->correct | group(Subj,Post,Finger)", correct_first = FALSE, grouping = "SubjPostFinger"),
  list(label = "5: correct->SD | group(overall)",          correct_first = TRUE,  grouping = "overall"),
  list(label = "6: SD->correct | group(overall)",          correct_first = FALSE, grouping = "overall")
)

results <- bind_rows(lapply(scheme_defs, function(s) {
  run_scheme(s$label, s$correct_first, s$grouping)
}))

# ---- 5. Results ----

cat(rep("=", 72), "\n", sep = "")
cat("Exp1 — 6种预处理方案比较\n")
cat("posture.D = mean_supine - mean_prone (raw RT)\n")
cat("correction = RT - finger.D_propre; supine额外减posture.D\n")
cat(rep("=", 72), "\n\n", sep = "")

# Overall summary table
summary_table <- results %>%
  group_by(scheme) %>%
  summarise(
    MAE       = mean(abs_diff),
    mean_diff = mean(diff),
    RMSE      = sqrt(mean(diff^2)),
    med_abs   = median(abs_diff),
    max_abs   = max(abs_diff),
    .groups   = "drop"
  ) %>%
  arrange(MAE)

cat("--- 总体汇总 (按MAE排序) ---\n")
print(summary_table %>% as.data.frame(), row.names = FALSE)

# Per-subject MAE
cat("\n--- 逐被试MAE ---\n")
per_subject <- results %>%
  group_by(scheme, Subject) %>%
  summarise(MAE = mean(abs_diff), .groups = "drop") %>%
  pivot_wider(names_from = scheme, values_from = MAE)
print(per_subject %>% as.data.frame(), row.names = FALSE)

# Per-condition MAE
cat("\n--- 逐条件MAE (被试平均) ---\n")
per_condition <- results %>%
  group_by(scheme, Mapping, Stimulus) %>%
  summarise(MAE = mean(abs_diff), .groups = "drop") %>%
  mutate(Condition = paste0(Mapping, "_", Stimulus)) %>%
  select(scheme, Condition, MAE) %>%
  arrange(scheme, Condition)
print(per_condition %>% as.data.frame(), row.names = FALSE)

# Best scheme
best <- summary_table %>% slice(1)
cat(sprintf("\n*** 最佳: %s | MAE = %.2f ms | RMSE = %.2f ms ***\n",
            best$scheme, best$MAE, best$RMSE))

# ---- 6. Save ----
write.csv(summary_table, file.path(data_dir, "..", "scheme_comparison_summary.csv"), row.names = FALSE)
write.csv(results, file.path(data_dir, "..", "scheme_comparison_detail.csv"), row.names = FALSE)
cat("\n已保存: scheme_comparison_summary.csv + scheme_comparison_detail.csv\n")
