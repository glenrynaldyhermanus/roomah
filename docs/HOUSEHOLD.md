# Household & Roles

Tujuan: mendukung kolaborasi keluarga. Setiap item (todo, finance, routines) dapat diprivatisasi atau dibagikan lewat `household_id`.

## Struktur

- `households`: entitas rumah tangga
- `household_members`: relasi user ↔ household dengan peran `owner|admin|member`
- Kolom `household_id` ditambahkan ke `todos`, `finances`, `routine_categories`, `routines`

## Akses & RLS (disarankan)

- Policy baca/tulis berdasarkan membership (`household_members`) atau `created_by = auth.uid()`
- Opsi default sederhana: batasi ke `created_by = auth.uid()` hingga membership diaktifkan di UI

## Roadmap UI

- Layar Manage Household: buat household, undang anggota (email), atur roles
- Filter global per-household pada list (toggle di header, gunakan `NeumaToggle`)
- Ownership selector di form (Private vs Household)