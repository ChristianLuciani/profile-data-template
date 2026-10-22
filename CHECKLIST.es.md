# CHECKLIST — verificación por plataforma post-deploy

[English](CHECKLIST.md)

> **Estado de este archivo (D18, SPEC §19 del engine):** el estado por entrada de deploy
> vive en `content/deployments.yaml` — reportalo con `pasco status`. Cuando empieces a
> confirmar pegadas con `pasco status --mark <ledgerKey> <surface>`, el ledger pasa a ser
> la fuente de verdad: `pasco status --write-checklist` **sobrescribe** este archivo con
> su vista AUTO-GENERADA (en inglés). Desde ese punto, no lo edites a mano. Hasta
> entonces, las listas de abajo son tu verificación manual post-pega.
>
> **Nota de traducción:** este archivo es la traducción mantenida a mano del checklist
> manual. El engine **solo regenera `CHECKLIST.md`**, y la vista generada no es el
> checklist manual — este español no puede espejarla: re-sincronizalo a mano o retiralo
> cuando corras `--write-checklist`.

Después de pegar/actualizar una plataforma, verificá y marcá. La consistencia factual
entre redes ES tu citabilidad (GEO): si un LLM cruza dos perfiles y encuentra
contradicciones, te descarta.

## Antes de publicar tu fork — privacidad del repo

Esto no es post-pega: es el gate de privacidad del **workspace**. En el template
(`profile-data-template`) se cumple por diseño; en tu copia es tuyo.

- [ ] **El repo es privado desde antes de cargar datos.** Si lo creaste público,
      cambialo a privado *y* asumí que lo publicado ya pudo indexarse.
- [ ] **`git status` no muestra `.pasco/`, `.env*` ni `media/` con bytes** — el
      estado local y los binarios van gitignoreados, no commiteados.
- [ ] **Ningún link crudo a un archivo de un repo privado** en `profiles/`
      (`raw.githubusercontent.com/...`): el asset viaja por `assets/`, nunca por URL.
- [ ] **Secret scanning + push protection activos** (Settings → Code security).
      Un token pegado una vez queda en la historia aunque lo borres después.
- [ ] **Los datos de otra persona no están acá.** `content/identity.yaml` describe
      a quien publica, no a un cliente o exempleador sin permiso.
- [ ] **`LICENSE` lleva tu copyright**, no el del template.
- [ ] Si trabajás en **este** template: `bash .github/scripts/check-example-data.sh`
      (en tu fork el job de CI se saltea y el script falla a propósito, porque tu
      identidad deja de ser el ejemplo).

## Evidencia (D17, SPEC §18) — antes de cualquier deploy

Esto **no** es post-pega: es el gate previo. Las reglas las ejecuta `pasco check`
(M7/§18.8 y M8/§18.6 están implementadas; requiere CLI ≥ 0.3.0). Los nombres entre
paréntesis son el código que el CLI emite en el finding.

`validate` + `check` también corren automáticamente en cada PR
(`.github/workflows/checks.yml`, job `evidence`) — pero el job solo cubre lo que el
engine sabe verificar. Los ítems manuales de abajo siguen siendo tuyos.

- [ ] **`pasco check` sale limpio o con warns entendidos** — un error bloquea el deploy.
- [ ] **`credential-expiry`** (`check/credential-expired`) — ninguna credencial con
      `expires` en el pasado. El check avisa nombrando credencial e índice; renová el
      dato o actualizá `expires`. Renová una vez al año, no cuando alguien te lo señala.
- [ ] **`private-in-public-output`** (`check/private-in-public-output`) — nada
      `unlisted` **ni** `private` referenciado desde material público. Solo `public`
      cuenta como público: `unlisted` falla igual que `private`. Si salta, poné la
      entrada en `public` o quitá la referencia.
      *Este check FALLA el build (exit 1) — es un error, no un aviso.*
- [ ] **`dangling-cross-ref`** (lo reporta `pasco validate`) — todo `credentialId` /
      `artifactId` / `artifactRefs` apunta a un `id` que **existe** en su bloque. Un id
      inexistente falla el load (exit 1), no se ignora.
- [ ] **`verifyUrl` resuelve** — abrí cada `verifyUrl` de credenciales `public`: es el link
      que un escéptico va a clickear. Un 404 deshace más de lo que suma la credencial.
- [ ] **`media-missing-workspace`** (error) — todo `path: media/…` existe en el repo. El
      workspace es la SSOT: si falta el archivo, es error y el asset no se bundlea.
- [ ] **`media-path-unsafe`** (error) — ningún locator resuelve **fuera** de su base
      (workspace o evidence root). Un `media/../../..` es error de contención, no un path válido.
- [ ] **`media-not-a-file`** (error) — todo locator apunta a un **archivo**, no a un
      directorio. `media/photos/` como locator falla.
- [ ] **`media-oversize`** (warn) — ningún archivo > 50 MB versionado (GitHub bloquea en
      100 MB). Para archivos grandes: git-lfs o `url` locator.
- [ ] **`media-checksum-mismatch`** (error) — los checksums declarados coinciden con los
      bytes. Aplica a artifacts inmutables (datasets, documentos): si el archivo cambió,
      la promesa se rompió. Para media mutable, omití `checksum`.
- [ ] **`media-symlink-external`** (warn) — si aparece, el render depende de tu máquina.
      Declarar `checksum` o migrar a `PASCO_EVIDENCE_ROOT`
      (ver `docs/power-user-symlinks.md`).
- [ ] **`media-external-missing`** (warn) — esperado y benigno en CI: un runner sin
      `PASCO_EVIDENCE_ROOT` saltea los assets externos y renderiza sin ellos. Si lo ves
      **en tu máquina**, revisá que la env var esté seteada en esa shell.
- [ ] **`media-unbundled-no-id`** (warn) — un `path` locator sin `id` no puede recibir un
      target estable (`assets/<id>/…`). Poné `id` si querés que la media se bundlee.
- [ ] **`.gitkeep` limpiado** — al agregar el primer archivo real a un subdirectorio de
      `media/`, borrá su `.gitkeep` (existe solo para que git versione el directorio vacío).

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
