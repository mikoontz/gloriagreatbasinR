library(dplyr)
library(glue)

https://github.com/hrbrmstr/qrencoder to generate the codes
devtools::install_github("hrbrmstr/qrencoder")

and https://github.com/brianwdavis/quadrangle to read them

and https://cran.r-project.org/web/packages/exifr/index.html to get the time stamp from the photo’s metadata

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
  dplyr::mutate(chalkboard_text = list(c(glue("p5m-{aspect}11"),
                                  glue("{aspect}11"),
                                  glue("{aspect}31"),
                                  glue("{aspect}13"),
                                  glue("{aspect}33"),
                                  glue("{aspect}\n3x3\nGrid"),
                                  glue("{aspect}\n10x10\nLow"),
                                  glue("{aspect}\n10x10\nHigh"),
                                  glue("p10m-{aspect}"),
                                  glue("{aspect}22\nTemp Logger"))),
                filename_text = list(c(glue("p5m-{aspect}11"),
                                       glue("{aspect}11-QU"),
                                       glue("{aspect}31-QU"),
                                       glue("{aspect}13-QU"),
                                       glue("{aspect}33-QU"),
                                       glue("CL-{aspect}"),
                                       glue("{aspect}\n10x10\nLow"),
                                       glue("{aspect}\n10x10\nHigh"),
                                       glue("p10m-{aspect}"),
                                       glue("{aspect}22\nTemp Logger"))) %>%
  arrange(aspect) %>% 
  tidyr::unnest(cols = photo_point_text) %>% 
  as.data.frame()

photos_per_aspect
