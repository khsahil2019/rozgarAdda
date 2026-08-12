# News APIs (current)

Base URL: `https://rozgaradda.com/api`

## 1. Categories — `GET /news-categories`

```json
{
  "status": true,
  "message": "News categories fetched successfully.",
  "data": [{ "id": 10, "name": "Business", "slug": "business" }]
}
```

## 2. States — `GET /states`

```json
{
  "status": true,
  "data": [{ "id": 28, "name": "West Bengal" }]
}
```

> These ids are **not** the same as the `s_id` values from `/states-images` used by
> the state-selection feature. The news controller matches the saved state by
> name to resolve the correct `state_id`.

## 3. Text news — `GET /text-news`

Query params (all required): `category_id`, `state_id`, `page`, `per_page`.

```json
{
  "status": true,
  "message": "Text News List",
  "data": [
    {
      "id": 12,
      "title": "...",
      "category_id": 7,
      "state_id": 28,
      "description": "...",
      "image": "news/1783940409.png",
      "status": "approved",
      "is_seen": 1,
      "added_by": 11,
      "created_at": "2026-07-13T11:00:09.000000Z",
      "updated_at": "2026-08-11T01:21:17.000000Z",
      "image_url": "https://rozgaradda.com/news/1783940409.png",
      "category": { "id": 7, "name": "National News", "slug": "national-news" },
      "state": { "id": 28, "name": "West Bengal" }
    }
  ],
  "pagination": {
    "current_page": 1,
    "per_page": 10,
    "total": 4,
    "last_page": 1,
    "from": 1,
    "to": 4
  }
}
```

Omitting `category_id`/`state_id` returns `422` with
`{"status": false, "message": "Validation failed", "errors": {...}}`.

## 4. Video news — `GET /video-news`

Same query params and envelope as text news. As of 2026-08-12 no video item
exists for any category/state combination, so the item shape could not be
observed; `VideoNewsModel` therefore accepts both the legacy shape
(`subject`, relative `video`) and the text-news-style shape (`description`,
`video_url`, nested `category`/`state`).

> The old `/videos-news` (YouTube) endpoint has been removed — it now returns
> `404 The route api/videos-news could not be found`. The YouTube model, entity
> and player screen were deleted along with it.

## 5. Create news — `POST /store-news`

Requires `Authorization: Bearer <token>`. Multipart form:

| field         | type   |
| ------------- | ------ |
| `category_id` | int    |
| `state_id`    | int    |
| `title`       | string |
| `description` | string |
| `image`       | file   |
