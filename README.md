# Roomah - Aplikasi Manajemen Rumah Tangga

Aplikasi Flutter untuk mengelola rumah tangga dengan fitur todo, keuangan, rutinitas, dan kalender.

## 🎨 Custom Widgets

### NeumaToggle

Widget toggle custom dengan desain neumorphic yang memberikan animasi smooth dan visual feedback yang jelas.

#### Fitur:

- ✅ **Smooth Animation**: Thumb bergerak dengan animasi 300ms
- ✅ **Neumorphic Style**: Shadow dan depth yang konsisten
- ✅ **Text Visibility**: Text selalu terlihat, tidak tertutup thumb
- ✅ **Color Customization**: Bisa custom active/inactive colors
- ✅ **Responsive**: Menyesuaikan dengan screen width
- ✅ **Touch Friendly**: Area tap yang cukup besar

#### Penggunaan:

```dart
NeumaToggle(
  selectedIndex: _selectedIndex,
  options: const ['Option 1', 'Option 2', 'Option 3'],
  onChanged: (index) => setState(() => _selectedIndex = index),
  height: 50,
  activeColor: Colors.blue[600],
  activeTextColor: Colors.white,
  inactiveTextColor: Colors.grey[700],
)
```

#### Parameter:

- `selectedIndex` (required): Index opsi yang sedang dipilih
- `options` (required): List string opsi yang akan ditampilkan
- `onChanged` (required): Callback function saat selection berubah
- `height` (optional): Tinggi widget (default: 50)
- `activeColor` (optional): Warna thumb aktif (default: Colors.blue[600])
- `inactiveColor` (optional): Warna background tidak aktif (default: theme.baseColor)
- `activeTextColor` (optional): Warna text aktif (default: Colors.white)
- `inactiveTextColor` (optional): Warna text tidak aktif (default: Colors.grey[700])

#### Contoh Implementasi:

**Finance Screen:**

```dart
NeumaToggle(
  selectedIndex: _tabController.index,
  options: const ['Finances', 'Budget'],
  onChanged: (int index) {
    _tabController.animateTo(index);
  },
  height: 50,
  activeColor: Colors.blue[600],
  activeTextColor: Colors.white,
  inactiveTextColor: Colors.grey[700],
)
```

**Dashboard Screen:**

```dart
NeumaToggle(
  selectedIndex: _selectedViewIndex,
  options: const ['Ringkasan', 'Aktivitas', 'Laporan'],
  onChanged: (index) => setState(() => _selectedViewIndex = index),
  height: 45,
  activeColor: Colors.purple[600],
  activeTextColor: Colors.white,
  inactiveTextColor: Colors.grey[700],
)
```

## 🏗️ Struktur Database

### Tabel Utama:

- `users` - Data pengguna
- `todos` - Daftar todo
- `finances` - Data keuangan
- `routine_categories` - Kategori rutinitas
- `routines` - Rutinitas harian

### Fitur Kategori:

- ✅ **Routine Categories**: Kategori untuk rutinitas dengan color dan icon
- ✅ **Visual Grouping**: Rutinitas dikelompokkan berdasarkan kategori
- ✅ **Uncategorized**: Rutinitas tanpa kategori ditampilkan terpisah

## 🚀 Fitur Utama

### 1. Todo Management

- ✅ CRUD operasi untuk todo
- ✅ Mark as completed
- ✅ Group by completion status

### 2. Finance Tracking

- ✅ Input data keuangan
- ✅ Toggle view (Finances/Budget)
- ✅ Visual statistics

### 3. Routine Management

- ✅ CRUD operasi untuk rutinitas
- ✅ Kategori rutinitas
- ✅ Frequency tracking
- ✅ Completion tracking

### 4. Calendar Integration

- ✅ Event management
- ✅ Date-based views

## 🎯 Teknologi

- **Framework**: Flutter
- **State Management**: BLoC Pattern
- **UI Design**: Neumorphic Design
- **Database**: Supabase
- **Navigation**: GoRouter
- **Icons**: Phosphor Icons

## 📱 Screenshots

[Add screenshots here]

## 🔧 Setup

1. Clone repository
2. Install dependencies: `flutter pub get`
3. Setup Supabase configuration
4. Run: `flutter run`

## 📝 License

MIT License
