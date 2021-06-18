library(dplyr)
library(glue)
library(tidyr)
# devtools::install_github("hrbrmstr/qrencoder")
library(qrencoder)
library(ggplot2)

# https://github.com/hrbrmstr/qrencoder to generate the codes

# 
# and https://github.com/brianwdavis/quadrangle to read them
# 
# and https://cran.r-project.org/web/packages/exifr/index.html to get the time stamp from the photo’s metadata

sites <- 
  data.frame(country_code = "US",
             tr = c(rep("CAT", 3), 
                    rep("SND", 4),
                    rep("LAN", 4),
                    rep("WDS", 3),
                    rep("WIM", 5),
                    rep("GRB", 4),
                    rep("SWE", 3),
                    rep("DEV", 4)),
             tr_fullname = c(rep("Carson Range Tahoe", 3),
                             rep("Dunderberg", 4),
                             rep("Mount Langley", 4),
                             rep("White Mountains Carbonatic", 3),
                             rep("White Mountains Siliceous", 5),
                             rep("Great Basin National Park", 4),
                             rep("Sweetwater Mountains", 3),
                             rep("Death Valley National Park", 4)),
             peak = c("FES", "FPK", "FSW",
                      "332", "357", "374", "GRL",
                      "CFK", "IDR", "LSS", "LWS",
                      "CWS", "PGS", "SME",
                      "BAR", "RNA", "SHF", "WMT", "CPT",
                      "BCK", "BLD", "PMD", "WLR",
                      "BEL", "FRY", "WHE",
                      "LOW", "MID", "BEN", "TEL"),
             peak_fullname = c("Freel East Summit", "Freel Peak", "Freel Southwest Ridge",
                               "Dunderberg Low 332", "Dunderberg Mid 357", "Dunderberg High 374", "Granite Lakes",
                               "Confluence Knob", "Iridescent Ridge", "Langley South Shoulder", "Langley West Shoulder",
                               "Cottonwood South Summit", "Patriarch Grove South", "Sheep Mountain East",
                               "Mount Barcroft", "Research Natural Area", "Sage Hen Flat", "White Mountain North Summit", "Campito",
                               "Buck Mountain", "Bald Mountain Northeast", "Pyramid Peak", "Wheeler Peak West Shoulder",
                               "Belfort", "Frying Pan", "Wheeler Peak", 
                               "Low Site", "Mid Site", "Bennett Peak", "Telescope Peak"))

# 1 photo of HSP, 9 photos per aspect, 2 photos per off-cardinal intersection, 2 logger photos per aspect
# 1 + (9*4) + (2*4) + (2 * 4)

photos_per_aspect <- 
  data.frame(aspect = c("N", "S", "E", "W")) %>% 
  rowwise() %>% 
  dplyr::mutate(chalkboard_text_per_summit = list(c(glue("p5m-{aspect}11"),
                                         glue("{aspect}11"),
                                         glue("{aspect}31"),
                                         glue("{aspect}13"),
                                         glue("{aspect}33"),
                                         glue("{aspect}\n3x3\nGrid"),
                                         glue("{aspect}\n10x10\nLow"),
                                         glue("{aspect}\n10x10\nHigh"),
                                         glue("p10m-{aspect}"),
                                         glue("{aspect}22\nTemp Logger"),
                                         glue("{aspect}22\nTemp Logger"))),
                filename_text_per_summit = list(c(glue("P5M-{aspect}11"),
                                       glue("{aspect}11-QU"),
                                       glue("{aspect}31-QU"),
                                       glue("{aspect}13-QU"),
                                       glue("{aspect}33-QU"),
                                       glue("CL-{aspect}"),
                                       glue("{aspect}-10x10-LOW"),
                                       glue("{aspect}-10x10-HIGH"),
                                       glue("P10M-{aspect}"),
                                       glue("{aspect}22-LOGC"),
                                       glue("{aspect}22-LOGO")))) %>%
  arrange(aspect) %>% 
  tidyr::unnest(cols = c(chalkboard_text_per_summit, filename_text_per_summit)) 

off_cardinal_photos <-
  data.frame(aspect = c("NE", "SE", "SW", "NW")) %>% 
  rowwise() %>% 
  dplyr::mutate(chalkboard_text_per_summit = list(c(glue("p5m-{aspect}"), glue("p10m-{aspect}"))),
                   filename_text_per_summit = list(c(glue("P5M-{aspect}"), glue("P10M-{aspect}")))) %>% 
  arrange(aspect) %>% 
  tidyr::unnest(cols = c(chalkboard_text_per_summit, filename_text_per_summit))


photo_points_per_summit <-
  data.frame(aspect = NA,
           chalkboard_text_per_summit = "HSP",
           filename_text_per_summit = "HSP") %>% 
  rbind(photos_per_aspect, off_cardinal_photos)

photo_points_all <-
  sites %>% 
  mutate(photo_points = list(photo_points_per_summit)) %>% 
  tidyr::unnest(photo_points) %>% 
  rowwise() %>% 
  mutate(qr = list(qrencoder::qrencode_df(to_encode = glue("{country_code}_{tr}_{peak}_{filename_text_per_summit}"))))

?qrencode_df

set.seed(1404)
example_qr <-
  photo_points_all$qr[[sample(nrow(photo_points_all), 1)]] %>% 
  as_tibble() %>% 
  mutate(z = as.factor(z))

example_qr

ggplot(example_qr, aes(x, y, fill = z)) + 
  geom_raster() + 
  coord_fixed() + 
  theme_void() +
  guides(fill = FALSE) +
  scale_fill_manual(values = c("white", "black"))
