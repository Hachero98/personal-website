# Deploying to Vercel

This site is configured for one-click Vercel deploys via [`vercel.json`](./vercel.json).
On every push to `main`, Vercel:

1. Downloads the Quarto 1.9.37 Linux tarball
2. Adds it to `PATH`
3. Runs `quarto render` → emits static HTML into `_site/`
4. Serves `_site/` via Vercel's CDN

No Node, no Python — just static HTML / CSS once Quarto finishes rendering.

---

## First-time hookup

### Option A — Vercel dashboard (easiest)

1. Push this repo to GitHub.
2. Go to <https://vercel.com/new>.
3. **Import** the GitHub repo. Vercel auto-detects `vercel.json`; you do **not**
   need to override the build command, install command, or output directory.
4. Click **Deploy**. First build takes ~2–3 min (cold Quarto download). Subsequent
   builds are faster — Vercel caches the binary between deploys.

### Option B — Vercel CLI

```bash
npm i -g vercel        # one-time
vercel login           # one-time
vercel                 # preview deploy from current branch
vercel --prod          # promote latest to production
```

CLI uses the same `vercel.json` so behavior is identical.

---

## Updating the live site

```bash
git add . && git commit -m "update homepage" && git push
```

Vercel watches `main` and redeploys automatically. PRs get preview URLs.

---

## Custom domain

Once you own something like `emmanuelhackman.com`:

1. Vercel dashboard → **Settings → Domains → Add**.
2. Vercel walks you through DNS records:
   - Apex (`emmanuelhackman.com`): `A` record to `76.76.21.21`.
   - `www`: `CNAME` to `cname.vercel-dns.com`.
3. TLS certificates are issued automatically (Let's Encrypt).
4. Update `site-url` in `_quarto.yml` to the new domain so OpenGraph / sitemap
   are correct, then push.

---

## Troubleshooting the build

- **Build fails with "quarto: not found".** Re-check `vercel.json` — the
  `buildCommand` must include `export PATH="$PWD/quarto-1.9.37/bin:$PATH"`
  *before* `quarto render`.
- **404s on nested pages.** `cleanUrls: true` strips `.html`. If that breaks
  internal links, set `cleanUrls: false` in `vercel.json`.
- **Quarto version drift.** Pin a newer release by editing the URL in
  `vercel.json` (and the folder name in the `PATH` export). Latest releases:
  <https://github.com/quarto-dev/quarto-cli/releases>.

---

## Sanity checklist before going live

- [ ] `quarto render` completes locally with no warnings.
- [ ] All nav links work in `_site/index.html`.
- [ ] Portrait, math (`$…$`), and email links render.
- [ ] No remaining placeholders: ORCID `0000-0000-0000-0000`, empty GitHub URLs,
      `*coming soon*` markers you didn't intend to ship.
- [ ] `_quarto.yml` `site-url` matches the live domain.
