download_egg_images <- function(out_path) {
  tmpdir <- tempdir()
  
  url <- "https://zenodo.org/record/1285237/files/egg_images.tgz"
  tmpfile <- paste0(tmpdir, "/", basename(url))
  download.file(url,
                destfile = tmpfile,
                mode = "wb")
  
  untar(tmpfile, compressed = 'gzip', exdir = tmpdir)
  list.files(tmpdir)
  
}

out_path <- "~/Desktop"
download_egg_images(out_path)
