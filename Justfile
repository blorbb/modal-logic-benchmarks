set default-list

# Initialise submodules
init:
    git submodule update --init --recursive --no-fetch --depth 1

# Update a submodule to the latest remote
update-submodule dir:
    git submodule update --remote '{{ dir }}'

# Build docker image
build:
    docker buildx build -t benchmarks .

# Run docker container using existing build
run-nobuild *args:
    # Note: --init required to reap zombie processes that might be
    # spawned from shell scripts after killing a solver due to TLE.
    docker run --init -t -v "$(pwd)/lwb-instances:/run/temp_target" --ulimit stack=134217728:134217728 benchmarks python bench.py {{ args }}

# Build and run docker container
run *args: build (run-nobuild args)

# Extract a binary from an existing build
extract bin:
    docker create --name tmp benchmarks
    @docker cp 'tmp:/run/{{ bin }}' . \
        || (echo 'Available binaries:' \
              && docker run benchmarks find /run -maxdepth 1 -type f -executable -printf '%f ' \
              && echo)
    docker rm tmp

# Apply a patch locally
apply-patch dir:
    cd '{{ dir }}' && git apply "../$(basename '{{ dir }}').patch"

# Update a directory's patch file and remove local edits.
update-patch dir:
    cd '{{ dir }}' \
        && git add --intent-to-add . \
        && git diff > "../$(basename '{{ dir }}').patch" \
        && git reset --hard
