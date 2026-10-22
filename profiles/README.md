# profiles/ — salidas generadas por el engine

Esta carpeta contiene los **artefactos de deploy** renderizados por `pasco build`.
Qué archivos aparecen lo decide el engine **pinneado** en este repo — su versión y
la lista autoritativa de las superficies que la fijan viven en
`CONTRIBUTING.md` § Releases —, no `main` del engine.

Con ese pin y el **contenido de ejemplo**, `pasco build` produce:

```
profiles/
└── github-readme/README.md    # se pushea al repo <user>/<user> (git/API)
```

Y en cuanto agregás un artifact con `locator: { path: … }` (media versionada en
`media/`), el mismo build suma el bundle — un directorio por plataforma:

```
profiles/github-readme/assets/manifest.json      # sha256 por asset
profiles/github-readme/assets/<id>/<basename>
```

- Los **paste artifacts por superficie** — `profiles/<platform>.md`, para pegar a
  mano en LinkedIn, Upwork, X, … — llegan con la release del engine que incluya
  profile-as-code **#239**. Hoy ese código está en `main` del engine pero **no**
  en ninguna versión publicada (`npm view @profile-as-code/cli versions`), así que
  el template no los promete: este árbol se actualiza **con** el pin, en el mismo
  PR que lo mueva.
- `pasco build` **borra los renders vacíos** (§15.1 del engine): una plataforma
  sin fila de bio para ese idioma no deja archivo.
- La variante elegida por `pasco refine` vive en **`content/active.yaml`**, no
  acá. El store `profiles/<platform>/variants/<id>.md` es de un engine posterior
  (#238) y tampoco aplica al pin actual.
- **No edites a mano** estos archivos: `pasco build` los regenera desde `content/`.
- En **tu workspace** se commitean: son el rastro de qué está publicado y en qué
  versión. En este template no: el bot no commitea output acá (repo
  `is_template`).
