# Calendar Event Form

- Rute: `/calendar/event-form`
- File: `lib/app/screens/calendar/calendar_event_form_screen.dart`
- Widget yang digunakan: `NeumaTextField.compact`, `NeumaCard`, `NeumaButton`

Field:
- Title (wajib)
- Description (opsional)
- Location (opsional)
- Start Date
- End Date (opsional)
- All Day (switch)

Action:
- Add / Update menyimpan ke tabel `calendar_events` via `SupabaseService`.