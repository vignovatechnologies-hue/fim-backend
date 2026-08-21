import os
import sys
import signal
import uvicorn

def handle_shutdown(sig, frame):
    print("\n🛑 Shutting down FIM Backend Server...", flush=True)
    os._exit(0)

if __name__ == "__main__":
    # Register immediate OS signal handlers for Ctrl + C
    signal.signal(signal.SIGINT, handle_shutdown)
    signal.signal(signal.SIGTERM, handle_shutdown)

    print("=" * 60, flush=True)
    print("🚀 FIM Backend Server Started Successfully!", flush=True)
    print("📡 Base URL:           http://127.0.0.1:8000", flush=True)
    print("📖 API Documentation:  http://127.0.0.1:8000/docs", flush=True)
    print("✨ Status:             Ready and listening for requests...", flush=True)
    print("🛑 To Stop:            Press Ctrl + C", flush=True)
    print("=" * 60, flush=True)

    try:
        uvicorn.run(
            "main:app",
            host="0.0.0.0",
            port=8000,
            reload=False,
            log_level="info"
        )
    except KeyboardInterrupt:
        print("\n🛑 FIM Server stopped.", flush=True)
        os._exit(0)
