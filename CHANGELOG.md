## 2026-10-10 — engine 0.2.0 published: pin + R2 build workflow (issue #11)
- Qué cambió: el README deja de mandar a compilar el engine desde el monorepo
  ("`npm i -g profile-as-code` cuando se publique") — el paquete real es
  **`@profile-as-code/cli@0.2.0`** (`pasco` es el bin) y el template lo fija;
  arranque sin terminal (editás `content/` en el browser). Nuevo
  `.github/workflows/build.yml` (R2 de `profile-as-code#122`): `pasco validate`
  + `build` desde npm commitea `profiles/`; en el template el bot no pushea a
  `main` (regla 6) — fuera de sync, el job falla. AGENTS.md: mapa + pin.
- Re-pegar en: — (scaffold).
- Verificado 2026-10-10: `@profile-as-code/cli@0.2.0 validate` exit 0 (schema
  valid · drift 0 · geo 81/100) · `build` determinista · yaml + links OK.
- **Fuera de este PR** (hard stop D5): CONTRIBUTING completo + release del
  template (ROADMAP item 7 del hub) → issue nuevo.

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

