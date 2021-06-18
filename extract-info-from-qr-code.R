library(exifr)
# devtools::install_github("brianwdavis/quadrangle", INSTALL_opts = "--no-multiarch")
# You may not need `INSTALL_opts = "--no-multiarch"` depending on your system.
library(quadrangle)
library(stringr)
library(lubridate)
library(pbapply)

photo_files <- list.files("data/raw/", full.names = TRUE)

qr_extract <- function(file) {
  qr <- quadrangle::qr_scan(file)
  metadata <- exifr::read_exif(path = file)
  photo_date <- lubridate::ymd_hms(metadata$FileModifyDate)
  month_out <- str_pad(string = month(photo_date), width = 2, side = "left", pad = "0")
  day_out <- str_pad(string = day(photo_date), width = 2, side = "left", pad = "0")
  out <- paste0(paste(qr$values$value, collapse = ""), "_", year(photo_date), month_out, day_out, "_", basename(file))
  
  return(out)
}

new_photo_filenames <- 
  pbsapply(photo_files, FUN = qr_extract)

new_photo_filenames
