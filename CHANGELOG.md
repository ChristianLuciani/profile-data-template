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

