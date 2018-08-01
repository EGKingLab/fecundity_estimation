# This function downloads the egg_images.tgz file from Zenodo to the
# current R temporary directory, extracts the images, and moves
# them to the directory specified by out_path

download_egg_images <- function(out_path) {
  if (file.exists(out_path)) {
    stop(paste(out_path, "already exists."))
  }
  
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
    
    dir.create(out_path)
    suc <- file.copy(paste0(tmpdir, "/", flist), to = out_path)
    message(paste("\negg images written to", out_path))
  } else {
    message("Cancelled.")
  }
}
