from __future__ import annotations

import ctypes
import shutil
import sys
import traceback
from pathlib import Path
from tkinter import END, BOTH, LEFT, RIGHT, VERTICAL, Y, filedialog, messagebox
import tkinter as tk
import tkinter.font as tkfont
from tkinter import ttk
import os

from infection_weekly_engine import (
    ConfigError,
    ReportConfig,
    generate_report,
    load_ui_options,
    project_root,
    read_report_config,
    write_report_config,
)


def enable_dpi_awareness() -> None:
    if sys.platform != "win32":
        return
    try:
        ctypes.windll.shcore.SetProcessDpiAwareness(2)
        return
    except Exception:
        pass
    try:
        ctypes.windll.user32.SetProcessDPIAware()
    except Exception:
        pass


class InfectionWeeklyApp(tk.Tk):
    def __init__(self) -> None:
        enable_dpi_awareness()
        super().__init__()
        self._configure_dpi_scaling()
        self.title("Infection Weekly")
        self.geometry(self._initial_geometry())
        self.minsize(900, 600)
        self.root_dir = project_root()
        self.date_var = tk.StringVar()
        self.status_var = tk.StringVar(value=f"项目目录：{self.root_dir}")
        self.disease_options: list[str] = []
        self.overview_options: list[str] = []
        self.focus_options: list[str] = []

        self._build_ui()
        self.load_config_to_ui()

    def _configure_dpi_scaling(self) -> None:
        try:
            scaling = max(1.0, self.winfo_fpixels("1i") / 72)
            self.tk.call("tk", "scaling", scaling)
        except tk.TclError:
            pass

        for font_name in (
            "TkDefaultFont",
            "TkTextFont",
            "TkMenuFont",
            "TkHeadingFont",
            "TkCaptionFont",
            "TkSmallCaptionFont",
            "TkIconFont",
            "TkTooltipFont",
        ):
            try:
                tkfont.nametofont(font_name).configure(family="Microsoft YaHei UI", size=10)
            except tk.TclError:
                continue

    def _initial_geometry(self) -> str:
        width = min(max(980, int(self.winfo_screenwidth() * 0.42)), 1280)
        height = min(max(680, int(self.winfo_screenheight() * 0.55)), 900)
        return f"{width}x{height}"

    def _build_ui(self) -> None:
        container = ttk.Frame(self, padding=12)
        container.pack(fill=BOTH, expand=True)

        top = ttk.Frame(container)
        top.pack(fill="x")

        ttk.Label(top, text="周一日期 date_Mon").pack(side=LEFT)
        ttk.Entry(top, textvariable=self.date_var, width=16).pack(side=LEFT, padx=(8, 20))
        ttk.Button(top, text="重新读取配置", command=self.load_config_to_ui).pack(side=LEFT, padx=4)
        ttk.Button(top, text="保存配置", command=self.save_config_from_ui).pack(side=LEFT, padx=4)
        ttk.Button(top, text="生成报告", command=self.generate_report_from_ui).pack(side=LEFT, padx=4)

        file_frame = ttk.LabelFrame(container, text="输入文件")
        file_frame.pack(fill="x", pady=(12, 8))
        ttk.Button(file_frame, text="选择并覆盖 A.xlsx（分年龄统计表）", command=self.choose_a_file).pack(side=LEFT, padx=8, pady=8)
        ttk.Button(file_frame, text="选择并覆盖 B.xlsx（疫情分析统计表）", command=self.choose_b_file).pack(side=LEFT, padx=8, pady=8)
        ttk.Button(file_frame, text="打开 outputs 文件夹", command=self.open_outputs).pack(side=LEFT, padx=8, pady=8)

        lists = ttk.Frame(container)
        lists.pack(fill=BOTH, expand=True, pady=8)
        self.overview_list = self._make_listbox(lists, "一、疫情概况点名疾病 overview_diseases")
        self.focus_list = self._make_listbox(lists, "二、重点疫情展开疾病 focus_diseases")

        ttk.Label(
            container,
            text="提示：打开后会默认读取当前 report_config.txt。按住 Ctrl 或 Shift 可多选疾病；保存配置会同步写回 config/report_config.txt。",
        ).pack(fill="x", pady=(8, 4))
        ttk.Label(container, textvariable=self.status_var, foreground="#1f5f9f").pack(fill="x")

    def _make_listbox(self, parent: ttk.Frame, title: str) -> tk.Listbox:
        frame = ttk.LabelFrame(parent, text=title)
        frame.pack(side=LEFT, fill=BOTH, expand=True, padx=6)
        scrollbar = ttk.Scrollbar(frame, orient=VERTICAL)
        listbox = tk.Listbox(frame, selectmode=tk.EXTENDED, exportselection=False, height=20)
        listbox.configure(yscrollcommand=scrollbar.set)
        scrollbar.configure(command=listbox.yview)
        listbox.pack(side=LEFT, fill=BOTH, expand=True, padx=(8, 0), pady=8)
        scrollbar.pack(side=RIGHT, fill=Y, padx=(0, 8), pady=8)
        return listbox

    def load_config_to_ui(self) -> None:
        try:
            config, options = load_ui_options(self.root_dir)
            self.disease_options = options
            self.overview_options = self._ordered_options(config.overview_diseases)
            self.focus_options = self._ordered_options(config.focus_diseases)
            self.date_var.set(config.date_mon)
            self._fill_listbox(self.overview_list, self.overview_options, config.overview_diseases)
            self._fill_listbox(self.focus_list, self.focus_options, config.focus_diseases)
            self.status_var.set("已读取当前 config/report_config.txt")
        except Exception as exc:
            messagebox.showerror("读取配置失败", str(exc))
            self.status_var.set("读取配置失败")

    def _ordered_options(self, selected: list[str]) -> list[str]:
        ordered = list(selected)
        ordered.extend(disease for disease in self.disease_options if disease not in ordered)
        return ordered

    def _fill_listbox(self, listbox: tk.Listbox, options: list[str], selected: list[str]) -> None:
        listbox.delete(0, END)
        for disease in options:
            listbox.insert(END, disease)
        selected_set = set(selected)
        for index, disease in enumerate(options):
            if disease in selected_set:
                listbox.selection_set(index)

    def _selected(self, listbox: tk.Listbox, options: list[str]) -> list[str]:
        return [options[index] for index in listbox.curselection()]

    def current_config(self) -> ReportConfig:
        return ReportConfig(
            date_mon=self.date_var.get().strip(),
            overview_diseases=self._selected(self.overview_list, self.overview_options),
            focus_diseases=self._selected(self.focus_list, self.focus_options),
        )

    def save_config_from_ui(self, show_message: bool = True) -> bool:
        try:
            config = self.current_config()
            if not config.overview_diseases:
                raise ConfigError("请至少选择一个疫情概况疾病 / Select at least one overview disease.")
            if not config.focus_diseases:
                raise ConfigError("请至少选择一个重点疫情疾病 / Select at least one focus disease.")
            target = self.root_dir / "config" / "report_config.txt"
            write_report_config(target, config)
            read_report_config(target)
            self.status_var.set("配置已保存到 config/report_config.txt")
            if show_message:
                messagebox.showinfo("保存成功", "配置已保存。")
            return True
        except Exception as exc:
            messagebox.showerror("保存配置失败", str(exc))
            self.status_var.set("保存配置失败")
            return False

    def _copy_input(self, target_name: str, label: str) -> None:
        source = filedialog.askopenfilename(
            title=f"选择 {target_name}",
            filetypes=[("Excel files", "*.xlsx"), ("All files", "*.*")],
        )
        if not source:
            return
        target = self.root_dir / "input_database" / target_name
        target.parent.mkdir(exist_ok=True)
        shutil.copy2(source, target)
        self.status_var.set(f"已覆盖 {target}")
        messagebox.showinfo("导入成功", f"{label} 已复制到：\n{target}")

    def choose_a_file(self) -> None:
        self._copy_input("A.xlsx", "A.xlsx")

    def choose_b_file(self) -> None:
        self._copy_input("B.xlsx", "B.xlsx")

    def generate_report_from_ui(self) -> None:
        try:
            if not self.save_config_from_ui(show_message=False):
                return
            result = generate_report(self.root_dir)
            self.status_var.set(f"生成完成：{result.docx_path.name}，{result.csv_path.name}")
            messagebox.showinfo(
                "生成完成",
                f"已生成：\n{result.docx_path}\n{result.csv_path}",
            )
        except Exception as exc:
            detail = "".join(traceback.format_exception_only(type(exc), exc)).strip()
            messagebox.showerror("生成失败", detail)
            self.status_var.set("生成失败")

    def open_outputs(self) -> None:
        outputs = self.root_dir / "outputs"
        outputs.mkdir(exist_ok=True)
        os.startfile(outputs)


def main() -> None:
    if "--generate" in sys.argv:
        generate_report(project_root())
        return
    app = InfectionWeeklyApp()
    app.mainloop()


if __name__ == "__main__":
    main()
