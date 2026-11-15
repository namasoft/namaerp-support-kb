---
name: nama-mcp-connection
description: Connect Claude Code to a customer's Nama ERP over MCP (add an MCP server for a Nama URL, IP or domain), and handle a Nama MCP tool that is missing from the tool list (dashboard, report, import, term/config tools). Use before writing any .mcp.json entry for a Nama server, and whenever a task needs a Nama MCP tool you do not have.
---

# Connecting to a customer's ERP over MCP

If you are asked to "add an MCP server" for a URL that is a Nama installation —
`https://<customer>.namasoft.com`, a customer's own domain, an IP and port — **do not guess the
endpoint path or the auth header, and do not probe the server for one.** Nama's built-in MCP
server is documented: read `namaerp-docs/docs/modules/ai/ai-mcp-server.md` and follow it.

The short version, for `.mcp.json`:

```json
{
  "mcpServers": {
    "nama-erp": {
      "type": "http",
      "url": "https://<customer-server>/basic-services/mcp",
      "headers": { "X-API-Key": "<client-secret>" }
    }
  }
}
```

The path is `/basic-services/mcp` — not `/mcp`, `/erp/...`, `/api/...` or `/sse` — and the
transport is Streamable HTTP, not SSE (older versions exposed `/basic-services/mcp/sse`; that
endpoint is gone). The key is the **Client Secret** of an **API Credentials** record in the
customer's own system, so ask for it rather than inventing a placeholder. A 404 on the correct
URL usually means the AI module is not installed on that server, not that the path is wrong.

# When an MCP tool you need is missing — say so

The tools a Nama MCP server exposes are exactly the lines on its **AI Tool Definition** record
(`Artificial Intelligence → Master Files → AI Tool Definition`, documented in
`namaerp-docs/docs/modules/ai/ai-tool-definitions.md`). Administrators often add only some of them,
so a connected server can lack the very tool the job calls for — the dashboard tools
(`AITDashboardTools`) when building a dashboard, the report tools (`AITReportReadTools` /
`AITUpdateReportTools`) when reading or fixing a report, the import tools when saving a record,
the term and config tools when changing document configuration, and so on.

**Do not quietly work around a missing tool** — by falling back to raw SQL, guessing a file's
contents, or doing the job locally instead of in Nama. When the right tool is not in your tool
list:

1. Tell the user plainly which tool (or tool group) is missing and what it would let you do.
2. Tell them how to add it: open the **AI Tool Definition** record the MCP connection uses, go to
   the System Tool page, and press the matching **Add … Tools** button (or pick the
   **Tool Class Name** from the suggestion list). Check `ai-tool-definitions.md` for the current
   class and button names — the set grows with each release — rather than naming one from memory.
3. **If the import tools are connected** (`<prefix>GetImportSchema` / `<prefix>ImportRecord`), offer
   to add the missing lines to the AI Tool Definition yourself through them — then do it only once
   the user agrees, because it changes the customer's configuration. After it is saved, the user
   must reconnect the MCP server (`/mcp`) for the new tools to appear.

# Keep MCP results small

Live-ERP tools can return very large results (report runs, record searches, application logs, SQL
result sets), and everything they return stays in the conversation for every later message. Ask
for what you need: filter, limit rows (`TOP`), request only the fields that matter, and narrow a
log view to the time window of the incident.
