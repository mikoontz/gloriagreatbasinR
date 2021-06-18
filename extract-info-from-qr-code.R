library(exifr)
# devtools::install_github("brianwdavis/quadrangle", INSTALL_opts = "--no-multiarch")
# You may not need `INSTALL_opts = "--no-multiarch"` depending on your system.
library(quadrangle)

photo_files <- list.files("data/raw/", full.names = TRUE)
metadata <- exifr::read_exif(path = photo_files)

qr_codes_from_photos <- quadrangle::qr_scan(photo_files)
