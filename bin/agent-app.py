#!/usr/bin/env python3
"""
agent-app — janela nativa LEVE (WebKit do sistema via pywebview) pro harness.
Sobe o agent-ui local e mostra numa janela desktop. RAM ~10x menor que Electron.
"""
import os, sys, time, subprocess, urllib.request
import webview

PORT = 8799
URL = f"http://127.0.0.1:{PORT}"
HOME = os.path.expanduser("~")
AGENT_UI = f"{HOME}/.local/bin/agent-ui"


def server_up():
    try:
        urllib.request.urlopen(URL + "/status", timeout=1); return True
    except Exception:
        return False


def main():
    proc = None
    if not server_up():
        env = dict(os.environ, AGENT_UI_NOBROWSER="1")
        proc = subprocess.Popen(["python3", AGENT_UI, str(PORT)], env=env,
                                stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        for _ in range(40):
            if server_up():
                break
            time.sleep(0.25)
    try:
        webview.create_window("ragha", URL, width=1040, height=740, min_size=(600, 480))
        webview.start()   # roda no main thread; bloqueia ate fechar a janela
    finally:
        if proc:
            proc.terminate()


if __name__ == "__main__":
    main()
