# fleet_garage_manager

A professional offline fleet garage management application for vehicle maintenance, accident reporting, fleet tracking, work orders, departmental management, PDF export, JSON backup, and mobile-first usage.

## Features included in this initial project scaffold
- Fleet dashboard with KPI cards and charts
- Vehicle and driver tracking
- Garage and company department management
- Work orders and accident reporting
- Offline data persistence using JSON-backed storage
- PDF/print-oriented data model and export hooks
- Camera and gallery image import structure for accident reports
- Mobile scanner integration preparation for plate number lookup
- JSON backup export/import support structure
- Responsive side menu with icon-only collapse support

## Project structure
- `lib/main.dart` - app bootstrap and state container
- `lib/models/models.dart` - models for vehicles, work orders, departments, and reports
- `lib/services/local_data_store.dart` - JSON persistence and offline storage
- `lib/screens/` - dashboard, fleet, work orders, accident reports, and settings screens

## Run locally
1. Install Flutter SDK.
2. Run:
   ```bash
   flutter pub get
   flutter run
   ```

## Notes
This repository contains the initial architecture and working UI scaffold for a fleet garage app. Additional feature expansion, Excel import, real PDF generation, and full mobile scanning behavior can be implemented in later iterations.
