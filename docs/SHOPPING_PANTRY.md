# To-Buy & Pantry (Draft)

## Entities

- `stores`: toko
- `items`: master item/pantry (opsional: perishable, shelf life)
- `shopping_list_items`: item yang perlu dibeli (qty, unit, priority, needed_by)

## Alur

- Buat template belanja (opsional) → generate shopping list
- Tandai item sebagai dibeli (check)
- Sinkron ke Pantry (menambah stok), low-stock reminder

## UI (rencana)

- Tab baru "Shopping" dan "Pantry" (gunakan `NeumaToggle` untuk sub-tab)
- Form item & store menggunakan `NeumaTextField` dan `NeumaButton`

## DB

- Lihat migrasi opsional di bagian bawah file migrasi `database/migrations/2025-08-14_add_core_tables.sql`