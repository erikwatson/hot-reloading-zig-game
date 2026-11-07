
#!/usr/bin/env bash

echo "Building and launching game..."

if ! zig build; then
    echo "Initial build failed."
    exit 1
fi

./zig-out/bin/arena &
GAME_PID=$!

cleanup() {
    kill "$GAME_PID" 2>/dev/null || true
    wait "$GAME_PID" 2>/dev/null || true
}

trap cleanup EXIT INT TERM

echo "Watching for source changes..."

while true; do
    if ! kill -0 "$GAME_PID" 2>/dev/null; then
        wait "$GAME_PID" 2>/dev/null || true
        echo "Game exited. Stopping watcher."
        break
    fi

    if IFS= read -r -t 1 file; then
        if [[ "$file" == *.zig ]]; then
            echo "Change detected: $file"

            if zig build; then
                echo "Build successful."
            else
                echo "Build failed. Waiting for the next change..."
            fi
        fi
    fi
done < <(inotifywait -m -r -e close_write,create,delete,move \
    --format '%w%f' src)

