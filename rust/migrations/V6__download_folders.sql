-- Download folders (logical grouping only; deleting a folder does not mutate downloads)

CREATE TABLE IF NOT EXISTS download_folders (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  created_at INTEGER NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_download_folders_created_at ON download_folders(created_at DESC);

-- Add folder_id to downloads by rebuilding the table (SQLite lacks IF NOT EXISTS for ADD COLUMN)
CREATE TABLE IF NOT EXISTS downloads_new (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  video_id TEXT NOT NULL UNIQUE,
  title TEXT NOT NULL,
  cover_url TEXT,
  video_url TEXT NOT NULL,
  quality TEXT,
  description TEXT,
  tags TEXT,
  cover_path TEXT,
  author_id TEXT,
  author_name TEXT,
  author_avatar_url TEXT,
  author_avatar_path TEXT,
  folder_id TEXT,
  save_path TEXT,
  total_bytes INTEGER DEFAULT 0,
  downloaded_bytes INTEGER DEFAULT 0,
  status INTEGER DEFAULT 0,
  error_message TEXT,
  created_at INTEGER NOT NULL,
  completed_at INTEGER
);

INSERT OR IGNORE INTO downloads_new (
  id, video_id, title, cover_url, video_url, quality, description, tags, cover_path,
  author_id, author_name, author_avatar_url, author_avatar_path,
  folder_id,
  save_path, total_bytes, downloaded_bytes, status, error_message, created_at, completed_at
)
SELECT
  id, video_id, title, cover_url, video_url, quality, description, tags, cover_path,
  author_id, author_name, author_avatar_url, author_avatar_path,
  NULL,
  save_path, total_bytes, downloaded_bytes, status, error_message, created_at, completed_at
FROM downloads;

DROP TABLE downloads;
ALTER TABLE downloads_new RENAME TO downloads;

CREATE INDEX IF NOT EXISTS idx_downloads_status ON downloads(status);
CREATE INDEX IF NOT EXISTS idx_downloads_folder_id ON downloads(folder_id);

