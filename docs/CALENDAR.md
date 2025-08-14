# Calendar

Fitur kalender menggabungkan beberapa sumber event:

- Todo: menggunakan `dueDate` bila tersedia, fallback `createdAt`
- Finance: tanggal `start_date`
- Calendar Events: tabel `calendar_events` (event internal)

## Layar

- `CalendarScreen` menampilkan kalender bulanan dan daftar event
- Tombol + (app bar) membuka `CalendarEventFormScreen` untuk menambah event

## Data Flow

- `CalendarDataBloc` memuat data dari `SupabaseService`:
  - `getTodosByDateRange(start, end)`
  - `getFinancesByDateRange(start, end)`
  - `getCalendarEventsByDateRange(start, end)`

## CRUD Event

- Model: `app/models/calendar_event.dart`
- Service: `SupabaseService`
  - `addCalendarEvent`, `updateCalendarEvent`, `deleteCalendarEvent`
- Form: `CalendarEventFormScreen` menggunakan Neuma widgets

## Catatan

- Tabel `calendar_events` disiapkan pada file migrasi `database/migrations/2025-08-14_add_core_tables.sql`
- Rekomendasi lanjutan: recurring events, color coding per household/member