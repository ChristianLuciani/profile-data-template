# profiles/ — salidas generadas por el engine

Esta carpeta contiene los **artefactos de deploy** renderizados por `pasco build`.
Qué archivos aparecen lo decide el engine **pinneado** en este repo
(`@profile-as-code/cli@0.3.0`), no `main` del engine.

Con ese pin, `pasco build` escribe **un solo archivo**:

```
profiles/
└── github-readme/README.md    # se pushea al repo <user>/<user> (git/API)
```

- Los **paste artifacts por superficie** — `profiles/<platform>.md`, para pegar a
  mano en LinkedIn, Upwork, X, … — llegan con la release del engine que incluya
  profile-as-code **#239**. Hoy ese código está en `main` del engine pero **no**
  en la versión publicada (`latest` = `0.3.0`), así que el template no los
  promete: este árbol se actualiza **con** el pin, en el mismo PR que lo mueva.
- `pasco build` **borra los renders vacíos** (§15.1 del engine): una plataforma
  sin fila de bio para ese idioma no deja archivo.
- La variante elegida por `pasco refine` vive en **`content/active.yaml`**, no
  acá. El store `profiles/<platform>/variants/<id>.md` es de un engine posterior
  (#238) y tampoco aplica al pin actual.
- **No edites a mano** estos archivos: `pasco build` los regenera desde `content/`.
- En **tu workspace** se commitean: son el rastro de qué está publicado y en qué
  versión. En este template no: el bot no commitea output acá (repo
  `is_template`).
