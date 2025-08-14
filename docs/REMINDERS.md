# Reminders

Tabel `reminders` mendukung pengingat untuk To-Do atau Routine.

## Struktur

- Target: `todo_id` XOR `routine_id`
- Waktu: `schedule_at`
- Kanal: `local` atau `push`
- Status: `is_sent`, `sent_at`

## Integrasi Aplikasi

- Service: tambah fungsi `getRemindersDue(now)`, `addReminder`, `markSent`
- UI: tombol "Add Reminder" di form Todo/Routine
- Notifikasi: gunakan `flutter_local_notifications` untuk men-schedule local notification

## Rekomendasi Policy

- Batasi akses ke `created_by = auth.uid()` atau berdasarkan membership household