Portable Quarto book format template
====================================

Use this folder together with FORMATO_QUARTO_ARF_A_EMF.txt.

The target project is tutorial_emf. Work directly on main. Do not create a new
branch. Do not create or use a _book branch. The rendered output belongs in
_book and should be published by GitHub Actions / GitHub Pages.

Suggested use:

1. Copy the files in this folder into the root of tutorial_emf.
2. Rename _quarto.yml.template to _quarto.yml and adapt the chapter list.
3. Rename index.qmd.template to index.qmd and rewrite the Preface / What's new.
4. Copy .gitignore.additions into the project .gitignore.
5. Keep the existing analytics_emf.html if the project already has one. Do not
   overwrite it with an ARF analytics file.
6. Adapt sidebar-chapter-sections.html to the real EMF chapter pages and section
   ids after rendering.
7. Adapt .github/workflows/publish.yml so the R package installation matches the
   packages used by EMF.
8. Render with quarto render and verify _book/index.html.

Do not copy ARF content into EMF. This template is only for layout, navigation,
publication, and shared book mechanics.
