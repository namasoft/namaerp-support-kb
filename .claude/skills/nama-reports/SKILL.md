---
name: nama-reports
description: Write, fix or restyle a Nama ERP report or printing form — Jasper .jrxml, Report Wizard, Virtual Entity reports, report SQL and parameters, "this report shows the wrong figures", or giving an old/custom report the new designs (Theme colors, Modern, Classic, summary cards, Powered-by footer). Routes to the full report skills in namaerp-docs.
---

# Nama reports

The full instructions live in the docs submodule. Read the one that matches and follow it:

| Task | Read |
|---|---|
| New report, change a report's query or layout, wrong figures, choosing Report Wizard vs Virtual Entity vs hand-written `.jrxml`, delivering through a Report Definition or the report MCP tools | `namaerp-docs/docs/public/skills/report-writer.md` |
| Give a hand-written report or printing form the run-time designs (Theme colors / Modern / Classic), summary cards, the "Powered by" footer, the Report Design question | `namaerp-docs/docs/public/skills/report-design.md` |

Wizard and Printing Form Wizard reports get the designs automatically, so `report-design.md` is only for
hand-written `.jrxml` files. A task that needs both (a new hand-written report in the new look) reads
`report-writer.md` first, then `report-design.md`.

Keep context small while you work:

- **Large pages:** `platform/reports/reports-guide.md` is 75 KB. List its headings
  (`grep -n '^#'`) and read only the section you need.
- **Table columns:** follow the entity-schema rule in CLAUDE.md. Grep the fields you need instead of reading a
  large entity file (`SalesInvoice.json` is 126 KB) whole.
- **Report MCP tools:** when running a report through `<prefix>RunReport` to check figures, narrow the
  parameters (one document, a short date range) so the result stays small. If the report tools
  (`AITReportReadTools` / `AITUpdateReportTools`) are missing, follow the `nama-mcp-connection` skill.
- **SQL is T-SQL**, and the write-query rule in CLAUDE.md applies.
