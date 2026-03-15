---
name: research-scout
description: Search for relevant papers, tools, and repos across multiple sources based on a query. Use when looking for research, libraries, or technical content useful for ML engineering work.
disable-model-invocation: true
---

# Research Scout

Given a user query, select the relevant sources below, fetch results from each, and return a curated summary of findings that are actually useful for the query.

Not every source is relevant to every query. Read the source descriptions and only use the ones that make sense.

## Sources

### arXiv — Academic Papers (CS, ML, AI, Math, etc.)
- **What it is**: Preprint server. The primary source for ML/AI research papers.
- **When to use**: Query involves research, algorithms, models, training techniques, architectures, or any academic topic.
- **Categories**: `cs.LG` (ML), `cs.CL` (NLP), `cs.CV` (vision), `cs.AI` (AI), `stat.ML` (stats), and many more.
- **How to fetch**:
  ```bash
  # Keyword search (replace QUERY with url-encoded terms)
  curl -s "https://export.arxiv.org/api/query?search_query=all:QUERY&sortBy=submittedDate&sortOrder=descending&max_results=15"

  # Category browse (e.g. recent ML papers)
  curl -s "https://export.arxiv.org/api/query?search_query=cat:cs.LG&sortBy=submittedDate&sortOrder=descending&max_results=15"

  # Combined (keyword + category)
  curl -s "https://export.arxiv.org/api/query?search_query=all:QUERY+AND+cat:cs.LG&sortBy=submittedDate&sortOrder=descending&max_results=15"

  # Author search
  curl -s "https://export.arxiv.org/api/query?search_query=au:AUTHOR&sortBy=submittedDate&sortOrder=descending&max_results=15"
  ```
- **Response**: XML (Atom feed). Parse `<entry>` elements for `<title>`, `<summary>`, `<published>`, `<id>` (link), `<author>`.
- **Rate limit**: 3 seconds between requests.

### AlphaXiv — Trending Discussed Papers
- **What it is**: Shows which arXiv papers are getting the most community attention and discussion right now.
- **When to use**: Query is open-ended ("what's interesting in ML"), or you want to find papers the community considers important rather than just recent.
- **How to fetch**:
  ```bash
  # Fetch front page (SPA — data is embedded in HTML as serialized payload)
  curl -s "https://www.alphaxiv.org/"
  ```
- **Parsing**: Extract paper data from embedded RSC payload. Look for `title:"..."` and `universal_paper_id:"YYMM.NNNNN"` patterns in the HTML. Links are `https://arxiv.org/abs/{paper_id}`.
- **Note**: No public API. Parsing is fragile — if extraction fails, skip this source and note it.

### GitHub Trending — Popular Repositories
- **What it is**: Repositories gaining the most stars recently.
- **When to use**: Query is about tools, libraries, frameworks, open-source projects, or practical implementations.
- **How to fetch**:
  ```bash
  # Weekly trending (also: ?since=daily or ?since=monthly)
  curl -s "https://github.com/trending?since=weekly"
  ```
- **Parsing**: HTML scraping. Extract repo links from `<h2>` elements with class `h3 lh-condensed`. Repo URLs follow the pattern `/owner/repo`. Descriptions are in adjacent `<p>` tags.
- **Filtering**: Can also filter by language: `https://github.com/trending/python?since=weekly`

### Stripe Dev Blog — Engineering & Infrastructure
- **What it is**: Engineering blog covering infrastructure, developer tooling, API design, coding agents, and production systems.
- **When to use**: Query is about API design, developer experience, infrastructure patterns, production engineering, or payment systems.
- **How to fetch**:
  ```bash
  curl -s "https://stripe.dev/blog"
  ```
- **Parsing**: HTML scraping. Extract post links matching `/blog/POST-SLUG` pattern and their titles. Full URL: `https://stripe.dev/blog/POST-SLUG`.

### Hacker News — Tech Community Discussion
- **What it is**: Community-curated tech news. Covers startups, open source, research, engineering, and industry.
- **When to use**: Query is broad, industry-oriented, or you want to see what the tech community is currently discussing. Good for finding tools, blog posts, and projects.
- **How to fetch**:
  ```bash
  # Get top 30 story IDs
  curl -s "https://hacker-news.firebaseio.com/v0/topstories.json"

  # Get details for a single story (replace ID)
  curl -s "https://hacker-news.firebaseio.com/v0/item/ID.json"
  ```
- **Response**: JSON. Each item has `title`, `url`, `score`, `by` (author), `time` (unix timestamp).
- **Tip**: Fetch top 30 IDs, then fetch details for each. Filter by score or relevance to the query.

## Usage

```
/skill:research-scout something interesting to read about ML this week
/skill:research-scout project ideas around computer vision
/skill:research-scout what's new in AI infrastructure
/skill:research-scout startup ideas in developer tooling
```

## Instructions

1. Read the query.
2. Decide which sources are relevant. Explain your reasoning briefly.
3. Fetch results from each selected source.
4. Filter out noise — only include results that are actually relevant to the query.
5. For each result, provide:
   - **Title**
   - **Source** (which source it came from)
   - **Link**
   - **Why it's relevant** (one sentence)
6. Group results by source.
7. If nothing relevant was found, say so — don't pad with loosely related results.
