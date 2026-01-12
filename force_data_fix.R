# Script de réparation des données (V3 - OPTIMISÉ)
message("=== DÉBUT DE LA RÉPARATION DES DONNÉES (VERSION OPTIMISÉE) ===")

library(sf)
library(dplyr)
library(stringr)
library(tidyr)
library(scales)

# 1. Chargement des communes 92
message("1. Chargement et projection des communes (vers Lambert-93)...")
if(!file.exists("data/communes.geojson")) {
  download.file("https://raw.githubusercontent.com/gregoiredavid/france-geojson/master/communes.geojson", "data/communes.geojson")
}
# On travaille en Lambert-93 (EPSG:2154) pour la précision et la rapidité
base_communes <- st_read("data/communes.geojson", quiet=TRUE) %>%
  filter(substr(code, 1, 2) == "92") %>%
  st_transform(2154) %>%
  st_make_valid()

# 2. Calcul ARGILE
message("2. Traitement ARGILE (Filtrage spatial préalable)...")
s_argile <- tibble(code=base_communes$code, score_argile=0)

if(file.exists("data/AleaRG_Fxx_L93.zip")) {
  unzip("data/AleaRG_Fxx_L93.zip", exdir="tmp_arg_fix", overwrite=TRUE)
  shp <- list.files("tmp_arg_fix", pattern=".shp$", full.names=TRUE)[1]
  
  if(!is.na(shp)) {
    sf_arg <- st_read(shp, quiet=TRUE) %>%
      st_make_valid()
    
    # ÉTAPE CRUCIALE : On ne garde que les polygones d'argile qui intersectent le 92
    bbox_92 <- st_as_sfc(st_bbox(base_communes))
    sf_arg_92 <- sf_arg[st_intersects(sf_arg, bbox_92, sparse = FALSE), ]
    
    if(nrow(sf_arg_92) > 0) {
      message(paste("   ->", nrow(sf_arg_92), "polygones d'argile intersectent la zone du 92."))
      
      # Calcul des poids
      sf_arg_92$w <- case_when(
        sf_arg_92$ALEA == 'Fort' ~ 3,
        sf_arg_92$ALEA == 'Moyen' ~ 2,
        sf_arg_92$ALEA == 'Faible' ~ 1,
        TRUE ~ 0
      )
      
      # Intersection réelle
      inter <- st_intersection(base_communes, sf_arg_92)
      
      if(nrow(inter) > 0) {
        inter$score_part <- as.numeric(st_area(inter)) * inter$w
        scores <- inter %>%
          st_drop_geometry() %>%
          group_by(code) %>%
          summarise(total = sum(score_part, na.rm=TRUE))
        
        base_communes$area <- as.numeric(st_area(base_communes))
        
        s_argile <- base_communes %>%
          st_drop_geometry() %>%
          left_join(scores, by="code") %>%
          mutate(raw = ifelse(is.na(total), 0, total/area),
                 score_argile = if(max(raw, na.rm=TRUE) > 0) scales::rescale(raw, to=c(0, 10)) else 0) %>%
          select(code, score_argile)
        
        message(paste("   -> Score moyen Argile :", round(mean(s_argile$score_argile), 2)))
      }
    }
  }
  unlink("tmp_arg_fix", recursive=TRUE)
}

# 3. Calcul NAPPES
message("3. Traitement NAPPES...")
s_nappe <- tibble(code=base_communes$code, score_nappes=0)
nappe_zip <- "data/Dept/Dept/Dept_92.zip"

if(file.exists(nappe_zip)) {
  unzip(nappe_zip, exdir="tmp_nappe_fix", overwrite=TRUE)
  shp_n <- list.files("tmp_nappe_fix", pattern="Re_Nappe_fr\\.shp$", full.names=TRUE, recursive=TRUE, ignore.case=TRUE)[1]
  if(!is.na(shp_n)) {
    sf_nappe <- st_read(shp_n, quiet=TRUE) %>%
      st_transform(2154) %>%
      st_make_valid()
    
    sf_nappe$w <- case_when(
      str_detect(sf_nappe$CLASSE, "débordements de nappe") ~ 3,
      str_detect(sf_nappe$CLASSE, "inondations de cave") ~ 2,
      TRUE ~ 1
    )
    
    inter_n <- st_intersection(base_communes, sf_nappe)
    if(nrow(inter_n) > 0) {
      inter_n$score_part <- as.numeric(st_area(inter_n)) * inter_n$w
      scores_n <- inter_n %>%
        st_drop_geometry() %>%
        group_by(code) %>%
        summarise(total = sum(score_part, na.rm=TRUE))
      
      base_communes$area <- as.numeric(st_area(base_communes))
      s_nappe <- base_communes %>%
        st_drop_geometry() %>%
        left_join(scores_n, by="code") %>%
        mutate(raw = ifelse(is.na(total), 0, total/area),
               score_nappes = if(max(raw, na.rm=TRUE) > 0) scales::rescale(raw, to=c(0, 10)) else 0) %>%
        select(code, score_nappes)
    }
  }
  unlink("tmp_nappe_fix", recursive=TRUE)
}

# 4. Fusion et Sauvegarde
message("4. Sauvegarde...")
communes_final <- base_communes %>%
  st_transform(4326) %>%
  # Retour en WGS84 pour Leaflet
  left_join(s_argile, by="code") %>%
  left_join(s_nappe, by="code") %>%
  mutate(
    score_argile = tidyr::replace_na(score_argile, 0),
    score_nappes = tidyr::replace_na(score_nappes, 0),
    score_global = (score_argile + score_nappes)/2
  )

saveRDS(communes_final, "communes_scores_92_100pct.rds")
message("=== TERMINÉ : Fichier communes_scores_92_100pct.rds mis à jour ===")