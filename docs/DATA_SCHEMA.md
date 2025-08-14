## Data Schema (App Models)

- User
  - id, email, username, createdAt

- Todo
  - id, title, description?, isCompleted, createdAt, completedAt?, dueDate?, priority (0=Low,1=Med,2=High)
  - Next: assignedTo?, tags[]?

- Finance
  - id, name, amount, startDate, endDate, createdAt

- RoutineCategory
  - id, name, color, icon, createdAt

- Routine
  - id, title, description?, categoryId?, frequencyType ('daily'|'weekly'|'monthly'|'custom'), frequencyValue (int), lastCompletedAt?, nextDueDate, isActive, createdAt
  - Next: assignees [userId], points (fairness), exceptions (skip dates)

## Gap & Rencana Migrasi

- Todos: tambahkan `due_date` dan `assigned_to` (opsional) → support Today prioritization
- Routines: tabel `routine_exceptions` (date, reason) dan `routine_assignments` (routineId, userId, points)
- Reminders: tabel `reminders` terhubung ke todo/routine (channel: local push, scheduleAt)
- Pantry/To-Buy: `stores`, `items`, `shopping_list_items` (qty, priority)

Skema SQL akan ditambahkan bertahap sesuai fase.