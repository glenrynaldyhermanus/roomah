# Migrasi Database

File migrasi utama: `database/migrations/2025-08-14_add_core_tables.sql`

## Cara Menjalankan (Supabase SQL Editor)

1. Buka proyek Supabase Anda
2. Masuk ke SQL Editor
3. Paste seluruh isi file migrasi di atas
4. Jalankan query

Aman untuk rerun: menggunakan `IF NOT EXISTS` dan `ADD COLUMN IF NOT EXISTS`.

## Perubahan Utama

- Todos:
  - Kolom `due_date TIMESTAMPTZ`
  - Kolom `priority SMALLINT DEFAULT 0`
  - Kolom `assigned_to UUID` (opsional)
  - Index pada `due_date`, `assigned_to`, `is_completed`
- Tags (opsional) dan relasi `todo_tags`
- Routines:
  - `routine_assignments`, `routine_exceptions`, `routine_logs`
- Reminders untuk Todo/Routine
- Calendar internal: `calendar_events`
- Multi-user:
  - `households`, `household_members` + kolom `household_id` di entitas utama

## Catatan RLS
Semua tabel baru sudah `ENABLE ROW LEVEL SECURITY`. Tambahkan policy sesuai model akses Anda (misalnya berdasarkan `created_by` atau membership household).