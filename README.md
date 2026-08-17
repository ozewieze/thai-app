# Thai-app

A premium online platform offering CEFR structured, interactive, and audio-based lessons designed specifically for English-speaking subscribers to learn Thai efficiently.

This is a [Next.js](https://nextjs.org) project bootstrapped with [`create-next-app`](https://nextjs.org/docs/app/api-reference/cli/create-next-app).

## Getting Started

First, run the development server:

```bash
npm run dev
# or
yarn dev
# or
pnpm dev
# or
bun dev
```

Open [http://localhost:3000](http://localhost:3000) with your browser to see the result.

You can start editing the page by modifying `app/page.tsx`. The page auto-updates as you edit the file.

This project uses [`next/font`](https://nextjs.org/docs/app/building-your-application/optimizing/fonts) to automatically optimize and load [Geist](https://vercel.com/font), a new font family for Vercel.

## Learn More

To learn more about Next.js, take a look at the following resources:

- [Next.js Documentation](https://nextjs.org/docs) - learn about Next.js features and API.
- [Learn Next.js](https://nextjs.org/learn) - an interactive Next.js tutorial.

You can check out [the Next.js GitHub repository](https://github.com/vercel/next.js) - your feedback and contributions are welcome!

## Deploy on Vercel

The easiest way to deploy your Next.js app is to use the [Vercel Platform](https://vercel.com/new?utm_medium=default-template&filter=next.js&utm_source=create-next-app&utm_campaign=create-next-app-readme) from the creators of Next.js.

Check out our [Next.js deployment documentation](https://nextjs.org/docs/app/building-your-application/deploying) for more details.

## Database Seed Workflow

This project uses CSV master files as the editable source of truth and generates SQL seed files from them for local Supabase resets. Seed execution happens after migrations, which keeps schema changes and data seeding clearly separated.

## Database Commands

Use these commands depending on whether you are working against the local Supabase stack or the remote project.

### Local

- `npx supabase migration up` - applies only new local migrations to the local database.
- `npx supabase db reset` - rebuilds the local database from scratch and runs all migrations plus seed files.
- `npx supabase status` - shows the local Supabase service status and database connection details.

### Remote

- `npx supabase db push` - pushes pending migrations to the linked remote Supabase project.
- `npx supabase db pull` - pulls the remote schema into local migration files.
- `npx supabase migration list` - compares local and remote migration history.

### Overview

The seed workflow was changed from `COPY`-based seeding to SQL-based seeding.

- `seed.sql` now only handles truncate/reset behavior.
- Actual seed data is stored in generated `.seed.sql` files.
- The generated seed files are loaded automatically during `supabase db reset`.

This setup currently supports three datasets:

- Vocabulary
- Grammar
- Pattern

### Source Files

The following CSV files are the editable master files:

- `vocabulary_master.csv`
- `grammar_master.csv`
- `pattern_master.csv`

These files should be treated as the canonical content source. The generated SQL files are runtime artifacts derived from them.

### Generated Seed Files

Each dataset has its own generator script and output file:

- `generate-vocabulary-seed.mjs` -> `vocabulary_master.seed.sql`
- `generate-grammar-seed.mjs` -> `grammar_master.seed.sql`
- `generate-pattern-seed.mjs` -> `pattern_master.seed.sql`

### Seed Strategy

The seeding strategy is intentionally split into two layers:

1. **Reset/truncate layer**
   - `seed.sql` only contains truncate/reset logic.

2. **Data seed layer**
   - Dataset-specific `.seed.sql` files contain the actual insert statements.
   - These files are generated from the CSV master files.

This makes the seed process easier to maintain and avoids relying on server-side `COPY` behavior during local resets.

### NPM Commands

The following scripts are available in `package.json`:

```bash
npm run seed:vocab
npm run seed:grammar
npm run seed:pattern
npm run db:reset
```

#### What they do

- `npm run seed:vocab` regenerates `vocabulary_master.seed.sql`
- `npm run seed:grammar` regenerates `grammar_master.seed.sql`
- `npm run seed:pattern` regenerates `pattern_master.seed.sql`
- `npm run db:reset` rebuilds the local Supabase database using migrations and all configured seed files

### Supabase Seed Configuration

`config.toml` is configured so that Supabase loads all seed SQL files during reset.

This means the local reset flow now includes:

- vocabulary seed SQL
- grammar seed SQL
- pattern seed SQL

Important notes:

- Seed files run **after** migrations.
- Seed files are executed in the order defined in `sql_paths`.
- Schema changes should stay in migrations, not in seed files.

### Migration Updates

Additional migrations were added to align database constraints with the data contained in the CSV master files.

#### CEFR expansion

- `20260422104500_expand_cefr_levels.sql`

This migration expands CEFR support beyond the initial limited set.

#### Grammar concept type expansion

- `20260424100000_expand_grammar_concept_types.sql`

This migration allows all `concept_type` values required by the grammar CSV.

#### Pattern type expansion

- `20260424103000_expand_pattern_types.sql`

This migration allows all pattern type values required by the pattern CSV.

### Validation

Extra validation was added to improve failure visibility during seed generation.

#### Grammar validation

`generate-grammar-seed.mjs` now fails early when it encounters invalid or unsupported `concept_type` values.

This helps catch data issues before running a full database reset.

### Recommended Workflow

Use the following workflow whenever you update seed data:

1. Edit one of the master CSV files:
   - `vocabulary_master.csv`
   - `grammar_master.csv`
   - `pattern_master.csv`

2. Regenerate the corresponding SQL seed file:

   ```bash
   npm run seed:vocab
   npm run seed:grammar
   npm run seed:pattern
   ```

3. Rebuild the local database:
   ```bash
   npm run db:reset
   ```

### End-to-End Status

The full reset flow has been tested successfully.

`npm run db:reset` now completes successfully with all three datasets:

- vocabulary
- grammar
- pattern

### File Responsibilities

| File                                              | Responsibility                                                   |
| ------------------------------------------------- | ---------------------------------------------------------------- |
| `vocabulary_master.csv`                           | Editable source data for vocabulary                              |
| `grammar_master.csv`                              | Editable source data for grammar                                 |
| `pattern_master.csv`                              | Editable source data for patterns                                |
| `generate-vocabulary-seed.mjs`                    | Generates vocabulary seed SQL from CSV                           |
| `generate-grammar-seed.mjs`                       | Generates grammar seed SQL from CSV and validates `concept_type` |
| `generate-pattern-seed.mjs`                       | Generates pattern seed SQL from CSV                              |
| `vocabulary_master.seed.sql`                      | Generated runtime seed file for vocabulary                       |
| `grammar_master.seed.sql`                         | Generated runtime seed file for grammar                          |
| `pattern_master.seed.sql`                         | Generated runtime seed file for patterns                         |
| `seed.sql`                                        | Truncate/reset seed layer only                                   |
| `config.toml`                                     | Declares which seed SQL files Supabase should run                |
| `package.json`                                    | Defines the seed and reset commands                              |
| `20260422104500_expand_cefr_levels.sql`           | Expands allowed CEFR values                                      |
| `20260424100000_expand_grammar_concept_types.sql` | Expands allowed grammar concept types                            |
| `20260424103000_expand_pattern_types.sql`         | Expands allowed pattern types                                    |

### Key Principle

Keep the responsibilities separated:

- **CSV files** = editable master data
- **Generated `.seed.sql` files** = runtime seed artifacts
- **Migrations** = schema and constraint changes

This keeps the workflow reproducible, easier to debug, and easier to maintain.
