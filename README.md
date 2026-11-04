# Frontend_Flutter

Flutter mobile app for the **Employee & Product API**, built with GetX, a REST API, the Repository Pattern and JWT authentication.

## Features

- Login and logout with JWT (access token is refreshed automatically on 401)
- Product list with search and category filter
- Employee list with search
- Add, update and delete employees (delete asks for confirmation)
- Form validation, loading indicators and error handling

## API

The backend runs at `http://localhost:33033` (Swagger: `/swagger-ui/index.html`).

| Feature | Endpoint |
|---|---|
| Login / Refresh / Logout | `POST /api/auth/login`, `/api/auth/refresh`, `/api/auth/logout` |
| Products | `GET /api/products` |
| Employees | `GET`, `POST /api/employees`, `PUT`, `DELETE /api/employees/{id}` |

The app connects to `http://10.0.2.2:33033` by default (the Android emulator's address for your PC).
To change it, tap the gear icon on the login screen or open the Profile tab.

## Project structure

```
lib/
  core/services/      HTTP client (ApiService) with token refresh
  data/local/         Token and settings storage (GetStorage)
  data/repositories/  Auth, Product and Employee repositories
  models/             API models
  modules/            Screens: splash, login, home, dashboard, product, employee
  routes/             GetX routes
  widgets/            Shared UI widgets
```

## Run

```
flutter pub get
flutter run
```
