download_egg_images <- function(out_path) {
  
  message("This function will download the egg images file from")
  message("Zenodo, uncompress it, and move it to")
  message(out_path)
  
  resp <- menu(
    c("Yes", "No"),
    title = "\nChoosing yes will download a ~5 gb file, which will be slow. Proceed?")
  
  if (resp == 1) {
    tmpdir <- tempdir()
    url <- "https://zenodo.org/record/1285237/files/egg_images.tgz"
    tmpfile <- paste0(tmpdir, "/", basename(url))
    download.file(url,
                  destfile = tmpfile,
                  mode = "wb")
    
    untar(tmpfile, compressed = 'gzip', exdir = tmpdir)
    flist <- list.files(tmpdir, pattern = "IMG")

    if (file.exists(out_path)) {
      stop(paste(out_path, "already exists."))
    } else {
      dir.create(out_path)
      file.copy(paste0(tmpdir, "/", flist), to = out_path)
    }
  } else {
    message("Cancelled.")
  }
}

out_path <- "~/Desktop/egg_images"
download_egg_images(out_path)
