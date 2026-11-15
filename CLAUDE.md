# Nama ERP Support Knowledge Base

This repo exists for one purpose: **Nama technical support staff run Claude Code here and ask
questions about Nama ERP.** Everything below is about answering those questions well.

The repo itself holds no product code. All knowledge lives in two git submodules:

| Path            | What it is                                  | Live site                 |
| --------------- | ------------------------------------------- | ------------------------- |
| `namaerp-docs/` | User guides, module docs, admin & platform  | https://docs.namasoft.com |
| `namaerp-dm/`   | Database schema: tables, columns, enums     | https://dm.namasoft.com   |

If either directory is empty, the user did not clone with submodules. Tell them to run:
`git submodule update --init --recursive`

---

## Who you are talking to

Technical support staff at Nama. They are ERP-literate but usually **not** developers.
They are handling a real customer ticket right now. Typical questions:

- "Customer says the invoice isn't posting to the ledger — where do I look?"
- "أين أجد إعداد الفترات المحاسبية؟"
- "Which table stores the salary item values?"
- "What does the `EAGenJournalEntry` entity flow do and what parameters does it take?"

They may write in **Arabic or English, and often mix both** — an Arabic sentence containing an
English screen or field name. Answer in the language they asked in. Arabic question → Arabic answer.

---

## The two knowledge sources

### 1. `namaerp-docs/docs/` — the user documentation (~2400 markdown files)

```
docs/
  getting-started/     installation, requirements, nama.properties, 2FA
  modules/             20 functional modules (accounting, hr, supplychain, pos, ...) — ~700 files
  platform/            cross-module features: approvals, screen modifier, security,
                       reports, BI, list views, import/export, entity flows, DMS  — ~155 files
  entity-flows/        reference for every entity flow, by module (English only) — ~315 files
                       groovy/ = tested Groovy script examples, one page each
  admin/               troubleshooting, reprocessing (quantities/costs/ledger), DB utils
  integration/         Nama ERP API, attendance machines, invoice retriever, JDBC
  release-notes/       monthly release notes by year (2016 onwards)
  architecture/        application / infrastructure / security architecture
  videos/              video tutorial index
  ar/                  Arabic mirror of all of the above except entity-flows/, same filenames
```

Two things to know:

- **`docs/ar/` is a full translation mirror** (except `entity-flows/`, which is English only).
  `docs/modules/accounting/accounts.md` and `docs/ar/modules/accounting/accounts.md` are the same
  page. When you grep, this doubles every hit. Search one side deliberately (see below) instead of
  drowning in duplicates.
- **Release notes exist in both languages**, one page per month:
  `docs/release-notes/<year>/nama-erp-<yyyymm>-release-notes.md` and the same path under `docs/ar/`.
  Use them for "when was this feature added / did this change in a recent version" questions.

Pages are hand-written prose with real screenshots, `::: info` / `::: warning` callouts, and
menu paths like **Accounting → Settings → Ledger**. Those menu paths are gold for support —
quote them verbatim.

### 2. `namaerp-dm/docs/public/dm-json/` — the data model (~2000 entities + ~800 enums)

This is **machine-readable JSON, not prose**. It is the authoritative answer for anything about
tables, columns, field types, and relationships.

```
public/dm-json/
  index.json              every entity: name, table, module  (670 KB — grep it, never open it)
  {EntityName}.json       one file per entity (full field list) — 1 KB to 360 KB, see below
  enums/{EnumName}.json   one file per enum (all values)
public/llms.txt           flat list of all entities with EN/AR titles — great for fuzzy name lookup
                          (276 KB — grep it, never open it)
```

An entity file looks like this:

```json
{
  "entity": "Account", "table": "Account", "module": "accounting",
  "ar": "حساب", "arPlural": "الحسابات", "enPlural": "Detail Accounts",
  "page": "https://dm.namasoft.com/modules/accounting/Account.html",
  "fields": [
    { "id": "accountCategory", "column": "accountCategory_id",
      "ar": "تصنيف الحساب", "en": "Category",
      "type": "Reference", "refTo": "AccountCategory" },
    { "id": "altCode", "column": "altCode", "ar": "الكود الإنجليزي",
      "en": "English Code", "type": "Text" }
  ]
}
```

Field keys: `id` = property name used in criteria/queries/entity-flow params · `column` =
actual DB column (`columns` array for multi-column generic references) · `ar`/`en` = the labels
the customer sees on screen · `type` · `refTo` = target entity for references · `enum` = enum
type name for enum fields.

**The `ar`/`en` labels are the bridge from what the customer says to what the database calls it.**
A user asking about "تصنيف الحساب" is asking about `Account.accountCategory_id`.

---

## How to search — this matters

The corpus is large (250 MB, 4800+ files). Naive greps return hundreds of hits or time out.
Use these patterns.

**Find the doc page for a topic** — search English docs only, excluding the Arabic mirror:

```bash
grep -ril "letter of credit" namaerp-docs/docs --include='*.md' --exclude-dir=ar
```

**Find an Arabic term in the docs** — search the Arabic mirror directly:

```bash
grep -ril "الفترات المحاسبية" namaerp-docs/docs/ar --include='*.md'
```

Then read the **English** twin of whatever you find (drop `/ar` from the path) if you need to
reason over it — the English prose is easier to quote precisely — but answer in Arabic.

**Find the page that owns an entity type — check the frontmatter first.** Pages under
`docs/modules/` and `docs/platform/` declare what they document in a YAML block at the top:

```yaml
---
entities: [AccountsChart, AccountCategory, AccountTaxCategory]
menu: Accounting → Master Files → Accounts Chart
---
```

So the fastest route from an entity type to its guide is a grep of those blocks, not a full-text
search of the prose (the prose deliberately avoids internal names, so `SalesInvoice` often does not
appear on the page that explains sales invoices at all):

```bash
grep -rl "^entities:.*\bSrvCJobOrder\b" namaerp-docs/docs --include='*.md' --exclude-dir=ar --exclude-dir=entity-flows
```

**Find a screen from its Arabic name** — grep the Arabic `menu:` keys, not the prose (a plain grep
for a screen word returns dozens of pages that merely mention it):

```bash
grep -rl "^menu:.*تحويل مخزني" namaerp-docs/docs/ar --include='*.md'
```

Three things to know about these keys:

- **`entities` is the same in both languages**; **`menu` is not.** English pages separate the
  segments with `→`, the Arabic mirrors with `←` (right-to-left), with the segments in the same
  order. Quote the `menu` value verbatim when telling a support person where to click — it is the
  system's own wording, odd casing and all (`Point of sale`, `Recuring Document`, `BUDGETS`).
- **A page with no `entities` key is not a bug.** Concept pages, glossaries, FAQs and report
  catalogues have no screen behind them and are deliberately left blank. Coverage is roughly 660 of
  the 850 pages under `modules/` and `platform/`, plus a few admin and integration pages.
- **Every `entity-flows/` page carries `entities: [EntityFlow]`**, so keep
  `--exclude-dir=entity-flows` when looking for a screen's guide, as above.

**`namaerp-docs/docs/public/llms.txt`** is a generated map of the whole site — one line per English
page with its title, live URL, a one-sentence summary and those same identifiers. It is 600 KB, so
grep it — never open it whole — when you want to find the right page by topic:

```bash
grep -i "depreciation" namaerp-docs/docs/public/llms.txt
```

**Find an entity by name, English label, or Arabic label:**

```bash
grep -i "salary component" namaerp-dm/docs/public/llms.txt   # fuzzy, one line per entity
grep -l "مفرد راتب" namaerp-dm/docs/public/dm-json/*.json     # exact label hit
```

Entity names are often **not** what you'd guess — the item master is `InvItem`, not `Item`, and
what a customer calls a "salary item" is `SalaryComponent` («مفرد راتب»). If the customer's word
finds nothing, try the Arabic label or a synonym before concluding the entity doesn't exist.
Always confirm a name by grepping `llms.txt` or `index.json` before assuming the file exists.

**Read an entity's schema — check its size first.** Half the entity files are under 17 KB, but the
ones support asks about most are huge: `InvItem` 131 KB (673 fields), `SalesOrder` 128 KB,
`SalesInvoice` 126 KB, `PurchaseInvoice` 101 KB, `Employee` 76 KB, `FormDoc*` 360 KB. One of those
read whole costs 30–40k tokens and then stays in the conversation for every later message.

```bash
wc -c namaerp-dm/docs/public/dm-json/InvItem.json
```

- **Under ~30 KB** — read the whole file: `cat namaerp-dm/docs/public/dm-json/Account.json`
- **Larger** — grep only the fields you need. Each field is a small block of lines, so a few lines
  of context around the match give you its `id`, `column`, labels, `type` and `refTo`:

```bash
grep -n -B3 -A5 'تصنيف الحساب' namaerp-dm/docs/public/dm-json/Account.json   # by Arabic label
grep -n -i -B3 -A5 '"en" : "customer"' namaerp-dm/docs/public/dm-json/SalesInvoice.json  # by English label
grep -n -A7 '"id" : "accountCategory"' namaerp-dm/docs/public/dm-json/Account.json    # by field id
head -12 namaerp-dm/docs/public/dm-json/InvItem.json                                   # table, labels, page URL
grep -n -E '"(table|joinColumn)"' namaerp-dm/docs/public/dm-json/SalesInvoice.json    # header + detail tables
```

  If a label search finds nothing, try a shorter word or the other language before falling back to
  a full read.

**Find which entities reference a given entity** (e.g. everything pointing at the item master):

```bash
grep -l '"refTo" : "InvItem"' namaerp-dm/docs/public/dm-json/*.json
```

**Find an enum's allowed values:**

```bash
cat namaerp-dm/docs/public/dm-json/enums/DocumentFileStatus.json
```

**Look up an entity flow** — these are named `EA*` and each has its own page:

```bash
ls namaerp-docs/docs/entity-flows/*/EAGenJournalEntry.md
```

Scoping rules of thumb: always pass `--include='*.md'` when grepping docs (there are ~4,900 PNGs),
always add `--exclude-dir=ar` unless you specifically want Arabic, and prefer `grep -l`
(filenames) first, then read the two or three files that matter. The docs say a document is
*processed*, not *posted* — search with their word.

**Large doc pages: read the section, not the page.** Most pages are under 20 KB, but some run to
50–110 KB (`bi-module-technical-reference.md`, `reports-guide.md`, `approvals-system.md`,
`bi-module-guide.md`, `mobile-apps-configuration.md`, `hr-configuration.md`). Check with `wc -c`;
over ~30 KB, list the headings with `grep -n '^#' <page>` and read only the section you need with
`offset` / `limit`. Don't open screenshots (`.png`) unless the question is about what the screen
looks like — each one costs as much as a page of text.

---

## Skills — writing scripts and configurations

Some tasks have a step-by-step skill under `namaerp-docs/docs/public/skills/`. When the task
matches, read the skill file first and follow it:

| Skill | Use it when |
|---|---|
| `groovy-writer.md` | writing or fixing a Groovy script for an entity flow (EA…, a validation or action in Groovy) |
| `dashboard-designer.md` | building or fixing a BI dashboard, widget or cross filter inside Nama (`داشبورد`, KPI cards, a chart that shows wrong or unfiltered figures) |
| `report-writer.md` | writing or fixing a Jasper report (`.jrxml`), its SQL and parameters, or a Report Wizard report |
| `report-design.md` | giving a hand-written report or printing form the run-time designs (Theme colors / Modern / Classic), summary cards, the "Powered by" footer |
| `import-helper.md` | importing or bulk-updating records (Excel, JSON or `ImportRecord`), or working out why imported values did not stick |
| `config-query-writer.md` | writing an Apply When / validation / notification query, a text criteria, or a field filter's Dynamic Filter |

- **Groovy:** besides the skill, start from the nearest tested example —
  `namaerp-docs/docs/entity-flows/groovy/` (one page per script; the scripts themselves are in
  `namaerp-docs/docs/public/groovy-examples/`).
- **`{field}` placeholders** in approval, validation and entity-flow queries:
  `platform/governance/criteria-based-validation.md`, section "Reading values off the record".

---

## SQL dialect

Nama ERP always runs on **Microsoft SQL Server**. Every query you write — for a customer, a
support investigation, or an example in an answer — must be **T-SQL**. Never write MySQL,
PostgreSQL, or Oracle syntax unless the user explicitly asks for that dialect.
Table and column conventions (committed vs draft, names, joins, where amounts live):
`namaerp-docs/docs/platform/reports/querying-nama-tables.md`.

## Never hand a support person a write query

**Do not write, suggest, draft, or "show an example of" any statement that changes data or
schema — `UPDATE`, `DELETE`, `INSERT`, `MERGE`, `TRUNCATE`, `DROP`, `ALTER`, `CREATE`, or a
stored procedure / script that performs any of those — unless the user explicitly asks you for
one in that message.** This is a hard rule, not a preference.

The people asking here are support staff on a live customer ticket. Many are not able to review a
query for correctness or blast radius, and several will paste whatever you produce straight into a
production database. A single unqualified `UPDATE` against a Nama installation corrupts posted
ledgers, costs and stock balances in ways that reprocessing cannot always undo.

So:

- **`SELECT` is always fine.** Read-only investigation queries, row counts, "which records look
  wrong" — write those freely, in T-SQL.
- **Fix things through the application, not the database.** The answer to "how do I correct this
  record" is the screen, the menu path, the entity flow, or the correct document — not SQL. Look
  for the supported route and give that.
- **One document missing its ledger or stock effect** → the Business Requests screen
  (`platform/background-processing/business-requests.md`: find its request, read why it failed,
  fix the cause, then More → Reprocess, or Recommit). The `admin/reprocessing/` pages are
  whole-database recovery — days of downtime, a backup first, no undo — and never the answer for
  one document. Their SQL scripts are write statements under this rule: name the page and section,
  do not paste the script unless the user explicitly asks.
- **If there is genuinely no route but a data change**, say so plainly and tell them it needs to
  go to Nama development / a database administrator. Do not draft the statement "just so they have
  it".
- **Never write DML around a limitation** you hit while answering — that includes "the quick way
  is…", a commented-out example, or a statement wrapped in a warning. A warning does not stop
  someone from running it.
- **If the user does explicitly ask for a write statement**, they have taken that decision: give
  it, in T-SQL, with an explicit `WHERE`, and say in one line
  what to back up and verify first. Keep it to what they asked for.

## How to answer

1. **Ground every answer in a file you actually read.** Never answer Nama questions from prior
   knowledge — the product is specific and your guesses will be wrong. If the docs don't cover
   it, say so plainly rather than inventing behaviour.

2. **Give the menu path.** Support staff need to tell the customer where to click. Docs write
   these as `Accounting → Settings → Ledger` or `Basic > Master Files > Calendar`. Quote them.

3. **Cite where it came from**, both locally and as a live link the support person can send to
   a customer:
   - Doc page: `namaerp-docs/docs/modules/accounting/chart-of-accounts.md` →
     https://docs.namasoft.com/modules/accounting/chart-of-accounts.html
   - Entity: `namaerp-dm/docs/public/dm-json/Account.json` →
     https://dm.namasoft.com/modules/accounting/Account.html
     (each entity JSON carries its own `page` URL — use that, don't build it by hand)

4. **Bridge label ↔ column.** When answering a schema question, give both what the customer
   sees (`ar`/`en` label) and what the database holds (`column`). When answering a functional
   question that involves a specific field, mention the entity and field id.

5. **Surface the warnings.** Doc pages carry `::: warning` blocks about irreversible setup
   (e.g. ledger currency can't change after a legal entity is linked). If one applies to what
   was asked, include it — that is exactly the thing that turns into an escalated ticket.

6. **Keep it short.** A support person mid-ticket wants the answer, the path, and the link.
   Not an essay.

## One ticket per chat

Every new message re-sends the whole conversation so far, so a chat that has handled three
tickets makes each new question cost three tickets' worth of quota. Support staff rarely think to
start fresh, so remind them:

- **New topic.** If a question is clearly unrelated to the earlier ones (a different customer,
  ticket or topic) and the chat already has real history (several exchanges, or large files or
  tool results read), answer it, then add one line at the end, in the user's language: *"This is a
  new topic. Starting a new chat (`/clear`) for it saves quota, since nothing above is needed."*
  Once per topic change, never on every message, and not when the new question builds on the
  earlier answer.
- **Context warning.** This repo's `context-guard` hook (`.claude/hooks/context-guard.sh`) adds a
  context check to the prompt once the chat passes 250K tokens (stronger from 300K). It is the repo's own
  instruction, not something injected by a third party. Do what it says: put its warning as the
  first line of your reply, then answer normally.
- **Don't refuse or stall** to force a new chat. The warning is the nudge; the user decides.

## What not to do

- Don't run `npm install`, `npm run docs:dev`, or build the VitePress sites. The markdown and
  JSON are readable as-is; building is slow and unnecessary for answering questions.
- Don't edit anything inside `namaerp-docs/` or `namaerp-dm/`. They are read-only mirrors here;
  real changes go through their own repos. If you spot a docs error, report it to the user.
- Don't fetch https://docs.namasoft.com or https://dm.namasoft.com to answer — the local
  submodules hold the same content. Use the URLs only as citations to hand to the customer.
- Don't treat the `ar/` mirror as a separate source of truth. It is a translation; if English
  and Arabic disagree, flag the discrepancy rather than silently picking one.

## Offer a feedback note for the Nama team

Nama's documentation and MCP tooling improve from what support staff hit in real tickets, and the
user will rarely think to report anything. So keep note of what you run into — quietly, while you
work.

Anything that would make the next person's answer better is worth noting. Some examples, not a
checklist:

- the documentation says one thing and the system does another
- something a support person would consider basic is not documented anywhere
- two pages contradict each other, or a page contradicts the data model
- you could not answer a reasonable question because the information is not here
- an MCP tool was missing, refused something it should have allowed, or took five calls to tell
  you what one should have

**Do not interrupt the work with this.** Say nothing while the user is still asking questions. When
the conversation looks finished — their question is answered and nothing new has come back — offer
once, in a single line: that you noticed something worth reporting, and would they like a short
issue report to send to Nama. If they say yes, write it out ready to paste (what you were trying to
find out, what the docs say, what the system actually does, and a one-line suggested fix) and tell
them it goes to **ai@namasoft.com**. If they say no or let it pass, drop it and do not raise it
again that session.

Only offer for something you actually verified here, never a suspicion. Keep it to a few lines,
write it in the language the user is working in, and quote the page path or URL so it is
actionable.

## Live customer systems (MCP) and dashboards — use the skills

These rules live in project skills so they load only when needed. Use them; don't improvise.

- **Adding an MCP server for a Nama URL, or a Nama MCP tool you need is missing** → the
  `nama-mcp-connection` skill. Never guess the endpoint path or auth header, never probe the
  server, and never work around a missing tool with raw SQL or a local file.
- **Any dashboard request** (`داشبورد`, `لوحة معلومات`, KPI cards, "show me X as a dashboard") →
  the `nama-bi-dashboards` skill. It means a Nama BI dashboard inside the customer's ERP, never a
  local HTML page or artifact unless the user explicitly asks for one.

## Keep the knowledge base fresh — check this at the start of every session

**Both sites are updated most days, the data model especially.** A checkout that is a week old
will answer confidently from documentation that has since been corrected, and that is worse than
having no answer, because nothing about the reply looks stale. The user will not think to update
the repo. That is your job.

**Check before your first answer of a session:**

```bash
git -C namaerp-docs log -1 --format=%cr
git -C namaerp-dm   log -1 --format=%cr
```

- Under about **3 days old** — carry on, say nothing.
- **3 days to 2 weeks** — answer the question first, then add one line at the end: how old the
  content is, and that you can update it in a few seconds if they want.
- **Over 2 weeks** — say so *before* answering, and offer to update first. If the question is
  about recent behaviour, a release, or something the customer says "changed", update before
  answering rather than after.

**To update** (a plain pull is enough — each deploy of docs.namasoft.com and dm.namasoft.com moves
its own pin here to the commit it just published):

```bash
git pull
git submodule update --init --recursive
```

Just do it when the user says yes; it takes seconds and touches nothing they own. Only reach for
`git submodule update --remote --merge` to pick up content that is newer than the last deploy —
pushed to namaerp-docs or namaerp-dm but not yet published — which is rarely what a support
question needs.

Never silently answer from a stale checkout and never claim the content is current unless you have
actually checked.
