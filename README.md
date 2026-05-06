# emmanuelhackman.com — personal website

Source for [Emmanuel Hackman](mailto:emmanuelhackman825@gmail.com)'s personal
academic website. Built with [Quarto](https://quarto.org), deployed on
[Vercel](https://vercel.com).

## Local development

```bash
# install Quarto (one-time)
#   https://quarto.org/docs/get-started/
# or, on this machine, the binary lives at ~/.local/bin/quarto

quarto preview --port 4444     # live reload at http://127.0.0.1:4444
quarto render                  # one-shot build to ./_site
```

## Project layout

```
.
├── _quarto.yml          site config (theme, navbar, footer)
├── index.qmd            home
├── contact.qmd
├── research/index.qmd
├── publications/index.qmd
├── cv/index.qmd
├── assets/
│   ├── css/             theme overrides
│   └── img/profile.jpg  portrait
├── vercel.json          Vercel build config (downloads Quarto, runs render)
└── DEPLOY.md            deploy notes (Vercel + custom domain)
```

## Deployment

Pushing to `main` triggers Vercel to:

1. Download the Quarto CLI tarball
2. Run `quarto render` → produces `_site/`
3. Serve `_site/` as a static site

See [`DEPLOY.md`](./DEPLOY.md) for the full build flow and custom-domain notes.

## Editing tips

- Pages are markdown with a YAML front matter block. Math uses `$…$` / `$$…$$`
  via KaTeX.
- To add a page: drop a `.qmd` file in the right folder and add it to the
  `navbar` in `_quarto.yml`.
- Theme colors and fonts: `assets/css/custom.scss`.

## License

MIT — see [`LICENSE`](./LICENSE).
