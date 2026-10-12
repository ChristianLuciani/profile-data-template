## v0.3.0 — 2026-10-12 — primer release del scaffold: CONTRIBUTING completo + release (issue #12, ROADMAP item 7)
- Qué cambió:
  - **Primer tag del scaffold: `v0.3.0`** — desde acá el template se versiona espejando
    el pin del engine: `MAJOR.MINOR` = `@profile-as-code/cli`, `PATCH` = revisión propia
    del scaffold. Corte del tag y re-sync de un fork: `CONTRIBUTING.md` § Releases. Las
    entradas anteriores a esta no llevan tag (historia pre-release); el tag se crea
    sobre `main` en el commit de merge.
  - **`.pascorc` → `diff.tagPattern: "v*"`** — traía el default `release-*`, que no
    matchea el tag del release. Reproducido contra el engine 0.3.0 en un repo de prueba
    (tag `v0.3.0` a mitad de historia): con `v*` → `tag: v0.3.0`, base = commit del
    release, 1 commit desde el tag; con `release-*` → `tag: null`, base = primer commit,
    2 commits (el propio release incluido). El default habría hecho que `pasco diff`
    nunca viera el release.
  - **`CONTRIBUTING.md` completo** — setup local con el engine **pinneado**
    (`npm i -g @profile-as-code/cli@0.3.0`, bin `pasco`), la regla "nunca editar
    `profiles/` a mano" (`pasco build` + commit), sección **CI** (los dos workflows, la
    excepción del bot y por qué su push no dispara `checks.yml`) y sección **Releases**
    (esquema de versión + corte del tag + re-sync de un fork). Ya no manda a clonar el
    engine ni a correr `scripts/schema-check/check.py`: esa no es la interfaz publicada.
  - **`docs/STANDARDS.md`** — la regla "Never push to `main`" ahora declara la excepción
    que `build.yml` ejecuta (el bot commitea `profiles/` en el workspace del usuario,
    nunca en el template: guard fail-closed), y la línea de CI nombra los dos workflows
    en vez de solo `checks.yml`.
  - **Diferidos de los dos comentarios de review de #12 (los 8):**
    - `content/bios.yaml` — `pac refine` → `pasco refine` (drift del rename #38).
    - `AGENTS.md` — `.pascorc` nombra sus claves reales (`workspace`, `defaults`,
      `diff`), fila de mapa para `.github/scripts/`, y `pasco check` en los comandos.
    - **Gate que parsee los workflows** (job `yaml` de `checks.yml`): el propio
      `checks.yml` documenta el `startup_failure` por un alias YAML incidental y
      `build.yml` no tenía cobertura; ahora los dos se parsean en cada push/PR.
    - **El commit generado pasa por un chequeo de links**: el push del bot usa
      `GITHUB_TOKEN` y GitHub no dispara workflows por eventos propios ⇒ `checks.yml`
      nunca veía `profiles/` generado. El link-check corre **dentro** de `build.yml`
      antes del commit, con el script compartido `.github/scripts/check-links.sh` (una
      copia, dos callers — antes la lógica vivía inline en `checks.yml`).
    - **`build.yml`** — expresión hoisteada a `env:` (interpolaba antes de que el shell
      viera el script); guard `is_template` **fail-closed** (campo ausente del payload
      ⇒ error, no push a ciegas); acciones del job con `contents: write` **pinneadas por
      SHA**, salidas de la API: `actions/checkout` `11d5960a…` (= `v4`, tip 2026-07-16)
      y `actions/setup-node` `49933ea5…` (= `v4.4.0`).
- **Rondas de review (misma rama):** cada corrección reproducida antes de corregir:
  - **Claim falso "el engine es read-only salvo dos excepciones que escriben solo
    en `content/`"** — son **cuatro** escritores y **dos quedan fuera** de
    `content/`: `pasco build` → `profiles/`, `pasco status --write-checklist` →
    `CHECKLIST.md` (verificado en el engine: `status.ts` escribe
    `join(workspace, "CHECKLIST.md")`; `refine.ts` → `content/active.yaml`). La
    misma frase falsa estaba en `README.md` → corregida en ambos.
  - **El gate de workflows no podía cubrir `checks.yml`**: un error de YAML ahí es
    un `startup_failure`, así que un job adentro nunca corre para reportarlo — la
    clase de incidente que el propio archivo documenta. Movido a
    **`.github/workflows/workflow-lint.yml`**, que no depende del archivo que
    valida. Residual declarado: un error en el propio lint sigue siendo
    `startup_failure` (nada se valida a sí mismo).
  - **El gate de links podía pasar en silencio**: si `git ls-files` falla, la lista
    vuelve vacía y reportaba éxito tras chequear 0 archivos → ahora exit 1
    (pre-existente en la versión inline que este PR extrajo).
  - **Falsos positivos del regex de links** (`[x](f.md "title")`, `[x](<a b.md>)`)
    y el comentario del `|| true`, que afirmaba algo falso (un shell hijo no hereda
    `-e`): regex endurecido y comentario reescrito.
  - La lista de superficies del pin en § Releases omitía **este mismo archivo**, y
    el snippet de re-sync no funcionaba para una copia `--template` (no tiene el
    tag local) → ambos corregidos.
  - Nuevo **self-test del gate de links** en `checks.yml` (fixture roto ⇒ exit 1,
    en modo argumentos): ningún job ejercía su camino de falla, porque `build.yml`
    no ejecuta esa rama en este repo (`is_template: true`).
  - **Reconciliación del veredicto premerge publicado** (`PASS-CON-RIESGOS`,
    corrido contra el head `27e4560`, dos commits atrás): sus dos MAJOR —F1 (gate
    verde tras chequear 0 archivos) y F2 (la lista de superficies del pin)— ya
    estaban corregidos en `d5a3d82`, y F3 en `bff8155`; F1 se reprodujo en el head
    actual y da exit 1. Los dos NIT que seguían vivos se corrigen acá: la regla 3
    de `AGENTS.md` no pedía `pasco check` (que este mismo PR promovió en Commands y
    en CI) y `STANDARDS.md` describía `build.yml` solo con `build`.
- Re-pegar en: — (scaffold).
- **Premisas del issue corregidas (C2):**
  - El issue pide pin `@profile-as-code/cli@0.2.0`; el repo **ya** pineaba `0.3.0` desde
    el PR #14 (necesario para el schema M7). `CONTRIBUTING.md` documenta el pin real.
  - El SHA que el comentario de review daba para `setup-node` (`11bd7190…`) es en
    realidad un commit de `actions/checkout` (`v4.2.2`): pinear `setup-node` con ese
    valor no resuelve la acción. Los de arriba salen de
    `gh api repos/<owner>/<repo>/git/ref/tags/<ref>`.
- Verificado 2026-10-12 (engine `@profile-as-code/cli@0.3.0` de npm): `validate` exit 0
  (schema valid · drift 0 · geo 81/100) · `check` exit 0 (registry 0 findings · media 0
  findings) · 12 `content/*.yaml` y **2 workflows** parsean · `.pascorc` JSON válido con
  `tagPattern: "v*"` · probe de `diff` con los dos patrones (arriba) · gate de links: 11
  `.md` tracked resuelven, y falla (exit 1) ante un fixture roto, en un lote mixto y
  sobre el markdown generado estageado, mientras pasa en un archivo sin links y en uno
  con solo externos/anclas · guard del bot: `false` procede, `true` saltea, ausente ⇒
  exit 1 (fail-closed) · array vacío bajo `set -euo pipefail` no rompe el step ·
  **3 workflows** parsean · el self-test del gate se ejecutó verbatim y se probó
  contra un gate neutralizado (falla como debe) · el regex endurecido se probó en
  los 4 casos nuevos (`"title"`, `<>`, `#frag`, nombre con espacios).

## 2026-10-12 — scaffold del registro de evidencia: media/ + packs + ejemplos (issue #8, D17/§18)
- Qué cambió:
  - **`media/`** con `certificates/`, `photos/`, `press/` + `media/README.md`: qué
    pertenece ahí (chico y versionable), límites (>50 MB warn, 100 MB límite duro de
    GitHub), la **regla de no-hot-link** (la media llega a lo público solo por
    `media/ → assets/ → deploy`) y la alternativa `PASCO_EVIDENCE_ROOT`.
  - **`docs/evidence-packs.md`** — checklists por dominio (diseñador, filmmaker,
    científico, ingeniero) mapeados a los kinds reales del schema + metadata esperada.
  - **`docs/power-user-symlinks.md`** — symlink/stow: git guarda el *texto* del link,
    los targets absolutos rompen CI y clones frescos; nunca el mecanismo canónico.
  - **`content/credentials.yaml` + `content/artifacts.yaml`** — ejemplos que
    **validan hoy** (el schema M7 ya está deployado) + ejemplos comentados de
    `visibility: private` y `locator.path`.
  - **`README.md`** — sección de flujo de evidencia: claim ≠ credential ≠ artifact,
    cómo agregar una entrada, matriz de locators, reglas de visibilidad y PII.
  - **`CHECKLIST.md`** — gate de evidencia pre-deploy: `credential-expiry`,
    `no-private-in-public-output`, `verifyUrl` resoluble, `media-missing-workspace`,
    `media-oversize`, `media-symlink-external`, checksums y verificación de assets.
  - **`AGENTS.md`** — mapa + regla 8 (naming del registro + regla de no-hot-link).
  - **Pin del engine `0.2.0` → `0.3.0`** (README, `AGENTS.md`, `build.yml`) —
    **necesario**: los bloques `credentials`/`artifacts` y los checks M7/M8 llegan
    recién en el schema v1.4+, ausentes en 0.2.0 ([OFICIAL] registry.npmjs.org,
    `@profile-as-code/cli` dist-tags `latest: 0.3.0`, verificado 2026-10-12).
- Re-pegar en: — (scaffold).
- Verificado 2026-10-12 contra el engine local v0.3.0 desde el monorepo:
  `validate` exit 0 (schema valid · drift 0 · geo 81/100) · `check` exit 0 (registry 0
  findings · media 0 findings) · `check` **falla** correctamente en un workspace de
  prueba con credencial expirada (`credential-expired`, warn) y con un `path` de media
  ausente (`media-missing-workspace`, error) · `build github-readme` bundlea
  `assets/<id>/<basename>` + `manifest.json` con sha256 · loader OK en los 4 casos
  (archivo ausente / vacío / `null` / solo comentarios) · JSON-LD `hasCredential` emitido.
- **Nota de alcance:** el issue asumía que los ítems 5–6 debían quedar comentados
  esperando M7; M7 ya está mergeado y publicado, así que los ejemplos salen **vivos y
  validados**. El punto abierto del issue (loader debe saltear archivos
  ausentes/vacíos) queda **verificado como resuelto** en el engine actual.
- **Ronda de review (misma rama):** tres correcciones donde la prosa no coincidía con
  el comportamiento real del engine, las tres reproducidas antes de corregir:
  - **`unlisted` no es un modo de compartir** — es indistinguible de `private` para el
    gate: cablear una credencial `unlisted` desde un claim **falla** con
    `check/private-in-public-output` (exit 1). README, `docs/evidence-packs.md` y
    CHECKLIST lo vendían como "se comparte a pedido" y hasta lo recomendaban.
  - **El gate de evidencia no corría en ningún lado** — `build.yml` solo hacía
    `validate` + `build`, y no tiene trigger de `pull_request`, así que `pasco check`
    nunca podía bloquear un PR. Nuevo job `evidence` en `checks.yml` (PR-triggered)
    que instala el engine y corre `validate` + `check`.
  - **La receta "agregar una credencial" omitía la consecuencia del `id`** — referenciar
    un id inexistente falla `validate` con `dangling cross-ref` (exit 1), justo el
    error que los docs describían a una página de distancia. La receta ahora declara
    el paso de wiring como tal, con el requisito de `id` existente + `visibility: public`.
  - Además: los 4 códigos `media-*` que faltaban en el CHECKLIST
    (`media-path-unsafe`, `media-not-a-file`, `media-external-missing`,
    `media-unbundled-no-id`, los cuatro reproducidos), el placeholder
    `sha256:0000…` reemplazado por instrucción de `shasum -a 256` (el placeholder
    pasaba `validate` pero rompía `check` en cuanto la entrada fuera pública),
    `.gitkeep` como ítem de limpieza, y aclaración de que **`press[]` es brand-only**
    (el template es flavor `person`: un write-up va como artifact `document`).
- Verificación de la ronda: `validate` + `check` exit 0 con el CLI **publicado**
  (`@profile-as-code/cli@0.3.0` de npm — el artefacto que corre CI, no el monorepo) ·
  6 inyecciones de falla reproducidas · ambos workflows parsean como YAML (el repo ya
  tuvo un `startup_failure` por prosa no comentada) · fresh clone verificado.

## 2026-10-10 — pin del engine (publicado el 2026-10-09) + workflow build R2 (issue #11)
- Qué cambió: el README deja de mandar a compilar el engine desde el monorepo — el
  paquete real es **`@profile-as-code/cli@0.2.0`** (`pasco` es el bin) y el template
  lo fija; arranque sin terminal (editás `content/` en el browser). Nuevo
  `.github/workflows/build.yml` (R2 de `profile-as-code#122`): `validate` + `build`
  desde npm (node 22, el mínimo del engine) commitea `profiles/` en tu workspace; en
  un repo `is_template` el bot no pushea a `main` (excepción declarada a la regla 6).
  AGENTS.md: mapa + pin. Drift corregido: `profiles/github-profile/` →
  **`profiles/github-readme/`** (`CHECKLIST.md`, `profiles/README.md`).
- Re-pegar en: — (scaffold).
- Verificado 2026-10-10 con el engine pinneado: `validate` exit 0 (schema valid ·
  drift 0 · geo 81/100) · `build` determinista · yaml + links OK.
- **Fuera de este PR** (hard stop D5): CONTRIBUTING + release del template → #12.

## 2026-09-15 — migración identity.email (v1.5/#71) + rename .pascorc (#38)
- Qué cambió:
  - **Email como hecho (v1.5, issue #71, engine PR #72):** el ejemplo Alex Rivera
    lleva `email: alex@example.com` al nivel raíz de `identity` — la fila
    `platform: email` con `mailto:` se elimina de `links[]` (el boundary de schemes
    `^https?://` de PR #64 la rechaza: todo workspace clonado fallaba
    `pasco validate` día uno).
  - **Rename `.pacrc` → `.pascorc`** (issue #38: bin `pac` → `pasco`) — el CLI
    vigente rechaza el `.pacrc` legacy; el scaffold lo renueva.
  - README + `profiles/README.md`: comandos `pac` → `pasco`.
- Re-pegar en: — (scaffold; los usuarios re-clonan o aplican el mismo cambio en
  su workspace: fila email de links[] → `email:` raíz).
- Verificado: `pasco validate` (engine PR #72) schema OK · drift 0 · YAML CI OK.

## 2026-09-15 — D18 adoption: origin stamps + ids + ledger stub (issue #7)
- Qué cambió: filas de ejemplo de `experience/projects/publications` llevan `id` estable
  (`exp-example-*`, `proj-example-*`, `pub-example-*` — trackables por `pasco status`) y
  `origin: template` (procedencia D18 §19.2 — absent = user-authored). Stub vacío
  `content/deployments.yaml` (ledger por entrada — solo `pasco` escribe). README: paso de
  confirmación `pasco status --mark <ledgerKey> <surface>` en el flujo de deploy + comando
  del CLI corregido `pac` → `pasco` (drift de naming: el bin real es `pasco`).
  CHECKLIST.md: nota de transición a vista AUTO-GENERADA (`--write-checklist` sobrescribe).
- Re-pegar en: — (no aplica; scaffold del template)
- Verificado: `pasco validate` exit 0 (schema v1.3) · `pasco status` — 6 unidades
  tracked `[template]`, 0 untracked, 0 stale · yaml parse OK · links OK

## 2026-09-07 — README: workspace per-user = `profile-data-<username>` + bootstrap gh
- Qué cambió: guía de arranque alineada a la terminología canónica del engine (SPEC
  §9.1, per-user naming): el workspace se llama `profile-data-<username>` (owner en el
  nombre, prefijo de familia gana). Camino recomendado CLI-first: `gh repo create
  profile-data-<username> --template … --private` (crea privado directo). H1 del README
  corregido a `profile-data-template` (drift del rename de PR #3).
- Re-pegar en: — (no aplica; docs del template)
- Verificado: links relativos OK + yaml parse OK — CI `checks.yml` verde (run 34159636684,
  primer run exitoso del repo).

## 2026-08-08 — init del workspace
- Qué cambió: template inicial con persona ficticia de ejemplo.
- Re-pegar en: — (aún sin deploy)
- Verificado: —

## 2026-08-11 — familia profile-*: rename a profile-data-template
- Qué cambió: el template se renombra a **profile-data-template** (y el workspace del
  usuario a **profile-data**) — "profile" primero: agrupación alfabética, un modelo
  mental con el engine (profile-as-code). Instrucción de fork actualizada:
  renombrar el fork a `profile-data` y hacerlo privado.
- Re-pegar en: — (no aplica; naming)
- Verificado: repos renombrados en GitHub (las URLs viejas redirigen).

## 2026-08-10 — conformidad al contrato v1 (primer test e2e del engine)
- Qué cambió: data alineada a schema/profile.schema.json v1 (M1): file = root property
  (sin key wrapper), identity.links como array {platform,label,url}, fechas YYYY-MM-DD,
  highlights como string por idioma, platformWeights 0..1, projects.links como array,
  evidence {claim,source,verified}, headlines en su propio archivo, `.pacrc` JSON
  ({workspace,defaults,diff}). Anclas GEO honestas (refuerzo real).
- Re-pegar en: — (aún sin deploy)
- Verificado: `pac validate` exit 0 (schema válido, drift 0, geo 84/100);
  `pac build` renderiza base texts en en/es.

