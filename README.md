# user-brand-data

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

1. **Fork** (recomendado, te queda conectado upstream) o **Use this template** en GitHub.
   Hacelo **privado** — tus datos no son públicos (salvo que quieras).
2. Cloná y entrá:

   ```bash
   git clone git@github.com:<tu-usuario>/user-brand-data.git
   cd user-brand-data
   ```

3. Instalá el CLI del engine (M1): `pnpm --filter @profile-as-code/cli build` en el monorepo
   `profile-as-code` (o `npm i -g profile-as-code` cuando se publique).

4. Editá `content/` — reemplazá el ejemplo ficticio con tus datos (contrato:
   `schema/profile.schema.json`; cada archivo ES una root property — `bios.yaml` es el
   array `bios[]` directamente, sin key wrapper):
   - `identity.yaml` — nombre, ubicación, links canónicos (TU source of truth de URLs)
   - `positioning.yaml` — tu enunciado de posicionamiento + ángulos por audiencia + anclas GEO
   - `bios.yaml`, `headlines.yaml` — por plataforma/idioma/longitud
   - `skills.yaml`, `experience.yaml`, `projects.yaml`, `publications.yaml`, `keywords.yaml`

5. Construí y validá:

   ```bash
   pac validate          # schema (fail) + drift/geo (warn) — D12
   pac build             # base texts deterministas por plataforma (sin arg = todas)
   pac diff              # cambios desde el último release (→ CHANGELOG)
   pac refine linkedin   # variantes IA (stub en M1, M3/M4) — agente propone, vos elegís
   pac check             # checks declarativos (stub en M1, M4)
   ```

6. **Deploy:** pegá lo generado en cada plataforma (ver `CHECKLIST.md`) o dejá que git/API
   actualice GitHub README y web. Marcá cada plataforma en `CHECKLIST.md` cuando la verifiques.
7. **Versioná:** cada cambio entra con `CHANGELOG.md` actualizado → sabés qué re-pegar y dónde.

## Estructura

```
user-brand-data/
├── content/             # ← TU información (YAML)
├── profiles/            # outputs generados (se commitean: son los artefactos de deploy)
├── CHANGELOG.md         # cada cambio: fecha + qué plataformas re-pegar
├── CHECKLIST.md         # verificación por plataforma post-pega
└── .pacrc               # configuración del CLI (workspace path, defaults)
```

## Reglas

- Los datos de ejemplo en `content/` son una **persona ficticia** (Alex Rivera) — documentan el schema.
- `profiles/` se regenera con `pac build`; no lo edites a mano (se pisa).
- El engine es de solo lectura sobre este repo, salvo `pac refine` (escribe la variante elegida).
- Multi-identidad: si mañana manejás una **identidad comercial/marca**, creá otro workspace
  (mismo engine) — uno por identidad.

## Enlaces

- Engine: https://github.com/ChristianLuciani/profile-as-code
- Spec del engine: `docs/SPEC.md` allí (§9 = este template)
- Prior-art: `docs/research/01-prior-art.md`
