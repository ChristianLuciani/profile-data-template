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
   GitHub y, al pushear a `main`, las vistas generadas se commitean solas. El template
   fija la versión que espera — **`@profile-as-code/cli@0.3.0`** (`pasco` es el bin) —
   ([OFICIAL] [WEB: registry.npmjs.org, verificado 2026-10-12]). Para correrlo local:
   `npm i -g @profile-as-code/cli@0.3.0`.

   > En **tu copia** verificá que Actions esté habilitado. *No* hace falta tocar
   > *Settings → Workflow permissions*: el workflow declara su `contents: write`.
   > La primera vez, confirmá en la pestaña **Actions** que corrió.

4. Editá `content/` — reemplazá el ejemplo ficticio con tus datos (contrato:
   `schema/profile.schema.json`; cada archivo ES una root property — `bios.yaml` es el
   array `bios[]` directamente, sin key wrapper):
   - `identity.yaml` — nombre, ubicación, links canónicos (TU source of truth de URLs)
   - `positioning.yaml` — tu enunciado de posicionamiento + ángulos por audiencia + anclas GEO
   - `bios.yaml`, `headlines.yaml` — por plataforma/idioma/longitud
   - `skills.yaml`, `experience.yaml`, `projects.yaml`, `publications.yaml`, `keywords.yaml`

5. Construí y validá:

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

## Evidencia — probar lo que afirmás

Tu perfil se cree cuando está **probado**. Dos bloques opcionales (D17, SPEC §18 del
engine) registran esa prueba. Si no los usás, dejá los archivos vacíos o borralos: el
loader saltea archivos ausentes o vacíos.

**Tres conceptos que NO se mezclan** (naming canónico, §18.1):

| Concepto | Bloque | Qué es | Ejemplo |
|---|---|---|---|
| **Claim** | `projects[].evidence[]` | afirmación textual + fuente | "levanté $2M" → link a TechCrunch |
| **Credential** | `content/credentials.yaml` | atestación de terceros | certificado AWS, título, premio, patente |
| **Artifact** | `content/artifacts.yaml` | una obra o media | portfolio, galería, showreel, dataset, código |

`publications[]` (papers, DOI) y `press[]` conservan sus bloques y **referencian** ids del
registro vía `artifactRefs` — no se duplican. (`press[]` es del flavor **brand**: este
template es `person`, así que un write-up sobre vos va como artifact `document` o como
claim. Detalle en `docs/evidence-packs.md`.)

### Agregar una credencial o un artifact

1. **Poné el archivo** — si es chico y vale versionarlo (un escaneo, unos stills), va en
   `media/`; si es grande (un showreel de 2 GB), hostealo afuera y usá `url`. Detalle y
   límites de tamaño: `media/README.md`.
2. **Declará el puntero** en `content/credentials.yaml` o `content/artifacts.yaml`.
   Mínimo: `id`, `kind`, `title` (+ `issuer` en credenciales; `locator` en artifacts).
   El `id` tiene que ser único en su bloque y ser un slug (`^[a-z0-9][a-z0-9._:-]*$`).
3. **(Opcional) Cableala desde un claim.** Solo si querés que la prueba aparezca
   asociada a un proyecto: agregá `credentialId: <id>` o `artifactId: <id>` en
   `projects[].evidence[]`, o `artifactRefs: [<id>]` en `publications[]` (y `press[]`, si
   el workspace fuera flavor `brand`).
   **El `id` referenciado tiene que existir ya**: si apuntás a un id que no está en el
   bloque, `pasco validate` **falla** con `dangling cross-ref` (exit 1) — no se ignora
   en silencio. Si declarás la credencial pero no la cableás a nada, no pasa nada: no
   es obligatorio referenciarla.
   Y para que la referencia funcione en el output, la entrada referenciada tiene que
   ser `visibility: public` — ver *Visibilidad* abajo.
4. **Verificá y construí:**

   ```bash
   pasco validate   # schema (falla) + drift/geo (avisa)
   pasco check      # expiración, privacidad y transporte de media
   pasco build github-readme   # bundlea assets/ + manifest.json con sha256
   ```

   Los tres comandos en `0` = listo. `validate` y `check` también corren solos en cada
   PR vía `.github/workflows/checks.yml` (job `evidence`).

**Locators** — la matriz de capacidades (§18.3). Exactamente uno de `url` o `path`:

| Locator | Para qué | En el render |
|---|---|---|
| `{ url: https://… }` | algo ya hosteado (Vimeo, Zenodo, tu sitio) | URL verbatim + live-link check |
| `{ path: media/… }` | archivo versionado en este repo | viaja a `profiles/<platform>/assets/` — **nunca** como URL cruda |
| `{ path: otra-cosa }` | colección externa grande | resuelve bajo `PASCO_EVIDENCE_ROOT` |

**Regla de oro (workspace privado ⇒ sin hot-linking):** la media llega a la superficie
pública **solo** por `media/ → assets/ → deploy`. Nunca pegues un link a un archivo de tu
repo privado en un perfil público: para el resto del mundo es un 404. Un link
`assets/<id>/<basename>` es deploy-relative y resuelve recién en la superficie pública.

### Visibilidad — PII

`visibility: public | unlisted | private` en ambos bloques. Ausente = `public` (un
perfil pre-registro era público por diseño — la ausencia no oculta en silencio).

La regla que el engine **hace cumplir** es binaria y más estricta de lo que sugieren
los nombres: **solo `public` cuenta como público**. `unlisted` y `private` se tratan
igual a los efectos del gate — ninguno de los dos puede ser referenciado desde material
público.

- `public` → los renderers la emiten. Lo único referenciable desde output público.
- `unlisted` → **no se emite en los renders** y **no puede** referenciarse desde un
  claim público. Pensalo como "guardado pero no publicado": existe para que el dato
  esté en el workspace, no para compartirse por un render.
- `private` → nunca sale del workspace.

⚠️ **El caso que rompe el build:** si declarás una credencial `unlisted` y la cableás
desde un claim (`projects[].evidence[].credentialId`), `pasco check` **falla** — igual
que con `private`, y el mensaje del engine dice "visibility unlisted ... public output
renders only public entries". Si querés que la credencial aparezca en el perfil, tiene
que ser `public`. Si no querés que aparezca, no la referencies desde un claim.

```bash
pasco check   # falla (exit 1) si algo público referencia unlisted/private
```

El nombre de la regla en la SPEC es `no-private-in-public-output` (§18.8); el CLI lo
emite como `check/private-in-public-output`. El mensaje dice "private" incluso cuando
la visibility es `unlisted` — es un nombre histórico, no una descripción exacta.

Empezá por `docs/evidence-packs.md` (checklists por dominio: diseñador, filmmaker,
científico, ingeniero). Si querés versionar media grande o stowear una carpeta externa:
`docs/power-user-symlinks.md` (spoiler: git guarda el *texto* del symlink, no los bytes).

## Estructura

```
profile-data-<username>/
├── content/             # ← TU información (YAML · deployments.yaml = ledger D18)
│   ├── credentials.yaml # atestaciones de terceros (opcional — D17/§18)
│   └── artifacts.yaml   # obras y media (opcional — D17/§18)
├── media/               # ← binarios chicos y versionables (opcional — §18.6)
│   ├── certificates/    #   escaneos de credenciales
│   ├── photos/          #   stills, galería
│   └── press/           #   recortes de prensa
├── docs/                # evidence-packs.md · power-user-symlinks.md
├── profiles/            # outputs generados (se commitean: son los artefactos de deploy)
│   └── <platform>/assets/   # media bundleada + manifest.json (sha256) — solo con path locators
├── CHANGELOG.md         # cada cambio: fecha + qué plataformas re-pegar
├── CHECKLIST.md         # verificación por plataforma post-pega
└── .pascorc             # configuración del CLI (workspace path, defaults)
```

## Reglas

- Los datos de ejemplo en `content/` son una **persona ficticia** (Alex Rivera) — documentan el schema.
- `profiles/` se regenera con `pasco build`; no lo edites a mano (se pisa).
- El engine es de solo lectura sobre este repo salvo por sus 4 escritores: `pasco build`
  (`profiles/`), `pasco refine` (`content/active.yaml`), `pasco status --mark`
  (`content/deployments.yaml`, D14) y `pasco status --write-checklist` (`CHECKLIST.md`).
- Multi-identidad: si mañana manejás una **identidad comercial/marca**, creá otro workspace
  (mismo engine) — uno por identidad, mismo naming: `profile-data-<identidad>`
  (p.ej. `profile-data-topia`).

## Enlaces

- Engine: https://github.com/ChristianLuciani/profile-as-code
- Spec del engine: `docs/SPEC.md` allí (§9 = este template)
- Prior-art: `docs/research/01-prior-art.md`
