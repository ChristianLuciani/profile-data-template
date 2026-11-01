# profile-data-template

> **Tu identidad profesional como código.** Un workspace de datos forkable para el
> engine [profile-as-code](https://github.com/ChristianLuciani/profile-as-code):
> los hechos viven en YAML, los textos por plataforma se renderizan desde ellos, y
> una sola fuente de verdad mantiene todos tus perfiles consistentes.

[![checks](https://github.com/ChristianLuciani/profile-data-template/actions/workflows/checks.yml/badge.svg)](https://github.com/ChristianLuciani/profile-data-template/actions/workflows/checks.yml)
[![license: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![engine: 0.3.7](https://img.shields.io/badge/engine-%40profile--as--code%2Fcli%400.3.7-blue)](https://www.npmjs.com/package/@profile-as-code/cli)

**Este repositorio es un template, no el engine.** No contiene código de
aplicación. Lo copiás, reemplazás el ejemplo ficticio por tus hechos, y el engine
valida y renderiza el resultado.

| Si querés… | Vive en |
|---|---|
| Este layout de workspace, docs y CI | **este repo** |
| El CLI `pasco`, el schema, los renderers | [profile-as-code](https://github.com/ChristianLuciani/profile-as-code) |
| `schema/profile.schema.json` | [schema del engine](https://github.com/ChristianLuciani/profile-as-code/blob/main/schema/profile.schema.json) |
| La SPEC del engine (`§9` cubre este template) | [docs/SPEC.md del engine](https://github.com/ChristianLuciani/profile-as-code/blob/main/docs/SPEC.md) |
| Prior-art / notas de research | [docs/research/01-prior-art.md del engine](https://github.com/ChristianLuciani/profile-as-code/blob/main/docs/research/01-prior-art.md) |

## Estado

- Scaffold **v0.3.2**, alineado a `@profile-as-code/cli@0.3.7` — el `latest`
  actual en npm, verificado 2026-10-31 ([OFICIAL] [WEB: registry.npmjs.org]).
  `.pascorc` declara `"engine": "0.3.7"` — el piso que `pasco doctor`, `validate`,
  `build` y `preview` hacen cumplir desde 0.3.7. Un CLI más viejo no lee la clave:
  aplica sus propias reglas y renderiza un árbol que este scaffold no documenta, así
  que pinneá la instalación como hacen los comandos de abajo.
- El contenido de ejemplo es una **persona ficticia** (Alex Rivera) que documenta
  el schema — la superficie de respuestas (`identity.definition`, `faq[]`), la
  referencia al registro (`projects[].artifactRefs`) junto a los dos hechos que la
  acompañan (`nationality` v1.13, `publication.kind` v1.14) y el evento de release
  (`releases[]`), hasta **v1.15**. No pongas datos reales en este repositorio; tus
  datos van en tu fork.
- Mantenimiento best-effort. Issues y PRs se triajan; ver
  [CONTRIBUTING.md](CONTRIBUTING.md).

## Por qué existe

Un perfil se publica en muchos lugares y cada uno deriva. Este workspace hace que
los hechos sean la fuente de verdad:

- **Hechos** (fechas, roles, proyectos, papers, DOIs) deterministas, validados y
  con drift-check — un LLM que cruza tus perfiles debe encontrar los mismos hechos
  en todos lados (consistencia GEO).
- **Textos** (headlines, bios, ángulos) generados por plataforma e idioma (`en`
  esencial, `es` nativo; `fr` deseable), en variantes que elegís vos.
- **Evidencia** como registro de primera clase: claims, credenciales de terceros y
  artifacts son cosas distintas y se nombran como tales.
- **Deploy** trazado: un ledger registra qué se pegó dónde y si sigue en sync con
  `content/`.

## Arranque en menos de 10 minutos — privado primero

> **Regla de privacidad #0:** creá el repositorio **privado antes de escribir un
> solo hecho**. Un repo profile-data público expone tus datos de contacto,
> historial y media. El camino con CLI de abajo lo crea privado en un paso.

1. Creá tu workspace desde el template, privado:

   ```sh
   gh repo create profile-data-<username> \
     --template ChristianLuciani/profile-data-template \
     --private
   ```

   Alternativa manual: **Use this template** (o fork) en GitHub, después
   **renombralo a `profile-data-<username>`** y hacelo **privado**. El nombre lleva
   el owner y el prefijo de la familia (naming canónico, SPEC §9.1 del engine).

2. Clonalo:

   ```bash
   git clone git@github.com:<tu-usuario>/profile-data-<username>.git
   cd profile-data-<username>
   ```

3. **No necesitás instalar el engine para obtener output.** En tu copia,
   `.github/workflows/build.yml` instala `pasco` pinneado desde npm y commitea
   `profiles/` generado en cada push a `main` que toque `content/`. Editá
   `content/` desde el editor web de GitHub y las vistas aparecen.

   > Confirmá que **Actions** esté habilitado en tu copia. **No** hace falta tocar
   > *Settings → Workflow permissions*: el workflow declara su propio
   > `contents: write`. Revisá la pestaña **Actions** después del primer push.

   Para correrlo local, se requiere Node **22+** (`engines` del engine):

   ```bash
   npm i -g @profile-as-code/cli@0.3.7
   ```

4. Reemplazá el ejemplo de `content/` con tus hechos. Cada archivo **ES** su root
   property — `bios.yaml` es el array `bios[]` directamente, sin key wrapper
   ([schema](https://github.com/ChristianLuciani/profile-as-code/blob/main/schema/profile.schema.json)):

   - `identity.yaml` — nombre, ubicación, links canónicos (la SSOT de tus URLs),
     `definition` y `nationality` (v1.10 / v1.13)
   - `positioning.yaml` — statement de posicionamiento, ángulos por audiencia, anclas GEO
   - `bios.yaml`, `headlines.yaml` — por plataforma, idioma y longitud
   - `skills.yaml`, `experience.yaml`, `projects.yaml`, `publications.yaml`, `keywords.yaml`
   - `faq.yaml` — los pares de respuesta citables detrás del bloque `FAQPage` (v1.10)
   - `releases.yaml` — eventos de release y el fan-out de presencia (v1.15)

5. Validá y construí:

   ```bash
   pasco doctor           # engine · schema · workspace válido · requisito de .pascorc cumplido
   pasco validate         # schema FALLA (exit 1); drift/GEO AVISA (exit 0)
   pasco check            # gate offline: registro (M7/§18.8), transporte de media (M8/§18.6),
                          # límites y fact-present sobre las superficies construidas
   pasco build            # output determinista por plataforma (sin arg = todas)
   pasco preview          # una página HTML autocontenida en .pasco/preview (no es publicación)
   pasco diff             # cambios desde el último tag de release → CHANGELOG
   pasco refine linkedin  # PARCIAL: emite un task de agente; --choose registra la elegida
   pasco status           # por entrada: origen · superficies · in-sync/stale/never
   pasco status --write-checklist   # regenera CHECKLIST.md desde el ledger
   ```

6. **Deploy.** Pegá cada texto generado en su plataforma (ver
   [CHECKLIST.es.md](CHECKLIST.es.md)), o dejá que git/API actualice tu README de GitHub
   y tu web. Registrá cada pega para que el ledger sepa qué está vivo:

   ```bash
   pasco status --mark experience:exp-example-labs linkedin
   # escribe deployedAt + contentHash en content/deployments.yaml — solo pasco lo hace
   ```

7. **Versioná.** Cada cambio entra con una entrada en `CHANGELOG.md`, así sabés
   qué re-pegar y dónde.

## Qué escribe el engine

El engine escribe solo cuando escribir es el trabajo del comando, y solo donde
se lo pedís. Ningún comando de lectura reescribe tus hechos como efecto colateral:

| Comando | Escribe |
|---|---|
| `pasco build` | `profiles/<platform>/` (+ `assets/` bundleados) — derivado, commiteado |
| `pasco refine --choose` | `content/active.yaml` — la variante que elegiste |
| `pasco edit <contract-path> --set` | ese único campo en `content/*.yaml` (preserva comentarios, valida, atómico) |
| `pasco status --mark` | `content/deployments.yaml` — el ledger de deploy (D18) |
| `pasco status --verify` | la certificación en `content/deployments.yaml` (el único camino con red, opt-in) |
| `pasco status --write-checklist` | `CHECKLIST.md` — vista AUTO-GENERADA del ledger |
| `pasco preview` | `.pasco/preview/` (gitignored), o el directorio que pases en `--out` |
| `pasco export … --out`, `pasco entity --jsonld --out` | solo la ruta que pasás a `--out`; `--check` y `export profile --json` no escriben (imprimen) |
| `pasco post seed/task/choose/import` | `posts/<id>/…` — solo si usás el flujo MVP de posts |

`profiles/` es output generado y **sí** se commitea en tu workspace: es el
artefacto de deploy. Nunca lo edites a mano — corregí `content/` y reconstruí.
**Este template es la excepción**: su bot de `build.yml` se niega a commitear el
output (`is_template` — ver la fila de build abajo y `profiles/README.md`).
`.pasco/` es estado local y está gitignored.

## Los tres conceptos de evidencia (no los mezcles)

| Concepto | Bloque | Qué es | Ejemplo |
|---|---|---|---|
| **Claim** | `projects[].evidence[]` | afirmación textual + fuente | "levanté $2M" → link a TechCrunch |
| **Credential** | `content/credentials.yaml` | atestación de terceros | certificado AWS, título, premio, patente |
| **Artifact** | `content/artifacts.yaml` | una obra o media | portfolio, showreel, dataset, código |

`publications[]` y `press[]` conservan sus bloques y **referencian** ids del
registro vía `artifactRefs`; no son kinds del registro. (`press[]` es un bloque del
flavor **brand**; este template trae `flavor: person`, así que un write-up *sobre
vos* es un artifact de `kind: document` o un claim. Ver
[docs/evidence-packs.md](docs/evidence-packs.md).)

Una referencia a un `id` que no existe falla el load (`dangling cross-ref`,
exit 1) — no se ignora en silencio.

### Visibilidad — la regla es más estricta que los nombres

`visibility: public | unlisted | private` (ausente = `public`). Solo `public`
cuenta como público. `unlisted` y `private` se tratan igual a los efectos del
gate: ninguno puede referenciarse desde output público, y ninguno se emite en los
renders. `pasco check` falla el build si material público referencia uno.

### Media — un solo camino a la web pública

`media/` guarda binarios chicos y versionables. Un locator `path` es la fuente de
verdad; el renderer lo bundlea en `profiles/<platform>/assets/` con un manifest
`sha256`, y el output deployado linkea un `assets/<id>/<basename>`
**deploy-relative**. Nunca hot-linkees un archivo de un repo privado: para el
resto del mundo es un 404.

Límites y tradeoffs: [media/README.md](media/README.md),
[docs/power-user-symlinks.md](docs/power-user-symlinks.md).

## Mapa del repositorio

```
profile-data-<username>/
├── content/              # TUS datos (YAML)
│   ├── credentials.yaml  # atestaciones de terceros (opcional, D17/§18)
│   ├── artifacts.yaml    # obras y media (opcional, D17/§18)
│   ├── faq.yaml          # pares de Q&A citables / FAQPage (opcional, v1.10)
│   ├── releases.yaml     # eventos de release + fan-out de presencia (opcional, v1.15)
│   └── deployments.yaml  # ledger de deploy (solo lo escribe pasco status --mark)
├── media/                # binarios chicos y versionables (opcional, §18.6)
├── docs/                 # evidence packs · symlink/stow · standards
├── profiles/             # artefactos de deploy generados (commiteados, nunca a mano)
├── .github/              # CI, gates de links/secretos/data de ejemplo, plantillas de issue
├── .pascorc              # config del CLI: workspace, defaults, diff.tagPattern, engine
├── CHECKLIST.md          # verificación post-deploy por plataforma (EN · .es)
└── CHANGELOG.md          # cada cambio: fecha + qué re-pegar
```

## CI y automatización

Seis checks más el job de build. Todas las actions están **pinneadas por commit
SHA completo**; [Dependabot](.github/dependabot.yml) mantiene los pins al día.

| Workflow | Trigger | Qué hace |
|---|---|---|
| `checks.yml` → `yaml` | push a main + cada PR | `content/*.yaml` parsea |
| `checks.yml` → `pins` | idem | cada mención de `@profile-as-code/cli` en un workflow o action local es exactamente la versión de `.pascorc` → `engine` (whitelist de strings, no detector de comandos), con self-test de cuatro sondas — el pin tiene una sola fuente |
| `checks.yml` → `links` | idem | links markdown relativos resuelven, más un self-test de que el gate rechaza un link roto |
| `checks.yml` → `example-data` | idem | `content/` sigue siendo ficticio, `media/` sigue vacío, no hay estado local trackeado |
| `checks.yml` → `secrets` | idem | `gitleaks` (CLI pinneada + SHA-256) escanea la historia completa |
| `checks.yml` → `evidence` | idem | `pasco validate` + `pasco check` (el gate §18.8) |
| `workflow-lint.yml` | cambios en workflows | cada archivo de workflow parsea — separado para poder cubrir `checks.yml` mismo |
| `build.yml` | push a main que toca `content/**`, `.pascorc`, el script de links o sí mismo | validate + check + build; commitea `profiles/` en un workspace de usuario y se niega acá (`is_template`, fail-closed) |

El job `example-data` corre **solo en este repositorio template** — un fork lleva
legítimamente una identidad real, así que ahí se saltea (correrlo en un fork
fallaría en cada PR).

El job de build es el único con `contents: write`. En **workspaces de usuario**
commitea el output como `github-actions[bot]`; en **este template** se niega (el
check de `is_template` es fail-closed: si falta el flag, aborta en vez de pushear
a ciegas). Su push usa `GITHUB_TOKEN`, así que no dispara workflows — por eso corre
el gate de links él mismo, con el mismo
[`.github/scripts/check-links.sh`](.github/scripts/check-links.sh) que usa `checks.yml`.

## Seguridad y privacidad

- **Nada de datos reales en este repositorio.** `content/` es un ejemplo ficticio y
  `media/` viene vacío; el CI falla acá si eso deja de ser cierto (el guard se
  saltea en los forks, donde los datos reales son el objetivo).
- **Nunca pegues datos reales de perfil, tokens o media privada en un issue o PR.**
  Este repo es público; tu workspace no.
- **Los reportes de seguridad van por GitHub en privado**, nunca en un issue
  público: ver [SECURITY.md](SECURITY.md).
- **Forkear es tu responsabilidad.** Creá el fork privado, mantené el engine
  pinneado, y revisá las actualizaciones de dependencias antes de mergearlas.
- El estado local que puede contener paths de tu máquina (`.pasco/`) está
  gitignoreado.

## Contribuir

Las contribuciones son bienvenidas cuando ayudan a **todos los usuarios de la
familia**, no a los datos de una persona. Empezá por
[CONTRIBUTING.md](CONTRIBUTING.md); aplica el
[Código de Conducta](CODE_OF_CONDUCT.md). Abrí un issue antes de un feature
grande; bugs y propuestas tienen plantillas.

## Releases

Las versiones espejan el pin del engine: `MAJOR.MINOR` es la línea del engine,
`PATCH` es la revisión de este scaffold. `v0.3.2` es el release actual (engine
`0.3.7`); `v0.3.0` fue el primer release taggeado. El corte del tag, el re-sync
de un fork y la lista de archivos que se bumpean juntos están en
[CONTRIBUTING.md § Releases](CONTRIBUTING.md#releases).

## Troubleshooting

| Síntoma | Causa / fix |
|---|---|
| `pasco: command not found` | Instalalo (`npm i -g @profile-as-code/cli@0.3.7`) o corré `npx -y @profile-as-code/cli@0.3.7 <cmd>` |
| `doctor` sale 1, o `validate`/`build` rechazan por el requisito de engine | El `pasco` instalado está por debajo del piso `engine` de `.pascorc` — instalá al menos esa versión (un CLI más viejo ignora el piso) |
| `validate` falla con `dangling cross-ref` | Un `credentialId` / `artifactId` / `artifactRefs` apunta a un `id` que no existe |
| `check` falla con private-in-public-output | Un claim público referencia una entrada `unlisted`/`private` — hacela `public` o quitá la referencia |
| El bot de build no commitea nada | Confirmá que es un workspace de usuario (no el template), que Actions está habilitado, y que el push tocó uno de los paths vigilados |
| Un workflow muere en 0s (`startup_failure`) | Un error YAML en ese workflow. `workflow-lint.yml` existe para esa clase y parsea los archivos en CI |
| Los links del README generado dan 404 | `assets/` no se commiteó con el output, o el link no es deploy-relative |

## Roadmap

El scaffold sigue los milestones del engine; la línea actual es engine `0.3.x`.
Las prioridades y el trabajo abierto viven en
[issues](https://github.com/ChristianLuciani/profile-data-template/issues) y en el
roadmap del engine. `pasco check` ejecuta hoy las reglas de registro y media; el
resto del catálogo declarativo llega con M3/M4 del engine.

## Licencia

[MIT](LICENSE). Cuando forkeás este template para tu propio workspace, reemplazá la
línea `Copyright (c)` de `LICENSE` con tu nombre.

## Enlaces

- Engine: https://github.com/ChristianLuciani/profile-as-code
- Spec del engine: https://github.com/ChristianLuciani/profile-as-code/blob/main/docs/SPEC.md
- Schema: https://github.com/ChristianLuciani/profile-as-code/blob/main/schema/profile.schema.json
- Roadmap: [ROADMAP.md](ROADMAP.md)
- Prior-art: https://github.com/ChristianLuciani/profile-as-code/blob/main/docs/research/01-prior-art.md
- Media pipeline: https://github.com/ChristianLuciani/profile-as-code/blob/main/docs/media-pipeline.md

---

[English](README.md)
