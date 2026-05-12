library(rmarkdown)

combos <- list(
  c(1, 0, 0),
  c(1, 1, 0),
  c(1, 0, 1),
  c(2, 0, 0),
  c(2, 1, 0),
  c(2, 0, 1),
  c(3, 0, 0),
  c(3, 1, 0),
  c(3, 0, 1)
)

rmd_lines <- readLines("Analyse_FD_25.Rmd")

for (combo in combos) {
  pss <- combo[1]; sos <- combo[2]; ts <- combo[3]
  cat(sprintf("\n=== party.selec=%d spill=%d turnout=%d ===\n", pss, sos, ts))

  modified <- rmd_lines
  modified <- sub("^party\\.selec\\.switch <- [0-9]+",
                  sprintf("party.selec.switch <- %d", pss), modified)
  modified <- sub("^spill\\.over\\.switch <- [0-9]+",
                  sprintf("spill.over.switch <- %d", sos), modified)
  modified <- sub("^turnout\\.switch <- [0-9]+",
                  sprintf("turnout.switch <- %d", ts), modified)

  tmp <- tempfile(fileext = ".Rmd", tmpdir = ".")
  writeLines(modified, tmp)

  result <- tryCatch(
    rmarkdown::render(tmp,
                      output_file = tempfile(fileext = ".html", tmpdir = "."),
                      knit_root_dir = getwd(),
                      quiet = TRUE),
    error = function(e) {
      cat(sprintf("ERROR: %s\n", conditionMessage(e)))
      NULL
    }
  )

  file.remove(tmp)
  if (!is.null(result) && file.exists(result)) file.remove(result)

  if (!is.null(result)) {
    cat(sprintf("OK: party.selec=%d spill=%d turnout=%d\n", pss, sos, ts))
  }
}

cat("\nAll combos done.\n")
