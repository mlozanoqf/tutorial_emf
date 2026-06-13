# Financial Econometrics with R

This repository contains the source files for **Financial Econometrics with R**, a Quarto book by Dr. Martin Lozano. The book connects time-series forecasting tools, volatility modeling, and asset pricing econometrics in R.

Published site: <https://mlozanoqf.github.io/tutorial_emf/>

## Scope

The current version focuses on:

- Forecast notation, forecast origins, holdout samples, and forecast errors
- Monthly sales data from FRED as an introductory time-series example
- Classical forecasting with `fpp3`: decomposition, simple benchmarks, ETS, ARIMA, and NNAR
- Supervised forecasting with time-based features
- Temporal train/validation/test splits
- Linear regression, regression trees, and small neural networks for forecasting
- ARIMA benchmarking with the `forecast` package
- Forecast averaging and out-of-sample model comparison
- GARCH(1,1) conditional volatility modeling and volatility forecasting
- Asset pricing econometrics with CAPM, Fama-French factors, 25 size-value portfolios, time-series regressions, cross-sectional tests, and SDF/GMM logic

## Book Structure

- `index.qmd`: preface, book identity, and publication metadata
- `01-forecasting-with-fpp3.qmd`: classical forecasting workflow with `fpp3`
- `02-forecasting-with-machine-learning.qmd`: time-series forecasting with machine learning
- `03-garch-volatility.qmd`: GARCH volatility forecasting
- `04-asset-pricing-econometrics.qmd`: asset pricing econometrics with Fama-French factors
- `references.qmd`: references chapter
- `references.bib`: bibliography

The book configuration lives in `_quarto.yml`.

## Repository Layout

- `R/book-edition.R`: helper functions for book edition and publication metadata
- `_freeze/`: cached execution results used by Quarto's `freeze: auto`
- `_book/`: generated HTML output created by `quarto render`
- `.github/workflows/publish.yml`: GitHub Actions workflow for rendering and deploying the book to GitHub Pages
- `styles.css` and `*.html` partials: custom navigation, layout, analytics, and page behavior
- `_extensions/`: bundled Quarto extension files
- `fpp3_fc.rds` and `mape_updated.rds`: rendered intermediate objects shared across forecasting chapters
- `FF/`: source material for the asset-pricing chapter; kept as read-only reference material and not required as rendered book output

## Render Locally

Install Quarto and R, then install the R packages used by the book:

```bash
Rscript -e "install.packages(c('bit64','broom','dplyr','fontawesome','forecast','fpp3','ggplot2','kableExtra','knitr','lubridate','nnet','purrr','readr','rmarkdown','rpart','scales','seasonal','sweep','tibble','tictoc','timetk','tidyquant','tidyr','vembedr','xfun'), repos = 'https://cloud.r-project.org')"
```

Render the book from the repository root:

```bash
quarto render
```

For interactive local preview:

```bash
quarto preview
```

## Publication

Pushing to `main` triggers `.github/workflows/publish.yml`. The workflow:

1. checks out the repository;
2. installs Quarto and R;
3. installs the required R packages;
4. runs `quarto render`;
5. uploads `_book` as a GitHub Pages artifact;
6. deploys the artifact to GitHub Pages.

The workflow can also be started manually from GitHub Actions with `workflow_dispatch`.

## Maintenance Notes

- Edit the source `.qmd` files, `_quarto.yml`, `styles.css`, HTML partials, or helper scripts.
- Treat `_book/` as generated output.
- Keep `_freeze/` in sync with rendered chapter outputs because `freeze: auto` is enabled.
- If chapters are renamed, added, or removed, update `_quarto.yml`, `sidebar-chapter-sections.html`, `_freeze/`, and this README.
- `index.qmd` injects publication metadata through `R/book-edition.R`.
- No separate test suite is configured; the main validation step is a successful `quarto render` and review of the generated book.

## License

This project is licensed under the GNU General Public License v3.0. See `LICENSE`.
