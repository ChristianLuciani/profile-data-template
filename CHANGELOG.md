# CHANGELOG — cada cambio: fecha + qué plataformas re-pegar

Formato por entrada:

```
## AAAA-MM-DD — resumen del cambio
- Qué cambió: (hecho/texto/plataforma)
- Re-pegar en: linkedin, upwork (manual) · github-readme (git/API)
- Verificado: [ ] (marcar en CHECKLIST.md al terminar)
```

---

## 2026-08-08 — init del workspace
- Qué cambió: template inicial con persona ficticia de ejemplo.
- Re-pegar en: — (aún sin deploy)
- Verificado: —

## 2026-08-10 — conformidad al contrato v1 (primer test e2e del engine)
- Qué cambió: data alineada a schema/profile.schema.json v1 (M1): file = root property
  (sin key wrapper), identity.links como array {platform,label,url}, fechas YYYY-MM-DD,
  highlights como string por idioma, platformWeights 0..1, projects.links como array,
  evidence {claim,source,verified}, headlines en su propio archivo, `.pacrc` JSON
  ({workspace,defaults,diff}). Anclas GEO honestas (refuerzo real).
- Re-pegar en: — (aún sin deploy)
- Verificado: `pac validate` exit 0 (schema válido, drift 0, geo 84/100);
  `pac build` renderiza base texts en en/es.

