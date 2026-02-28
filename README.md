# community-where 
<img src="https://img.shields.io/static/v1?label=status&message=in+progress+non-production&color=dd9900">

Community-where is an open-source Rails app that lets people map useful resources in their neighborhoods —  
things like:

- ♻️ eco trash bins (oil, lamps, glass, paper…)
- 🔌 electric car chargers
- 🗺️ any other public “useful spot”

Users can place markers on the map, and the community can **validate** them  
(“validated by X people”) so information stays trustworthy.

---

## Tech stack

- **Ruby**: 3.3.3
- **Rails**
- **PostgreSQL**
- **Hotwire (Turbo + Stimulus)**
- **Leaflet** for maps
- **Yarn + esbuild + Sass**
- **Docker (production image)**
- Procfile 

---

## Requirements

Make sure you have:

- Ruby **3.3.3**
- PostgreSQL
- Node.js + Yarn
- Bundler

Check versions:

```bash
ruby -v
bundle -v
psql --version
node -v
yarn -v
```

> 💡 If Ruby isn’t 3.3.3, use rbenv, asdf, or chruby to install it.

---

## Clone & install dependencies

```bash
git clone https://github.com/your-username/community-where.git
cd community-where
bundle install
yarn install
```

---

## Configure credentials

Rails uses encrypted credentials.  
You should **NOT commit** `config/master.key`.

If it exists, ask the maintainer for it — or generate your own for local dev:

```bash
EDITOR="code --wait" bin/rails credentials:edit
```

This will create:

- `config/credentials.yml.enc`
- `config/master.key`

Keep `master.key` private.

---

## Create and migrate the database

```bash
bin/rails db:create db:migrate
```

### Geographical Data Import 

Only data from Portugal was retrieved.  
Source: https://gadm.org/download_country.html.

The project uses the LEVEL 3 GeoJSON file as the base source, for the most granularity of administrative units.

Three scripts are used to populate and maintain the geographic data:

1. **Import script**  
This script reads the LEVEL 3 GeoJSON file, creates the base records in the places table, and builds the hierarchical relationships between administrative levels.

```bash
rails runner script/import_places.rb
```

2. **Parent relations mapping**  
This script recalculates and assigns representative coordinates to parent records (e.g., municipalities and districts) based on their children.

```bash
rails runner script/update_parent_coordinates.rb
```

3. **Normalize names**  
Some names come with "de"/"da"/"dos" in the middle and sticked with the whole name, lacking of blank spaces

```bash
rails runner script/normalize_places_names.rb
```

---

## Running the app (development)

### Option A — run each process manually

**Rails**

```bash
bin/rails server
```

**JS build watcher**

```bash
yarn build --watch
```

**CSS watcher**

```bash
yarn build:css:watch
```

Open:

```
http://localhost:3000
```

---

### Option B — using Procfile (Foreman)

If you have `foreman`:

```bash
gem install foreman
foreman start
```

This runs:

```
web: env RUBY_DEBUG_OPEN=true bin/rails server
js: yarn build --watch
css: yarn build:css:watch
```

---

## Front-end build details

`package.json` contains:

- esbuild for JS
- Sass for CSS
- Leaflet
- Hotwire (Turbo + Stimulus)

Main scripts:

```bash
yarn build
yarn build:css
yarn build:css:watch
```

Stimulus is used especially for the **map controller**.

---

## Docker (production-style build)

> ⚠️ This Dockerfile is meant for production, not local dev.

Build:

```bash
docker build -t community_where .
```

Run:

```bash
docker run -d -p 80:80 \
  -e RAILS_MASTER_KEY=<your master key> \
  --name community_where community_where
```

---

## Development guidelines

- Keep secrets out of git
- Prefer small PRs
- Add seeds when useful

---

## Troubleshooting

**Assets not compiling?**

```bash
yarn install
yarn build
```

**Rails can’t boot?**

Check:

```bash
echo $RAILS_MASTER_KEY
```

or ensure `config/master.key` exists.

**DB errors**

```bash
bin/rails db:drop db:create db:migrate
```

---

## License

MIT — open for everyone ✨
