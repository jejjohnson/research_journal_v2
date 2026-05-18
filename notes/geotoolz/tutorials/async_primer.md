---
title: "Async Python — a pedagogical primer"
subject: geotoolz tutorial
short_title: "Async primer"
authors:
  - name: J. Emmanuel Johnson
    affiliations:
      - UNEP
      - IMEO
      - MARS
    orcid: 0000-0002-6739-0053
    email: jemanjohnson34@gmail.com
license: CC-BY-4.0
keywords: tutorial, async, asyncio, Python, concurrency, rustac
---

# Async Python: A Pedagogical Primer

*From restaurant analogies to satellite pipelines. Covers `async`, `await`, `gather`, `TaskGroup`, semaphores, and the geoscience-shaped problems they solve.*

-----

# Part 1 — ELI5: What problem does async solve?

## The coffee shop analogy

Picture two coffee shops, both with one barista, both serving the same line of 10 customers.

**Shop A — synchronous.**
The barista takes Customer 1’s order: “latte.” They grind beans, pull the espresso shot, steam the milk, pour, hand over the drink. *Then* they call Customer 2. Repeat 10 times. Each drink takes 3 minutes; total time is 30 minutes. The barista is busy the whole time, but here’s the thing — during the 90 seconds the espresso machine is pulling the shot and the steamer is heating the milk, the barista is *just standing there watching the machines work*.

**Shop B — asynchronous.**
The barista takes Customer 1’s order, *starts* the espresso machine, and while it’s pulling the shot, takes Customer 2’s order and starts their espresso too. While both espressos are pulling, they start steaming milk for Customer 1. When Customer 1’s drink is assembled, they hand it over and start working on Customer 3’s espresso. The barista bounces between tasks, never standing idle while machines work. Total time for 10 drinks: maybe 12 minutes.

**That’s async.** It’s not more baristas. It’s not faster machines. It’s *one worker who doesn’t waste time staring at machines while they run*. Each task has moments of “active work” (taking orders, assembling drinks) and “waiting” (espresso pulling, milk steaming). Async overlaps the waiting periods so the active worker is never idle.

The key insight: **async only helps when there’s waiting**. If every task were “manually grind 200g of beans by hand” — pure work, no waiting — async wouldn’t help. The barista can’t grind two bags at once with one pair of hands. Async pays off precisely when the work involves waiting on something external: machines, networks, databases, file systems.

## Why this maps to satellite pipelines

Almost everything in a remote sensing pipeline involves waiting on external systems:

- HTTP request to a STAC API → wait for server to query its database → wait for the network → response arrives.
- S3 GET for a Sentinel-2 tile → wait for AWS to find the object → wait for bytes to traverse the network.
- Database query → wait for PostgreSQL to plan, execute, and return rows.
- Reading a NetCDF file from a slow disk → wait for the disk head to seek and read.

A synchronous Python script doing 100 STAC API calls is the barista in Shop A — making one request, sitting idle for 200 ms while the network does its job, then making the next request. 100 requests × 200 ms = 20 seconds of mostly-idle waiting.

The async version starts all 100 requests near-simultaneously, lets them all wait in parallel, and processes responses as they arrive. Total time: roughly the time of the slowest single request, maybe 500 ms. **40× faster, same CPU, same memory, just no idle waiting.**

## The crucial distinction: concurrency vs parallelism

These words get used interchangeably and they shouldn’t be.

**Parallelism** is “two workers literally doing two things at the same moment.” Two CPU cores running two threads. Two GPUs training two models. Genuine simultaneous execution.

**Concurrency** is “one worker juggling multiple tasks by switching between them.” The barista in Shop B is concurrent, not parallel — there’s still only one of them.

Async Python is **concurrency without parallelism**. One thread, one CPU core, one Python interpreter. It just stops blocking on I/O. For network-bound work this is exactly the right tool. For CPU-bound work (matrix multiplication, FFTs, neural network training) it does nothing — you need parallelism, which means threads, processes, or GPUs.

A clean mental rule:

- **Async** for I/O-bound work (network, disk, database).
- **Threads** for I/O-bound work when you can’t use async (legacy libraries).
- **Processes / multiprocessing** for CPU-bound work in pure Python.
- **NumPy / JAX / PyTorch** for CPU-bound work where you can vectorize or hit a GPU.

Mixing these is fine — most production pipelines have an async outer loop fetching data and a JAX/NumPy inner loop crunching it.

-----

# Part 2 — The mental model

## Coroutines, the event loop, and the analogy of a chess simultan

Imagine a chess grandmaster playing a “simultaneous exhibition” — 30 boards arranged in a circle, 30 opponents waiting. The grandmaster walks from board to board, making one move at each, then moving on. By the time they’ve gone around the circle and returned to Board 1, that opponent has had time to think and is ready with their move.

The grandmaster is the **event loop**. Each board is a **coroutine** — a paused game waiting for its turn. The grandmaster never blocks on one game; they make a move, move on, come back when there’s something to do.

A coroutine is just a function that can be *paused* and *resumed*. When you write:

```python
async def fetch_one(url):
    response = await httpx.get(url)
    return response.json()
```

Calling `fetch_one("https://...")` doesn’t run the function. It returns a **coroutine object** — a paused computation that hasn’t started yet. To actually run it, you hand it to the event loop. The loop then walks through it until it hits the first `await`, pauses it there (the network request is pending), and goes to do other work. When the response arrives, the loop comes back to this coroutine and resumes it from where it paused.

```
EVENT LOOP                          COROUTINES (paused functions)

┌──────────────────┐               ┌─────────────────┐
│                  │ ───advance──▶ │ fetch_one(url1) │
│   loop.run()     │               │  → await httpx  │  (paused on network)
│                  │ ◀──pause───── │                 │
│                  │               └─────────────────┘
│   pick next      │
│   ready task     │               ┌─────────────────┐
│                  │ ───advance──▶ │ fetch_one(url2) │
│                  │               │  → await httpx  │  (paused on network)
│                  │ ◀──pause───── │                 │
│                  │               └─────────────────┘
│                  │
│   when network   │               ┌─────────────────┐
│   responds for   │ ───resume───▶ │ fetch_one(url1) │
│   url1, resume   │               │  → return data  │
│                  │ ◀──complete── │                 │
│                  │               └─────────────────┘
└──────────────────┘
```

The grandmaster makes a move, walks to the next board, comes back when something has changed. The loop advances a coroutine until it hits an `await`, parks it, and moves on. Nothing is *simultaneous* — there’s still one chess player and one event loop. But because nobody waits idly, throughput is high.

## The three keywords you need

**`async def`** — defines a coroutine function. Calling it returns a coroutine object; it doesn’t execute.

**`await`** — inside a coroutine, suspends execution until the awaited thing finishes, letting the event loop work on other coroutines in the meantime.

**`asyncio.run(coro)`** — top-level entry point. Starts an event loop, runs the coroutine, tears the loop down.

Minimal example:

```python
import asyncio

async def say_hi(name, delay):
    await asyncio.sleep(delay)        # this is the "wait" — non-blocking
    print(f"hi {name}")

async def main():
    await say_hi("Alice", 1)
    await say_hi("Bob", 1)
    # Total: 2 seconds. We awaited sequentially.

asyncio.run(main())
```

This is *async without concurrency* — we wrote async syntax but didn’t use it concurrently. Same effect as synchronous code, just clunkier. The payoff comes when we run things concurrently:

```python
async def main():
    await asyncio.gather(
        say_hi("Alice", 1),
        say_hi("Bob", 1),
    )
    # Total: 1 second. Both ran concurrently.
```

That’s the whole game. `gather` (and its modern replacement `TaskGroup`, covered below) starts multiple coroutines at once and waits for them all to finish. If they were going to spend their time waiting on I/O anyway, they wait in parallel rather than in sequence.

## Why is `await` needed at all?

This trips people up: “if the loop knows when a coroutine should pause, why do *I* have to write `await`?”

The answer is that the loop *doesn’t* know. It can’t tell from outside the function whether `httpx.get(url)` is going to do network I/O (and should yield) or just return a cached value instantly (and shouldn’t yield). The `await` keyword is *you, the programmer*, telling the loop “this is a yieldable point — pause here if needed.”

This explicit-yield-point design is the reason Python’s async is called **cooperative concurrency**. Each coroutine cooperates with the loop by marking its yield points. Compare to threads, where the OS can preempt your code anywhere it likes — that’s *preemptive* concurrency, and it’s harder to reason about because every line of code is a potential interruption.

The trade-off: async code is easier to reason about (yield points are visible), but if you forget to `await` something or call a blocking function inside an async context, the whole loop stalls. **One badly-behaved coroutine that does CPU work without yielding will freeze every other coroutine.** This is the “don’t block the event loop” rule, and it’s the single biggest async footgun.

-----

# Part 3 — The technical detail, pedantically

## Coroutines under the hood

Python coroutines are built on **generators**. Before `async def` existed, you could write:

```python
def fake_coroutine():
    print("first")
    yield 1
    print("second")
    yield 2
    print("third")
```

This function pauses at each `yield`, returns control to the caller, and resumes from there next time. That’s a coroutine in the loose sense. Python’s `async def` is essentially this mechanism with prettier syntax and stricter rules.

When you write `await something`, the interpreter is doing roughly: “call `something.__await__()`, which returns an iterator; yield from that iterator until it stops; the final value becomes the result of the `await` expression.” The event loop drives this iteration. The pause-resume mechanism is generator-based all the way down.

You don’t need to know this to use async, but understanding “coroutines are pause-able functions” makes the rest click.

## What can be `await`-ed

Three things:

1. **Coroutine objects** — what `async def foo()` returns when called.
2. **Tasks** — coroutines wrapped by `asyncio.create_task()` or `asyncio.gather()`, which schedules them on the loop immediately.
3. **Futures** — lower-level “this value will exist eventually” objects. Rare in user code; mostly used internally.

The umbrella term is **awaitable**. Any object implementing `__await__` is awaitable. In practice, you mostly work with coroutines and tasks.

## Coroutines vs Tasks

This is the most common confusion in async Python, and worth being precise about.

A **coroutine** is a paused function. Calling `async def foo(): ...` followed by `c = foo()` gives you a coroutine that *hasn’t started yet*. It’s inert until something drives it. If you forget to `await` it or schedule it, Python warns: “coroutine ‘foo’ was never awaited.”

A **Task** is a coroutine that’s been *scheduled on the loop* — it’s actively running (or paused mid-execution), and the loop is responsible for advancing it. `asyncio.create_task(foo())` takes a coroutine and turns it into a Task that starts running immediately.

```python
# Coroutine — paused, not running
c = fetch_one("https://...")           # nothing happens yet

# Task — running on the loop
t = asyncio.create_task(fetch_one("..."))  # already started, runs concurrently

# To get the result of either:
result_c = await c     # drives the coroutine to completion now
result_t = await t     # waits for the task to finish (it may already be done)
```

The practical rule: if you want *concurrent* execution of multiple coroutines, wrap them in Tasks (via `create_task`, `gather`, or `TaskGroup`). If you await coroutines sequentially, they run sequentially.

## The event loop, more precisely

The event loop is a roughly 200-line piece of state in CPython, but conceptually it’s just:

```
while there are tasks to run:
    run all ready tasks until they hit an `await` or finish
    ask the OS: "any of my I/O operations completed?"  # epoll / kqueue
    for each completed I/O: mark the waiting task as ready
    repeat
```

The OS-level mechanism is `epoll` on Linux, `kqueue` on macOS/BSD, IOCP on Windows. These are kernel facilities that let a single thread register interest in thousands of file descriptors and ask “which ones have data ready?” in one call. That’s the scalability secret: one OS call can monitor 10,000 sockets at once, so one Python thread can manage 10,000 concurrent network operations.

Python’s `asyncio` is one event loop implementation. There are others — `uvloop` is a faster drop-in replacement built on libuv (the same library that powers Node.js); `trio` is an alternative ecosystem with different design choices around cancellation; `anyio` is a compatibility layer that runs on top of either asyncio or trio. Most code targets `asyncio` and works fine.

## Blocking vs non-blocking calls

The event loop assumes coroutines yield quickly. If a coroutine does CPU-bound work or calls a *blocking* function (one that doesn’t yield), the whole loop stops.

**Non-blocking** — yields to the loop while waiting. `await asyncio.sleep(1)`, `await httpx_client.get(url)`, `await aiofiles.open(...)`. Async-aware libraries.

**Blocking** — does not yield. `time.sleep(1)`, `requests.get(url)`, `open(...).read()` for large files, NumPy operations, pure Python loops over big data.

```python
async def bad():
    time.sleep(5)        # BLOCKS the entire loop for 5 seconds
    return "done"

async def good():
    await asyncio.sleep(5)   # Yields to the loop; other tasks run
    return "done"
```

The single most common async bug is calling a sync HTTP library (`requests`, `urllib`) inside an async function. It “works” — the code runs — but it defeats the entire point of async, because every call blocks the loop. Use `httpx` (with `AsyncClient`), `aiohttp`, or similar async-native libraries.

If you *must* call blocking code inside an async function (a legacy library, a slow file read), wrap it in `asyncio.to_thread()`:

```python
async def call_blocking():
    result = await asyncio.to_thread(some_blocking_function, arg1, arg2)
    return result
```

This runs the blocking function on a thread pool, letting the event loop continue serving other coroutines. It costs you the overhead of a thread, but it keeps the loop responsive.

-----

# Part 4 — Running things concurrently

`async def` is just syntax — it doesn’t make anything concurrent on its own. Concurrency comes from how you schedule coroutines on the loop. There are four main primitives.

## 4a. `asyncio.gather` — the classic

```python
import asyncio
import httpx

async def fetch(client, url):
    r = await client.get(url)
    return r.json()

async def main():
    urls = [
        "https://earth-search.aws.element84.com/v1/collections/sentinel-2-l2a",
        "https://earth-search.aws.element84.com/v1/collections/sentinel-1-grd",
        "https://earth-search.aws.element84.com/v1/collections/landsat-c2-l2",
    ]
    async with httpx.AsyncClient() as client:
        results = await asyncio.gather(*(fetch(client, u) for u in urls))
    return results
```

`gather` takes any number of awaitables, starts them all concurrently, and returns a list of their results in the order you passed them in. If any of them raises, by default the exception propagates and the other tasks keep running in the background (which is sometimes wrong — see TaskGroup below).

```python
# With error handling
results = await asyncio.gather(*tasks, return_exceptions=True)
# Now `results` is a mixed list of values and Exception objects.
```

This is the workhorse for “fan out N requests, collect all results.”

## 4b. `asyncio.TaskGroup` — the modern recommended way (Python 3.11+)

`gather` has subtle issues with error handling and cancellation. `TaskGroup` (added in 3.11) fixes them by tying tasks to a structured scope:

```python
async def main():
    async with asyncio.TaskGroup() as tg:
        task1 = tg.create_task(fetch(client, url1))
        task2 = tg.create_task(fetch(client, url2))
        task3 = tg.create_task(fetch(client, url3))
    # By the time we exit the `async with`, all tasks have completed.
    # If any failed, all the others are cancelled automatically.
    results = [task1.result(), task2.result(), task3.result()]
```

The guarantee is **structured concurrency**: tasks created inside the block can’t outlive the block. If one task fails, the others are cancelled. No orphaned tasks running in the background after you’ve moved on. This is what `trio` pioneered, and what Python’s asyncio adopted in 3.11.

**Prefer TaskGroup for new code.** Use `gather` only when you specifically need the old “fire-and-forget on exception” semantics, which is rare.

## 4c. `asyncio.create_task` — for fire-and-forget or manual control

When you want to start a coroutine running *now* but not necessarily wait for it immediately:

```python
async def main():
    background = asyncio.create_task(slow_logging_function())
    # Do other work...
    result = await important_work()
    # Eventually await the background task before exiting
    await background
    return result
```

Useful for kicking off concurrent work that you’ll collect later, or for tasks you genuinely want to run in the background (logging, metrics, cache warming).

## 4d. `asyncio.as_completed` — process results in finish order

Sometimes you want to handle results as they arrive, not in submission order:

```python
async def main():
    tasks = [fetch(client, url) for url in urls]
    for coro in asyncio.as_completed(tasks):
        result = await coro
        print(f"got: {result}")     # printed in completion order
```

Useful when later results depend on earlier results being processed, or when you want to display progress incrementally.

## 4e. Semaphores — limit concurrency

Concurrency is great until you hit the receiving server’s rate limit and get banned. **Semaphores** bound how many tasks can run a given operation at the same time:

```python
async def fetch_one(client, sem, url):
    async with sem:
        return await client.get(url)

async def main():
    sem = asyncio.Semaphore(10)        # at most 10 in flight at a time
    async with httpx.AsyncClient() as client:
        results = await asyncio.gather(
            *(fetch_one(client, sem, u) for u in urls)
        )
```

The `async with sem` block holds one of the semaphore’s permits. If 10 tasks already hold permits, the 11th task waits until one releases. This bounds concurrency without serializing — usually the right setting for a STAC API is 5–20, depending on the provider’s documented rate limits.

This is one of the most important async patterns for geoscience work. Naively running `gather` over 10,000 URLs will get you instantly rate-limited or DDoS-detected; with a semaphore of 10, the same operation takes longer but actually completes.

## 4f. `asyncio.wait_for` — timeouts

```python
try:
    result = await asyncio.wait_for(fetch(url), timeout=5.0)
except asyncio.TimeoutError:
    print("took too long, moving on")
```

Wraps any awaitable with a deadline. If it doesn’t finish in time, the awaitable is cancelled and `TimeoutError` is raised. Use this for any network call against a flaky endpoint — without it, a dead connection can hang a coroutine forever.

In Python 3.11+, `asyncio.timeout()` is the cleaner alternative:

```python
async with asyncio.timeout(5.0):
    result = await fetch(url)
```

-----

# Part 5 — Diagramming what actually happens

## Sequential awaits

```python
async def main():
    a = await fetch(url1)   # 200 ms
    b = await fetch(url2)   # 200 ms
    c = await fetch(url3)   # 200 ms
    return a, b, c
# Total: ~600 ms
```

Timeline:

```
T=0     T=200    T=400    T=600
│       │        │        │
│fetch1 │        │        │
│ ━━━━━▶│        │        │
│       │fetch2  │        │
│       │ ━━━━━▶│         │
│       │       │fetch3   │
│       │       │ ━━━━━▶ │
│       │       │        │
```

Each fetch starts only after the previous completes.

## Concurrent execution via `gather`

```python
async def main():
    a, b, c = await asyncio.gather(
        fetch(url1),
        fetch(url2),
        fetch(url3),
    )
    return a, b, c
# Total: ~200 ms (the slowest)
```

Timeline:

```
T=0                       T=200
│                          │
│fetch1 ━━━━━━━━━━━━━━━━━━▶│
│fetch2 ━━━━━━━━━━━━━━━━━━▶│
│fetch3 ━━━━━━━━━━━━━━━━━━▶│
│                          │
```

All three fetches are in flight simultaneously. The event loop is the same single thread, but the OS handles all three network sockets concurrently and notifies the loop as each finishes.

## Bounded concurrency with a semaphore

```python
sem = asyncio.Semaphore(2)   # only 2 at a time

async def fetch_bounded(url):
    async with sem:
        return await fetch(url)

await asyncio.gather(*(fetch_bounded(u) for u in [u1, u2, u3, u4, u5]))
```

Timeline:

```
T=0        T=200      T=400      T=600
│          │          │          │
│fetch1 ━━▶│          │          │
│fetch2 ━━▶│          │          │
│          │fetch3 ━━▶│          │
│          │fetch4 ━━▶│          │
│          │          │fetch5 ━━▶│
│          │          │          │
```

Two slots; new fetches start only when an old one finishes. Total time scales as `ceil(N / concurrency) × per_request_time`.

## The blocking footgun

```python
async def main():
    await asyncio.gather(
        fetch(url1),
        bad_blocking_call(),    # contains time.sleep(2) instead of await asyncio.sleep(2)
        fetch(url2),
    )
```

Timeline:

```
T=0     T=200          T=2000   T=2200
│       │              │        │
│fetch1 │              │        │   ← fetch1 actually does respond at T=200
│ ━━━━━▶│              │        │      but the loop can't acknowledge it
│       │              │        │      because bad_blocking_call hasn't yielded
│ bad ━━━━━━━━━━━━━━━━▶│        │
│                      │ fetch2 │
│                      │ ━━━━━▶│
```

The blocking call hijacks the loop. `fetch1` finished at T=200 but its response can’t be processed until T=2000 when the blocking call releases. `fetch2` doesn’t even start until T=2000. Everything is serialized through the blocking call. This is the kind of bug that makes async code mysteriously “not faster than sync” — and it’s almost always a sneaky synchronous library call.

-----

# Part 6 — The async ecosystem in Python

## Async-native libraries you’ll meet

For geoscience and infrastructure work, the relevant ones:

|Domain            |Async library                                               |Replaces                     |
|------------------|------------------------------------------------------------|-----------------------------|
|HTTP client       |`httpx` (with `AsyncClient`), `aiohttp`                     |`requests`                   |
|Files             |`aiofiles`                                                  |`open()`                     |
|Object stores     |`obstore`, `aiobotocore`, `aioboto3`                        |`boto3`, `requests`          |
|Postgres          |`asyncpg`, `psycopg` (3.x async mode), `sqlalchemy[asyncio]`|`psycopg2`, sync SQLAlchemy  |
|Redis             |`redis.asyncio`                                             |`redis-py` (sync)            |
|MongoDB           |`motor`                                                     |`pymongo`                    |
|Kafka             |`aiokafka`                                                  |`kafka-python`               |
|STAC              |`rustac`, `pystac-client` (limited async)                   |`pystac-client` sync         |
|Web frameworks    |`FastAPI`, `Starlette`, `Quart`                             |`Flask`, `Django` (sync mode)|
|Task orchestration|`Prefect 2+`, `Dagster`, `Temporal`                         |Celery (sync)                |

The key rule: **inside an async function, everything that does I/O must be async-aware**, or you fall into the blocking footgun.

## `anyio` and trio compatibility

There’s a parallel async ecosystem called **trio** with cleaner semantics around cancellation, designed by Nathaniel Smith partly in response to perceived weaknesses in asyncio. It never overtook asyncio in adoption, but it influenced asyncio’s evolution (TaskGroup is essentially trio’s nursery pattern).

`anyio` is a compatibility layer that lets you write async code that runs on either asyncio or trio. Many libraries (httpx, FastAPI internals) use anyio so they work in both ecosystems. For your purposes: write asyncio code, ignore trio unless you have a specific reason.

## When asyncio falls short

Asyncio is great for I/O concurrency. It’s not great for:

- **CPU-bound work.** Use `concurrent.futures.ProcessPoolExecutor` or just don’t be in async land for that step.
- **Truly parallel I/O on filesystems.** Disk I/O is harder to make async than network I/O on Linux. `aiofiles` uses threads under the hood. For high-throughput disk reads, threads or processes are often simpler.
- **Mixing sync and async code carelessly.** A sync function that calls `asyncio.run` inside it creates a fresh loop and tears it down each call — expensive and broken in subtle ways. Pick a paradigm per module.

-----

# Part 7 — Geoscience use cases

This is where the abstract pays off. Real patterns from real pipelines.

## 7a. Fan-out STAC search across multiple catalogs

You need scenes from EMIT (NASA), Sentinel-2 (Earth Search), and EnMAP (DLR) over the same AOI for a methane fusion study. Sync version takes 6 seconds (3 catalogs × 2 sec each). Async version takes 2.

```python
import asyncio
import rustac

async def search_all(bbox, datetime):
    return await asyncio.gather(
        rustac.search(
            "https://cmr.earthdata.nasa.gov/stac/LPCLOUD",
            collections="EMITL2BCH4ENH.v002",
            bbox=bbox, datetime=datetime, max_items=500,
        ),
        rustac.search(
            "https://earth-search.aws.element84.com/v1",
            collections="sentinel-2-l2a",
            bbox=bbox, datetime=datetime, max_items=500,
        ),
        rustac.search(
            "https://geoservice.dlr.de/eoc/ogc/stac/v1",
            collections="ENMAP_HSI_L2A",
            bbox=bbox, datetime=datetime, max_items=100,
        ),
    )

emit, s2, enmap = asyncio.run(search_all(
    bbox=[-105.0, 31.0, -103.0, 33.0],   # Permian basin
    datetime="2024-01-01/2024-12-31",
))
```

The three searches run concurrently. Total time = the slowest single search.

## 7b. Bounded-concurrency tile download

You have 10,000 Sentinel-2 tiles to download to local disk for training. Without bounding concurrency, the S3 endpoint may throttle or your process runs out of memory. With a semaphore of 32:

```python
import asyncio
import obstore
from obstore.store import S3Store

async def download_one(store, key, out_path, sem):
    async with sem:
        data = await obstore.get_async(store, key)
        async with aiofiles.open(out_path, "wb") as f:
            await f.write(data.bytes())

async def download_all(keys):
    store = S3Store(bucket="sentinel-cogs", region="us-west-2", skip_signature=True)
    sem = asyncio.Semaphore(32)
    async with asyncio.TaskGroup() as tg:
        for key in keys:
            out = f"/data/tiles/{key.replace('/', '_')}"
            tg.create_task(download_one(store, key, out, sem))

asyncio.run(download_all(s2_keys))
```

32 concurrent downloads, structured task group, automatic cancellation on error. Replace 10,000 sequential 2-second downloads (5.5 hours) with bounded-concurrent downloads (~10 minutes on a fat pipe).

## 7c. Async object store for distributed JAX training

In a methane retrieval training loop, each batch needs ~16 EMIT scenes. Reading them sequentially per batch is the bottleneck. Prefetching the next batch while training on the current one (a classic ML pattern) maps cleanly to async:

```python
import asyncio
from collections import deque

async def fetch_scene(store, item):
    href = item.assets["radiance"].href
    key = href.split("lp-prod-protected/")[-1]
    data = await obstore.get_async(store, key)
    return decode_emit_scene(data.bytes())

async def prefetch_loop(items, store, queue, batch_size=16):
    for i in range(0, len(items), batch_size):
        batch = items[i:i + batch_size]
        scenes = await asyncio.gather(*(fetch_scene(store, it) for it in batch))
        await queue.put(scenes)
    await queue.put(None)   # sentinel for end-of-data

async def train(queue, model, optimizer):
    while True:
        scenes = await queue.get()
        if scenes is None:
            break
        loss = model_step(model, optimizer, scenes)   # JAX call, blocks the loop
        # In practice: run JAX step in a thread to keep the loop responsive
        # or just accept that the loop blocks during training step.

async def main(items, model, optimizer):
    store = S3Store(...)
    queue = asyncio.Queue(maxsize=2)   # backpressure
    async with asyncio.TaskGroup() as tg:
        tg.create_task(prefetch_loop(items, store, queue))
        tg.create_task(train(queue, model, optimizer))
```

The prefetcher fetches batch N+1 from S3 while the trainer is computing on batch N. JAX is busy on the GPU; the event loop is busy fetching bytes. Different work on different resources, overlapped.

(Caveat: real ML pipelines usually use PyTorch DataLoader / `tf.data` / `grain` for this, which use threads or processes under the hood. The async version above is more illustrative than recommended for production training. But for *inference* pipelines without GPU pressure, this pattern is very practical.)

## 7d. Parallel time-series fetch for a study site

You need TROPOMI methane time series for 200 power plants, querying a STAC API for each:

```python
async def fetch_site(client, sem, site, start, end):
    async with sem:
        search = await rustac.search(
            "https://data-portal.s5p-pal.com/api/stac",
            collections=["PAL_S5P_L2__CH4____HiR"],
            intersects=site.geometry,
            datetime=f"{start}/{end}",
            max_items=500,
        )
        return site.id, search

async def fetch_all_sites(sites, start, end):
    sem = asyncio.Semaphore(8)
    results = await asyncio.gather(
        *(fetch_site(None, sem, s, start, end) for s in sites)
    )
    return dict(results)
```

200 sites × 1.5 sec/query sequential = 5 minutes. With 8-way concurrency, ~40 seconds.

## 7e. Streaming COG byte-range reads

A Cloud-Optimized GeoTIFF lets you read just the tiles you need via HTTP range requests. Reading 100 small tiles from 100 different COGs is naturally async:

```python
async def read_tile(store, item, tile_bounds):
    # Compute byte offset from COG header (rasterio can do this)
    offset, length = compute_byte_range(item, tile_bounds)
    data = await obstore.get_range_async(
        store, item.assets["red"].href, offset, length
    )
    return decode_tile(data.bytes())

async def read_all_tiles(items, tile_bounds):
    store = S3Store(bucket="sentinel-cogs", region="us-west-2", skip_signature=True)
    sem = asyncio.Semaphore(50)
    async def bounded(item):
        async with sem:
            return await read_tile(store, item, tile_bounds)
    return await asyncio.gather(*(bounded(it) for it in items))
```

For chip-based ML training where each sample is a small patch from a big COG, this pattern saturates the network without saturating memory.

## 7f. The Jupyter case

Async in a Jupyter cell is special: the loop is already running, so you don’t call `asyncio.run`. You just `await`:

```python
# In a Jupyter cell (works as-is, no asyncio.run)
items = await rustac.search(
    "https://earth-search.aws.element84.com/v1",
    collections="sentinel-2-l2a",
    bbox=[-122.5, 37.5, -122.0, 38.0],
    datetime="2024-06-01/2024-06-30",
)
```

Underneath, Jupyter is using `IPython`’s async support (which uses `asyncio` with some careful patching). Most async-aware libraries Just Work in Jupyter cells without ceremony.

If you’re inside a `.py` script, you need a top-level `asyncio.run(main())`.

-----

# Part 8 — Common gotchas

**1. Forgetting `await`.** `result = fetch(url)` (without `await`) returns a coroutine, not a value. Python warns but doesn’t error. Confusing.

**2. Using a sync library inside async.** `requests.get` inside an async function blocks the loop. Use `httpx.AsyncClient`.

**3. Calling `asyncio.run` twice.** Each call creates and tears down a fresh loop. Repeatedly doing this in a script is wasteful and breaks any state that wanted to persist across calls (HTTP connection pools, etc.).

**4. Nested `asyncio.run`.** You can’t call `asyncio.run` from inside an already-running event loop. In Jupyter or FastAPI handlers, just use `await` directly.

**5. Forgetting to `await` a Task.** `asyncio.create_task(foo())` schedules it, but if your function exits before the task completes, you may get “Task was destroyed but it is pending” warnings. Use TaskGroup or explicitly await the task.

**6. Unbounded concurrency.** `gather` with 10,000 awaitables is technically valid but will overwhelm servers, exhaust file descriptors, and OOM your machine. Always use semaphores for fan-out.

**7. Exception handling differences.** In `gather`, exceptions in one task don’t cancel others by default. In TaskGroup, they do. Pick the right tool for your error semantics.

**8. CPU-bound async.** Async does *nothing* for CPU-bound work. A `for i in range(10**9)` loop inside an async function blocks the loop just like a sync one. Wrap CPU work in `asyncio.to_thread` or just don’t put it in async land.

**9. Mixing sync and async session/client objects.** `httpx.Client` (sync) and `httpx.AsyncClient` (async) are different classes. The sync one in an async function blocks. Triple-check imports.

**10. Async generators are different from async functions.** `async def gen(): yield x` is an async generator (use `async for` to iterate). `async def func(): return x` is a coroutine (use `await`). The syntax is similar; the semantics aren’t.

**11. Cancellation is cooperative.** `task.cancel()` raises `CancelledError` inside the task at the next `await`. If the task is doing pure CPU work without yielding, cancel doesn’t take effect until it yields. Long-running CPU work inside async tasks is impossible to interrupt cleanly.

**12. The “warning, coroutine was never awaited” message.** This always means you wrote `foo()` instead of `await foo()` somewhere. Hunt it down — coroutines that never run are silent bugs.

-----

# Part 9 — Where async fits in the GeoStack

```
                         ┌──────────────────────────────────────────┐
                         │              SCIENCE / ML LAYER          │
                         │   JAX, PyTorch — CPU/GPU-bound           │
                         │   ── async is irrelevant here ──         │
                         └──────────────────▲───────────────────────┘
                                            │
                         ┌──────────────────┴───────────────────────┐
                         │            ARRAY / LABELED-ARRAY         │
                         │   xarray, dask — mostly sync             │
                         │   (dask has its own scheduler)           │
                         └──────────────────▲───────────────────────┘
                                            │
                         ┌──────────────────┴───────────────────────┐
                         │              RASTER I/O                  │
                         │   rasterio (GDAL) — sync, threadable     │
                         │   zarr (with async stores) — partial     │
                         └──────────────────▲───────────────────────┘
                                            │
                         ┌──────────────────┴───────────────────────┐
                         │           OBJECT-STORE LAYER             │
                         │   obstore, aiobotocore — ★ ASYNC ★       │
                         │   fsspec — sync API, async under hood    │
                         └──────────────────▲───────────────────────┘
                                            │
                         ┌──────────────────┴───────────────────────┐
                         │           CATALOG LAYER                  │
                         │   rustac — ★ ASYNC ★                     │
                         │   pystac-client — sync                   │
                         └──────────────────▲───────────────────────┘
                                            │
                         ┌──────────────────┴───────────────────────┐
                         │            REST API / NETWORK            │
                         │   httpx (async), aiohttp — ★ ASYNC ★     │
                         │   requests — sync                        │
                         └──────────────────────────────────────────┘
```

The bottom three layers (network, catalog, object store) are where async pays off. Everything above is CPU- or memory-bound and gets nothing from async.

The practical structure of a modern Earth science pipeline:

1. **Async outer loop** does network I/O — STAC searches, object store reads, database queries.
2. **Sync inner kernel** does the math — JAX/PyTorch on GPU, NumPy/xarray on CPU.
3. **Bridge between them** is `asyncio.to_thread` (push sync work off the loop) or just structured staging (async fills a queue; sync workers drain it).

For `plumax` specifically: the data loading is naturally async (fetching EMIT scenes from S3, fetching ancillary atmospheric data from PC, fetching site metadata from MARS PostgreSQL). The retrieval algorithm itself is JAX and synchronous. Wrap the data loading in an async prefetch loop, hand decoded scenes to the JAX kernel via a queue, and you’ve used async exactly where it pays.

-----

# Part 10 — Quick reference

|What you want                              |What to write                                                              |
|-------------------------------------------|---------------------------------------------------------------------------|
|Define a coroutine                         |`async def foo(): ...`                                                     |
|Run a coroutine from sync code             |`asyncio.run(foo())`                                                       |
|Run a coroutine from async code            |`await foo()`                                                              |
|Run N coroutines concurrently, wait for all|`await asyncio.gather(*coros)`                                             |
|Same, with structured concurrency (3.11+)  |`async with asyncio.TaskGroup() as tg: tg.create_task(c)`                  |
|Run a coroutine in the background          |`task = asyncio.create_task(foo())`                                        |
|Process results as they finish             |`for coro in asyncio.as_completed(coros): r = await coro`                  |
|Limit concurrency to N                     |`async with asyncio.Semaphore(N): ...`                                     |
|Add a timeout                              |`async with asyncio.timeout(5): ...` (3.11+) or `asyncio.wait_for(coro, 5)`|
|Sleep without blocking                     |`await asyncio.sleep(seconds)`                                             |
|Call a blocking function                   |`await asyncio.to_thread(blocking_fn, arg1, arg2)`                         |
|HTTP request                               |`async with httpx.AsyncClient() as c: r = await c.get(url)`                |
|Iterate an async generator                 |`async for item in async_gen(): ...`                                       |
|Comprehension over async                   |`[x async for x in gen()]`                                                 |

-----

The mental model that holds it all together: **async is one worker who never stands idle while machines run.** The barista, the chess grandmaster, the event loop. When work is I/O-bound (which network-heavy Earth observation pipelines almost entirely are), this is dramatically faster than the synchronous version, at zero cost in CPU or memory.

When work is CPU-bound (JAX kernels, NumPy reductions, neural net forward passes), async does nothing useful — you need a different tool. Knowing which kind of work you have is the whole skill. Network → async. Compute → vectorization, parallelism, or GPUs. Most real pipelines have both, and the right answer is to layer them: async outer loop pulling data, sync inner kernel crunching it.