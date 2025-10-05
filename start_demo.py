#!/usr/bin/env python3
import http.server
import socketserver
import webbrowser
import os
import threading
import time

class CORSRequestHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        super().end_headers()

def start_demo_server():
    PORT = 8080
    
    # Change to the directory containing demo.html
    os.chdir('/Users/johnaderounmu/Git/care_hr_frontend')
    
    # Try to start server
    for port in range(8080, 8090):
        try:
            with socketserver.TCPServer(("", port), CORSRequestHandler) as httpd:
                print(f"🚀 Care HR Demo Server starting on http://localhost:{port}")
                print(f"📁 Serving from: {os.getcwd()}")
                print(f"🌐 Demo page: http://localhost:{port}/demo.html")
                print("")
                print("✅ Demo server ready!")
                print("🔗 Opening demo in browser...")
                
                # Open browser after a short delay
                def open_browser():
                    time.sleep(2)
                    webbrowser.open(f'http://localhost:{port}/demo.html')
                
                browser_thread = threading.Thread(target=open_browser)
                browser_thread.daemon = True
                browser_thread.start()
                
                print(f"⏹️  Press Ctrl+C to stop the server")
                httpd.serve_forever()
                
        except OSError as e:
            if e.errno == 48:  # Address already in use
                print(f"⚠️  Port {port} in use, trying {port + 1}...")
                continue
            else:
                print(f"❌ Error starting server: {e}")
                break
    else:
        print("❌ Could not find an available port")

if __name__ == "__main__":
    try:
        start_demo_server()
    except KeyboardInterrupt:
        print("\n🛑 Demo server stopped")
        print("👋 Thanks for trying the Care HR demo!")