# Run after rendering the book: Rscript scripts/check-navigation.R
library(xml2)
navigation <- readLines("sidebar-chapter-sections.html", warn = FALSE)
page <- NULL
entries <- list()
for (line in navigation) {
  if (grepl('page: "', line, fixed = TRUE)) {
    page <- sub('.*page: "([^"]+)".*', '\\1', line)
  }
  if (grepl('{ id: "', line, fixed = TRUE)) {
    entries[[length(entries) + 1L]] <- data.frame(
      page = page,
      id = sub('.*id: "([^"]+)".*', '\\1', line),
      number = sub('.*text: "([0-9]+[.][0-9]+).*', '\\1', line)
    )
  }
}
entries <- do.call(rbind, entries)
stopifnot(nrow(entries) > 0, !anyDuplicated(entries[c("page", "id")]))
for (page in unique(entries$page)) {
  document <- read_html(file.path("_book", page))
  sections <- xml_find_all(document, '//section[@data-number]')
  actual <- data.frame(id = xml_attr(sections, "id"), number = xml_attr(sections, "data-number"))
  expected <- entries[entries$page == page, ]
  for (i in seq_len(nrow(expected))) {
    target <- actual[actual$id == expected$id[i], ]
    if (nrow(target) != 1L || target$number != expected$number[i]) {
      stop("Missing or misnumbered destination: ", page, "#", expected$id[i])
    }
  }
  numbered_sections <- actual[grepl("^[0-9]+[.][0-9]+$", actual$number), ]
  stopifnot(setequal(expected$id, numbered_sections$id))
  cat("PASS:", page, "-", nrow(expected), "section links and numbers\n")
}
# Includes are embedded in every page; verify that each copy was refreshed.
for (file in list.files("_book", pattern = "[.]html$", full.names = TRUE)) {
  html <- paste(readLines(file, warn = FALSE), collapse = "\n")
  if (grepl("function initSidebarChapterSections()", html, fixed = TRUE)) {
    stopifnot(grepl(paste(navigation, collapse = "\n"), html, fixed = TRUE))
  }
}
cat("PASS: rendered pages contain the current sidebar navigation.\n")
