args <- commandArgs(trailingOnly = TRUE)

options(rgl.useNULL = FALSE)

if (length(args) != 3) {
  stop(
    "Usage: Rscript scripts/render-ff25-surface.R <data.csv> <output.png> <output.mp4>",
    call. = FALSE
  )
}

required_packages <- c("ggplot2", "readr", "rayshader", "rgl", "av")
missing_packages <- required_packages[
  !vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)
]

if (length(missing_packages)) {
  stop(
    "Install the required packages before rendering: ",
    paste(missing_packages, collapse = ", "),
    call. = FALSE
  )
}

surface_data <- readr::read_csv(args[[1]], show_col_types = FALSE)

if (!identical(names(surface_data), c("ME", "BM", "raw_return_percent"))) {
  stop("Unexpected columns in the surface data file.", call. = FALSE)
}

if (nrow(surface_data) != 25L || anyNA(surface_data)) {
  stop("The surface data must contain 25 complete portfolio cells.", call. = FALSE)
}

surface_plot <- ggplot2::ggplot(
  surface_data,
  ggplot2::aes(x = ME, y = BM, fill = raw_return_percent)
) +
  ggplot2::geom_raster() +
  ggplot2::scale_fill_viridis_c(option = "C") +
  ggplot2::scale_x_continuous(breaks = 1:5) +
  ggplot2::scale_y_continuous(breaks = 1:5) +
  ggplot2::labs(
    x = "ME (small to big)",
    y = "BM (low to high)",
    fill = NULL
  ) +
  ggplot2::theme_minimal(base_size = 12) +
  ggplot2::theme(legend.title = ggplot2::element_blank())

rayshader::plot_gg(
  surface_plot,
  width = 4,
  height = 4,
  scale = 150,
  zoom = 0.7,
  multicore = FALSE,
  raytrace = FALSE
)

rayshader::render_movie(
  filename = args[[3]],
  frames = 240,
  fps = 30
)

preview_dir <- tempfile("ff25-surface-preview-")
dir.create(preview_dir)

preview_frames <- av::av_video_images(
  args[[3]],
  destdir = preview_dir,
  format = "png",
  fps = 1
)

if (!length(preview_frames) || !file.copy(preview_frames[[1]], args[[2]], overwrite = TRUE)) {
  stop("Could not create the static preview from the rendered video.", call. = FALSE)
}

unlink(preview_dir, recursive = TRUE)
rgl::close3d()
