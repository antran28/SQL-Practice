SELECT pages.page_id
  FROM pages
LEFT OUTER JOIN page_likes
  ON pages.page_id = page_likes.page_id
WHERE page_likes.page_id is NULL;
