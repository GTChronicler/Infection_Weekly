# Changelog

## 2026-06-01

### Initial open-source project structure
- Initialized the Git repository on the `main` branch.
- Organized project files into `config/`, `input_database/`, `outputs/`, `scripts/`, `docs/`, and `changelog/`.
- Added `.gitignore` rules to keep local input data and generated outputs out of Git.
- Added `.gitkeep` placeholders so `input_database/` and `outputs/` remain visible in the repository.

### Update script paths for project directories
- Updated `scripts/main_v0_2.R` to read inputs from `input_database/` and `config/`.
- Updated generated report and table outputs to write into `outputs/`.
- Verified the script runs successfully from the project root with `Rscript scripts/main_v0_2.R`.
