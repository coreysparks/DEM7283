# Shared setup sourced (silently) at the top of every chapter of the book.
# You don't need this file to run the examples yourself; each chapter loads
# its own packages and sets its own colors. It only sets a default seed and
# makes sure any plot without an explicit color scale still uses the UTSA
# palette.

set.seed(7283)

if (requireNamespace("ggplot2", quietly = TRUE) &&
    requireNamespace("sparkscolors", quietly = TRUE)) {
  options(
    ggplot2.discrete.colour = function(...) sparkscolors::scale_colour_utsa(...),
    ggplot2.discrete.fill = function(...) sparkscolors::scale_fill_utsa(...),
    ggplot2.continuous.colour = function(...) sparkscolors::scale_colour_utsa(discrete = FALSE, ...),
    ggplot2.continuous.fill = function(...) sparkscolors::scale_fill_utsa(discrete = FALSE, ...)
  )
}

# UTSA colors for base R graphics: col = 1 is Midnight, col = 2 is Orange
grDevices::palette(c("#032044", "#F15A22", "#265BF7", "#A06620",
                     "#DBB485", "#C8DCFF", "#D5CFC8"))
