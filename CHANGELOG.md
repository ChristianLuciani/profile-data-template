# CHANGELOG — cada cambio: fecha + qué plataformas re-pegar

Formato por entrada:

```
## AAAA-MM-DD — resumen del cambio
- Qué cambió: (hecho/texto/plataforma)
- Re-pegar en: linkedin, upwork (manual) · github-readme (git/API)
- Verificado: [ ] (marcar en CHECKLIST.md al terminar)
```

---

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

