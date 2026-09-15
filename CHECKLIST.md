# CHECKLIST — verificación por plataforma post-deploy

> **Estado de este archivo (D18, SPEC §19 del engine):** el estado por entrada de deploy
> vive en `content/deployments.yaml` — reportalo con `pasco status`. Cuando confirmes pegás
> con `pasco status --mark <ledgerKey> <surface>`, este archivo pasa a ser la vista
> AUTO-GENERADA del ledger: `pasco status --write-checklist` lo **sobrescribe** desde el
> ledger — desde ese punto, no lo edites a mano. Hasta entonces: las listas de abajo son
> tu verificación manual post-pega.

Después de pegar/actualizar una plataforma, verificá y marcá. La consistencia factual
entre redes ES tu citabilidad (GEO): si un LLM cruza dos perfiles y encuentra
contradicciones, te descarta.

## GitHub (profile README)
- [ ] README actualizado vía git/API (commit en profiles/github-profile)
- [ ] Hechos (rol, fechas, papers) idénticos al resto de las redes
- [ ] Proyectos pinned = los 3-6 que querés mostrar
- [ ] Links a todos los perfiles (sameAs)

## LinkedIn
- [ ] Headline ≤ límite oficial (ver skill) y coherente con positioning.statement
- [ ] About pegado y revisado (variante elegida en `active`)
- [ ] Skills ordenadas por peso (platformWeights)
- [ ] Featured: projects + publications (DOI resolubles)
- [ ] Fechas de experiencia idénticas a GitHub/web

## Upwork
- [ ] Title/overview pegado (EN-first) y coherente con audience.clients
- [ ] Especialidades y skills correctas (platformWeights upwork)
- [ ] Portfolio conectado a los proyectos activos
- [ ] Tarifa/availability coherente (no contradice el resto)

## X
- [ ] Bio ≤ límite oficial; anclas semánticas presentes sin stuffing
- [ ] Pinned: el post que querés que un visitante nuevo vea

## ResearchGate
- [ ] Publicaciones sincronizadas (DOI, ORCID resolubles)
- [ ] Bio y skills coherentes

## Substack
- [ ] Perfil: bio + secciones + featured coherentes
- [ ] Newsletter citable (RSS visible, sobre linkeada desde otros perfiles)
