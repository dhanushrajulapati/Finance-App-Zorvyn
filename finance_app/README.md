<div align="center">
  <img src="https://raw.githubusercontent.com/dhanushrajulapati/Finance-App-Zorvyn/main/finance_app/web/icons/Icon-192.png" width="120" alt="Finance Companion Logo">
  <h1>Zorvyn Finance Companion</h1>
  <p>A modern, secure, and multi-tenant personal finance tracking application built with Flutter and Supabase.</p>
</div>

---

## ✨ Features

* **Secure Multi-Tenant Authentication**: Complete user isolation with Supabase Auth. Every user has their own private, secure dataset.
* **Smart Dashboard**: A beautifully designed home screen giving you an instant overview of your financial health, recent activity, and balances.
* **Expense & Income Tracking**: Easily add, edit, and categorize your transactions with intuitive dialogs. 
* **Dynamic Analytics**: Visualize your spending habits with interactive charts powered by `fl_chart`.
* **Monthly Challenge Goals**: Set a monthly spending limit and watch your animated progress bar fill up as you track expenses.
* **Theme Engine**: Fully responsive Light and Dark mode options matching your system preferences.
* **Row-Level Security (RLS)**: Enterprise-grade database protection utilizing Supabase's strict postgres policies.

## 🛠️ Technology Stack

* **Frontend Engine**: [Flutter](https://flutter.dev/) (Dart)
* **State Management**: Provider
* **Backend as a Service (BaaS)**: [Supabase](https://supabase.com/)
* **Database**: PostgreSQL
* **Local Caching**: Shared Preferences

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
- A [Supabase](https://supabase.com/) account and a new project.

### 1. Database Setup
Once your Supabase project is set up, navigate to the **SQL Editor** and run the following commands to construct the backend architecture and enable security:

```sql
-- Create core tables
CREATE TABLE transactions (
    id UUID PRIMARY KEY,
    amount DOUBLE PRECISION NOT NULL,
    type TEXT NOT NULL,
    category TEXT NOT NULL,
    date TIMESTAMP WITH TIME ZONE NOT NULL,
    notes TEXT,
    user_id UUID REFERENCES auth.users(id) NOT NULL
);

CREATE TABLE goals (
    id UUID PRIMARY KEY,
    target_amount DOUBLE PRECISION NOT NULL,
    month TIMESTAMP WITH TIME ZONE NOT NULL,
    user_id UUID REFERENCES auth.users(id) NOT NULL
);

-- Enable Row Level Security (RLS)
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE goals ENABLE ROW LEVEL SECURITY;

-- Establish Strict Isolation Policies
CREATE POLICY "Strict Isolation Transactions" ON transactions FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Strict Isolation Goals" ON goals FOR ALL USING (auth.uid() = user_id);
```

### 2. Connect Your App
Inside the project, navigate to `lib/core/constants.dart` and paste in your unique Supabase `URL` and `Anon Key`.
```dart
class AppConstants {
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
}
```

### 3. Run the App
Open your terminal inside the project directory and run:
```bash
flutter pub get
flutter run
```



---
Developed as a robust capstone software project prioritizing secure cloud-architecture and exceptional UI mapping.
