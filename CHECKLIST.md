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

## Evidencia (D17, SPEC §18) — antes de cualquier deploy

Esto **no** es post-pega: es el gate previo. Las reglas las ejecuta `pasco check`
(M7/§18.8 y M8/§18.6 están implementadas; requiere CLI ≥ 0.3.0). Los nombres entre
paréntesis son el código que el CLI emite en el finding.

- [ ] **`pasco check` sale limpio o con warns entendidos** — un error bloquea el deploy.
- [ ] **`credential-expiry`** (`check/credential-expired`) — ninguna credencial con
      `expires` en el pasado. El check avisa nombrando credencial e índice; renová el
      dato o actualizá `expires`. Renová una vez al año, no cuando alguien te lo señala.
- [ ] **`no-private-in-public-output`** (`check/private-in-public-output`) — nada
      `private` referenciado desde material público. Si salta, es una fuga: corregí la
      `visibility` o quitá la referencia.
      *Este check FALLA el build (exit 1) — es un error, no un aviso.*
- [ ] **`verifyUrl` resuelve** — abrí cada `verifyUrl` de credenciales `public`: es el link
      que un escéptico va a clickear. Un 404 deshace más de lo que suma la credencial.
- [ ] **`media-missing-workspace`** — todo `path: media/…` existe en el repo. El workspace
      es la SSOT: si falta el archivo, es error y el asset no se bundlea.
- [ ] **`media-oversize`** — ningún archivo > 50 MB versionado (GitHub bloquea en 100 MB).
      Para archivos grandes: git-lfs o `url` locator.
- [ ] **`media-symlink-external`** — si aparece, el render depende de tu máquina. Declarar
      `checksum` o migrar a `PASCO_EVIDENCE_ROOT` (ver `docs/power-user-symlinks.md`).
- [ ] **Checksums declarados coinciden** — `media-checksum-mismatch` es error. Aplica a
      artifacts inmutables (datasets, documentos): si el archivo cambió, la promesa se rompió.

### Verificación de media bundleada (solo con `path` locators)

- [ ] **`pasco build <platform>` bundleó assets/** — `profiles/<platform>/assets/` existe y
      `assets/manifest.json` registra id, target, sha256 y bytes por asset.
- [ ] **Los links `assets/…` resuelven en la superficie pública** — deploy-relative: solo
      funcionan **después** de que `assets/` se commiteó al repo de deploy. Un
      `assets/…` que no resuelve = el commit no incluyó los binarios.
- [ ] **Ningún archivo de `media/` se pegó como URL cruda** — ni `raw.githubusercontent.com`
      de un repo privado, ni un path absoluto local. Para el mundo son 404.

## GitHub (profile README)
- [ ] README actualizado vía git/API (commit en profiles/github-readme)
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
