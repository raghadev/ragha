#!/usr/bin/env python3
"""
mactools MCP — ferramentas de sistema pro agente: navegador especifico, trafego de rede,
organizar arquivos, criar apps standalone no Mac. Todas via macOS nativo.
"""
import subprocess, os, shutil, glob, json
from mcp.server.fastmcp import FastMCP

HOME = os.path.expanduser("~")
mcp = FastMCP("mactools")


def sh(args, t=30):
    try:
        return subprocess.run(args, capture_output=True, text=True, timeout=t).stdout.strip()
    except Exception as e:
        return f"erro: {e}"


@mcp.tool()
def list_browsers() -> str:
    """Lista os navegadores instalados no Mac (nomes exatos p/ usar em open_url)."""
    found = []
    for name in ["Safari", "Google Chrome", "Firefox", "Microsoft Edge", "Arc", "Brave Browser", "Opera"]:
        if os.path.isdir(f"/Applications/{name}.app"):
            found.append(name)
    return "Navegadores: " + (", ".join(found) if found else "nenhum encontrado")


@mcp.tool()
def open_url(url: str, browser: str = "") -> str:
    """Abre uma URL num navegador ESPECIFICO (ex browser='Google Chrome'). Sem browser = o padrao do sistema."""
    if not url.startswith(("http://", "https://", "file://")):
        url = "https://" + url
    if browser:
        r = subprocess.run(["open", "-a", browser, url], capture_output=True, text=True)
        return f"abri {url} no {browser}" if r.returncode == 0 else f"erro: {r.stderr.strip()}"
    subprocess.run(["open", url])
    return f"abri {url} no navegador padrao"


@mcp.tool()
def browser_traffic(browser: str = "Google Chrome", limit: int = 25) -> str:
    """Mostra o TRAFEGO de rede ao vivo do navegador/extensoes: para quais hosts ele esta conectado agora.
    Util p/ ver o que uma extensao esta acessando."""
    procname = browser.split()[0]  # "Google" p/ Chrome, etc; usa -c substring
    out = sh(["bash", "-c",
              f"lsof -nP -iTCP -sTCP:ESTABLISHED 2>/dev/null | grep -iE '{procname}' | awk '{{print $9}}' | sed 's/.*->//' | sort | uniq -c | sort -rn | head -{limit}"])
    if not out:
        return f"nenhuma conexao ativa de '{browser}' (o navegador esta aberto e navegando?)"
    # resolve IPs -> host quando possivel
    lines = []
    for l in out.splitlines():
        lines.append(l.strip())
    return "Trafego ativo (conexoes -> host:porta):\n" + "\n".join(lines)


@mcp.tool()
def organize_files(folder: str, mode: str = "ext") -> str:
    """Organiza os arquivos de uma pasta em subpastas. mode='ext' (por tipo) ou 'date' (por ano-mes).
    So mexe em arquivos soltos na raiz da pasta (nao entra em subpastas)."""
    folder = os.path.expanduser(folder)
    if not os.path.isdir(folder):
        return f"pasta nao existe: {folder}"
    cats = {
        "Imagens": {".jpg", ".jpeg", ".png", ".gif", ".heic", ".webp", ".bmp", ".svg", ".tiff"},
        "Documentos": {".pdf", ".doc", ".docx", ".txt", ".md", ".rtf", ".pages", ".odt"},
        "Planilhas": {".xls", ".xlsx", ".csv", ".numbers"},
        "Videos": {".mp4", ".mov", ".mkv", ".avi", ".webm"},
        "Audio": {".mp3", ".wav", ".m4a", ".flac", ".aac"},
        "Compactados": {".zip", ".rar", ".7z", ".tar", ".gz", ".dmg"},
        "Codigo": {".py", ".js", ".ts", ".sh", ".json", ".html", ".css", ".rs", ".go", ".c", ".cpp"},
        "Apps": {".app", ".pkg"},
    }
    moved = 0
    import time
    for name in os.listdir(folder):
        src = os.path.join(folder, name)
        if not os.path.isfile(src) or name.startswith("."):
            continue
        if mode == "date":
            t = time.localtime(os.path.getmtime(src))
            sub = f"{t.tm_year}-{t.tm_mon:02d}"
        else:
            ext = os.path.splitext(name)[1].lower()
            sub = next((c for c, exts in cats.items() if ext in exts), "Outros")
        dst_dir = os.path.join(folder, sub)
        os.makedirs(dst_dir, exist_ok=True)
        try:
            shutil.move(src, os.path.join(dst_dir, name)); moved += 1
        except Exception:
            pass
    return f"organizados {moved} arquivos em {folder} (modo={mode})"


@mcp.tool()
def make_app(name: str, kind: str, target: str) -> str:
    """Cria um app standalone no Mac (~/Desktop/<name>.app). kind='url' (abre um site) ou 'command' (roda um comando shell).
    target = a URL (kind url) ou o comando (kind command)."""
    app = f"{HOME}/Desktop/{name}.app"
    macos = f"{app}/Contents/MacOS"
    os.makedirs(macos, exist_ok=True)
    if kind == "url":
        body = f'#!/bin/bash\nopen "{target}"\n'
    else:
        body = f'#!/bin/bash\n{target}\n'
    exe = f"{macos}/{name}"
    open(exe, "w").write(body)
    os.chmod(exe, 0o755)
    plist = f'''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
 <key>CFBundleName</key><string>{name}</string>
 <key>CFBundleExecutable</key><string>{name}</string>
 <key>CFBundlePackageType</key><string>APPL</string>
 <key>CFBundleIdentifier</key><string>local.mactools.{name.lower().replace(" ","")}</string>
</dict></plist>'''
    open(f"{app}/Contents/Info.plist", "w").write(plist)
    open(f"{app}/Contents/PkgInfo", "w").write("APPL????")
    subprocess.run(["xattr", "-cr", app], capture_output=True)
    return f"app criado: {app} (kind={kind}). Duplo-clique no Desktop pra usar."


if __name__ == "__main__":
    mcp.run()
