# profiles/ — salidas generadas por el engine

Esta carpeta contiene los **artefactos de deploy** renderizados por `pac build`:

```
profiles/
├── github-profile/README.md   # se pushea al repo <user>/<user> (git/API)
├── linkedin.md                # se pega en LinkedIn (manual)
├── upwork.md                  # se pega en Upwork (manual)
├── x.md
├── researchgate.md
└── substack.md
```

- **No edites a mano** estos archivos: `pac build` los regenera desde `content/`.
- Se **commitean** porque son el rastro de qué está publicado y en qué versión.
- La variante elegida en `pac refine` se guarda en `active` (content) y queda como la vigente.
