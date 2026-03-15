# EFUZY Public Site

This document describes the public-facing EFUZY site.

## Purpose

The public site lives at the root URL.

It is a marketing and lead-generation surface.

It is not the main workflow application.

It points to the evaluation workspace.

It keeps the same visual language as the product.

## Stack

- MIO web server
- MIOROUTE
- MIOTPL
- Tailwind CSS
- SSR-first rendering
- Minimal JavaScript for theme and motion

## Routes

- `GET /`
- `GET /features`
- `GET /demo`
- `GET /contact`
- `POST /contact`
- `GET /privacy`
- `GET /terms`
- `GET /robots.txt`
- `GET /sitemap.xml`

## Config

The site uses `CONF("fuz",...)`.

Defaults are applied by `CONFDEF^FUZUI`.

Important keys:

- `siteUrl`
- `brand`
- `tagline`
- `demoHref`
- `demoArtifactTtlHours`
- `demoArtifactTtlLabel`
- `contactEmail`
- `contactMaxMessageChars`

## Contact form

The contact form is SSR-first.

It submits to `POST /contact`.

Validation stays server-side.

Leads are stored under `^MIO("FUZ","contact",...)`.

A honeypot field is included.

## SEO

The layout emits:

- title
- meta description
- canonical URL
- Open Graph tags
- Twitter card tags
- JSON-LD
- robots.txt
- sitemap.xml

## Tests

- `START^FUZT`
- `START^FUZPT`
- `START^FUZROUTET`
- `D ^FUZTESTS`
