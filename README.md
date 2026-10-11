# profile-data-template

> **Workspace de datos de profile-as-code** — tu identidad profesional como código.
> Este repo es un **template**: usalo con *Use this template* o fork/clone, y reemplazá el contenido
> de ejemplo con TUS datos. El engine ([profile-as-code](https://github.com/ChristianLuciani/profile-as-code))
> NUNCA vive aquí ni copia tus datos — solo los lee por ruta.

## Qué es esto

Un solo source of truth (YAML versionado) de tus hechos profesionales → textos optimizados por
plataforma (LinkedIn, GitHub, Upwork, X, ResearchGate, Substack…) con skills por plataforma.

- **Hechos** (fechas, proyectos, papers, DOIs) → deterministas, validados, con drift-check (GEO: un
  LLM que cruza tus perfiles debe encontrar los mismos hechos).
- **Textos** (headlines, bios, ángulos) → generados por plataforma, en variantes que VOS elegís,
  por idioma (`en` esencial, `es` nativo, `fr` deseable).
- **Deploy** → manual con checklist (LinkedIn, Upwork…) o git/API (GitHub README, web).

## Uso — arranque en <10 min

1. Creá tu workspace con el CLI de GitHub (recomendado: crea el repo **privado directamente**
   —elimina los dos pasos manuales, renombrar y flipar a privado, donde más se deja la data
   expuesta):

   ```sh
   gh repo create profile-data-<username> \
     --template https://github.com/ChristianLuciani/profile-data-template \
     --private
   ```

   Alternativa manual: **Use this template** o **fork** en GitHub (el fork queda conectado
   upstream) y **renombrá el resultado a `profile-data-<username>`** — el owner va en el
   nombre y el prefijo de la familia gana (terminología canónica: SPEC §9.1 del engine).
   Hacelo **privado** — tus datos no son públicos (salvo que quieras).
2. Cloná y entrá:

   ```bash
   git clone git@github.com:<tu-usuario>/profile-data-<username>.git
   cd profile-data-<username>
   ```

3. **No hace falta instalar el engine.** `.github/workflows/build.yml` corre `pasco`
   desde npm y commitea `profiles/` por vos: editá `content/` en el editor web de
   GitHub y las vistas generadas aparecen solas. El template fija la versión que
   espera — **`@profile-as-code/cli@0.2.0`**, donde `pasco` es el bin que instala
   ese paquete ([OFICIAL] [WEB: registry.npmjs.org, verificado 2026-10-09]).

   Solo para correrlo local: `npm i -g @profile-as-code/cli@0.2.0`.

   > En un fork, habilitá Actions (vienen deshabilitadas) y en *Settings → Actions →
   > General → Workflow permissions* elegí **Read and write** — el workflow
   > commitea `profiles/`.

4. Editá `content/` — reemplazá el ejemplo ficticio con tus datos (contrato:
   `schema/profile.schema.json`; cada archivo ES una root property — `bios.yaml` es el
   array `bios[]` directamente, sin key wrapper):
   - `identity.yaml` — nombre, ubicación, links canónicos (TU source of truth de URLs)
   - `positioning.yaml` — tu enunciado de posicionamiento + ángulos por audiencia + anclas GEO
   - `bios.yaml`, `headlines.yaml` — por plataforma/idioma/longitud
   - `skills.yaml`, `experience.yaml`, `projects.yaml`, `publications.yaml`, `keywords.yaml`

5. Construí y validá (local — el workflow ya corre `validate` + `build` en cada push):

   ```bash
   pasco validate         # schema (fail) + drift/geo (warn) — D12
   pasco build            # base texts deterministas por plataforma (sin arg = todas)
   pasco diff             # cambios desde el último release (→ CHANGELOG)
   pasco refine linkedin  # variantes IA (stub en M1, M3/M4) — agente propone, vos elegís
   pasco check            # checks declarativos (stub en M1, M4)
   pasco status           # estado por entrada — origen · superficies · in-sync/stale/never (D18)
   pasco status --write-checklist   # regenera CHECKLIST.md desde el ledger (AUTO-GENERATED)
   ```

6. **Deploy:** pegá lo generado en cada plataforma (ver `CHECKLIST.md`) o dejá que git/API
   actualice GitHub README y web. Confirmá cada pega con el ledger (D18):

   ```bash
   pasco status --mark experience:exp-example-labs linkedin
   # registra deployedAt + contentHash en content/deployments.yaml — solo `pasco` lo escribe
   ```

   El ledger responde por cada pieza: ¿mía o del template? (`origin`), ¿publicada dónde?,
   ¿en-sync o stale? — y `pasco status --write-checklist` regenera `CHECKLIST.md`
   (vista AUTO-GENERADA: no la edites a mano después de eso).
7. **Versioná:** cada cambio entra con `CHANGELOG.md` actualizado → sabés qué re-pegar y dónde.

## Estructura

```
profile-data-<username>/
├── content/             # ← TU información (YAML · deployments.yaml = ledger D18)
├── profiles/            # outputs generados (se commitean: son los artefactos de deploy)
├── .github/workflows/   # build.yml = `pasco` desde npm → commitea profiles/ (R2)
├── CHANGELOG.md         # cada cambio: fecha + qué plataformas re-pegar
├── CHECKLIST.md         # verificación por plataforma post-pega
└── .pascorc             # configuración del CLI (workspace path, defaults)
```

## Reglas

- Los datos de ejemplo en `content/` son una **persona ficticia** (Alex Rivera) — documentan el schema.
- `profiles/` se regenera con `pasco build`; no lo edites a mano (se pisa).
- El engine es de solo lectura sobre este repo, salvo `pasco refine` (variante elegida) y
  `pasco status --mark` (ledger de deploy) — ambas escriben solo en `content/` (D14).
- Multi-identidad: si mañana manejás una **identidad comercial/marca**, creá otro workspace
  (mismo engine) — uno por identidad, mismo naming: `profile-data-<identidad>`
  (p.ej. `profile-data-topia`).

## Enlaces

- Engine: https://github.com/ChristianLuciani/profile-as-code
- Spec del engine: `docs/SPEC.md` allí (§9 = este template)
- Prior-art: `docs/research/01-prior-art.md`
