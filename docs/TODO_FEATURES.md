# Todo Enhancements

Fitur baru untuk To-Do:

- Due Date: pilih tanggal jatuh tempo
- Priority: Low / Med / High (NeumaToggle)
- Quick Add: input cepat dari Dashboard

## Form To-Do

- Field Title dan Description tetap sama (NeumaTextField)
- Priority menggunakan `NeumaToggle`
- Due Date menggunakan tombol pilih tanggal

## List To-Do

- Toggle pengurutan (NeumaToggle): Created / Due / Priority
- Item menampilkan due date (jika ada) dan priority badge sederhana
- Aksi: complete/undo, edit, delete

## Dashboard Quick Add

- Kartu input cepat di bagian "To-Do Aktif":
  - NeumaTextField kompakt + tombol Add
  - Menambahkan To-Do minimal (title saja)

## Kalender

- Event To-Do kini menggunakan `dueDate` bila tersedia; fallback ke `createdAt`