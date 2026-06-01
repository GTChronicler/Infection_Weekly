# Desktop App

This folder contains the Windows GUI wrapper for Infection Weekly.

Build from the project root:

```powershell
powershell -ExecutionPolicy Bypass -File desktop_app\build_exe.ps1
```

The build creates:

```text
InfectionWeekly.exe
```

The executable expects the existing project folders beside it:

```text
config/
input_database/
outputs/
```

The generated executable and PyInstaller build artifacts are intentionally ignored by Git.

The app uses `python-calamine` for reading exported Excel workbooks, because some local `A.xlsx` files are not fully readable by `openpyxl`.
