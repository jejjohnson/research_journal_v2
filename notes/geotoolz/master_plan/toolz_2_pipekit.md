---
title: "Report 2 — What pipekit will ship"
subject: geotoolz master plan
short_title: "R2 — pipekit"
authors:
  - name: J. Emmanuel Johnson
    affiliations:
      - UNEP
      - IMEO
      - MARS
    orcid: 0000-0002-6739-0053
    email: jemanjohnson34@gmail.com
license: CC-BY-4.0
keywords: geotoolz, pipekit, surface, operators
---

# Report 2 — What pipekit will ship

|                                 |                                                                                                                                                                                                                                                                                  |
|---------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|**Status**                       |Surface proposal (revised post-L0–L4 analysis)                                                                                                                                                                                                                                    |
|**Reading time**                 |~30 min                                                                                                                                                                                                                                                                           |
|**Audience**                     |Anyone making the final decision on what’s in pipekit v0.1                                                                                                                                                                                                                        |
|**Companion reports**            |Report 1 (background), Report 3 (sister libraries), Report 4/9 (use-cases), Reports 10–13 (cycle, train, experiment, statecatalog)                                                                                                                                                |
|**What changed in this revision**|Added Group M (state primitives for cycle support) and noted the `pipekit-cycle` sibling package. The new sister libraries (`pipekit-cycle`, `pipekit-train`, `pipekit-experiment`) get their own reports; this report covers only what’s needed in pipekit *core* to enable them.|

This report organises pipekit’s shipped surface into **semantic groups** rather than tiers. Each group corresponds to a single Python module under `pipekit/`, has a clear purpose, and can be reasoned about independently. The grouping makes documentation, code review, and feature planning much easier than the abstract “Tier 1 / 2 / 3” of v1.

## Module layout

```
pipekit/
  _base/
    operator.py          # Operator, ConfigMixin, Carrier
    sequential.py        # Sequential
    graph.py             # Input, Node, Graph
  compose.py             # toolz-style helpers: pipe, compose, juxt, complement
  blocks.py              # Identity, Const, Lambda, Sink
  control.py             # Branch, Switch, Try, Coalesce, Retry
  observe.py             # Tap, Snapshot, ShapeTrace, Profile, Histogram
  combine.py             # Fanout
  cache.py               # Cache, Memoize
  qc.py                  # Quarantine, AssertX family
  signature.py           # Signature + shape inference protocol
  parallel.py            # ParMap, AsyncMap, ProcessMap, BatchedMap
  state.py               # StatefulOperator, CarryState — primitives for pipekit-cycle
```

12 modules, ~1600 LOC total estimate.

## Group A — Foundations (`_base/`)

The irreducible kernel. Pure-Python, no third-party deps, no imports from numpy / xarray / anything else.

### A.1 `Operator` — the base class

The class everything else subclasses. Combines both libraries’ best features:

- **Dual-mode `__call__`** (geotoolz) — eager on data, symbolic on `Node` / `Input`
- **`ConfigMixin` auto-config** (xr_toolz) — derives `get_config()` from `__init__` signature via `inspect`
- **`state` / `from_state`** (geotoolz) — JSON-safe state record; reconstruction walks all transitive subclasses
- **Class-level flags** — `forbid_in_yaml`, `_terminal`
- **Pipe operator** — `op_a | op_b` returns `Sequential([op_a, op_b])`; flattens nested `Sequential`s
- **`_dispatch_post_apply_hooks`** stub (geotoolz reservation) — no-op in v0.1; reserved for v0.2 hook surface

```python
class Operator:
    forbid_in_yaml: ClassVar[bool] = False
    _terminal: ClassVar[bool] = False
    
    def __call__(self, *args, **kwargs): ...   # eager/symbolic dispatch
    def _apply(self, *args, **kwargs): ...     # subclass implements
    def get_config(self) -> dict: ...          # via ConfigMixin or override
    def compute_output_signature(self, sig): ...  # default passthrough
    def __or__(self, other) -> Sequential: ...
    @property
    def state(self) -> dict: ...
    @classmethod
    def from_state(cls, state) -> Operator: ...
```

### A.2 `Sequential` — linear composition

The workhorse. Apply operators left-to-right.

- Construction-time validation (`_terminal` only-at-end, all-items-are-Operators)
- `__or__` flattening for `(a | b) | c` and `a | (b | c)` shapes
- `__len__`, `__getitem__` (slice support — `pipe[1:3]` returns a new `Sequential`)
- **`summary(input_signature)`** (xr_toolz) — Keras-style structural table
- **`describe()`** (xr_toolz) — indented-tree pretty-print
- Empty-pipeline call shape — `Sequential([])` is the identity

### A.3 `Graph` + `Input` + `Node` — DAG composition

Symbolic multi-input / multi-output graphs. Construction is implicit: calling operators on `Input` or `Node` instances builds the graph; `__call__` evaluates it.

- `Input(Node)` subclass relationship (xr_toolz shape — simpler topological sort than geotoolz’s sibling shape)
- Topological sort with cycle detection at construction time
- Positional OR keyword argument forms — single-input Graphs compose into `Sequential` cleanly
- `_bind` / `_execute` / `_compute_signatures` triad (xr_toolz) — signatures propagate without executing data
- `summary` and `describe`

## Group B — Composition convenience (`compose.py`)

Small **free functions** (not Operator subclasses) carrying the toolz-style surface. ~50 LOC.

|Symbol                    |toolz ancestor      |What it does                                                                                                |
|--------------------------|--------------------|------------------------------------------------------------------------------------------------------------|
|`pipe(value, *operators)` |`toolz.pipe`        |Apply operators left-to-right to value. Equivalent to `Sequential(operators)(value)` but with less ceremony.|
|`compose(*operators)`     |`toolz.compose`     |Right-to-left composition: `compose(f, g, h) == Sequential([h, g, f])`.                                     |
|`compose_left(*operators)`|`toolz.compose_left`|Explicit left-to-right alias of `Sequential`.                                                               |
|`complement(predicate)`   |`toolz.complement`  |Negate a predicate. Useful for `Branch(predicate=complement(is_clean), ...)`.                               |
|`juxt(*operators)`        |`toolz.juxt`        |Tuple-returning multi-output. Distinct from `Fanout` (dict-returning).                                      |

Reasoning: every one of these makes pipekit feel familiar to toolz users. They cost almost nothing to implement and they signal lineage clearly.

## Group C — Building blocks (`blocks.py`)

Tiny operators that on their own look trivial but in combination unlock common patterns.

|Operator                  |Purpose                         |Notes                                                                             |
|--------------------------|--------------------------------|----------------------------------------------------------------------------------|
|`Identity`                |Explicit no-op                  |Default for `Branch.if_false`, `Switch.default`, anywhere a slot needs an Operator|
|`Const(value)`            |Return a fixed value            |Test fixtures, `Switch` defaults, golden values                                   |
|`Lambda(fn, name=...)`    |Wrap a callable                 |`forbid_in_yaml = True`; the escape hatch                                         |
|`Sink(write_fn, name=...)`|Side-effect write, returns input|`forbid_in_yaml = True`; checkpointing                                            |

## Group D — Control flow (`control.py`)

Conditionals and exception handling as first-class composable operators. The whole point: these are not Python `if`/`try` statements outside the pipeline — they’re operators *inside* it.

### Shipped from geotoolz core

|Operator                                         |Purpose                             |
|-------------------------------------------------|------------------------------------|
|`Branch(predicate, if_true, if_false=Identity())`|Binary conditional                  |
|`Switch(key, cases, default=Identity())`         |Multi-way dispatch on `key(carrier)`|

### Promoted from `pipeline_idioms.ipynb` build-your-own

|Operator                                             |Purpose                                  |
|-----------------------------------------------------|-----------------------------------------|
|`Try(primary, fallback, on=tuple_of_exception_types)`|Direct map from `toolz.excepts`          |
|`Coalesce(sources, is_ok)`                           |First op whose output passes `is_ok` wins|
|`Retry(op, attempts, base_delay, on)`                |Backoff loop for transient failures      |

All five take callable predicates / handlers and carry `forbid_in_yaml = True`.

## Group E — Observers (`observe.py`)

Identity-with-side-effect operators. The carrier flows through unchanged; something useful happens on the side. Critical for notebook exploration and debug, useful in production logging.

|Operator                                               |Purpose                                                                                                                                                         |
|-------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------|
|`Tap(fn, name=...)`                                    |Fire a callback, return input unchanged                                                                                                                         |
|`Snapshot()` (controller) + `Snapshot.at(key)`         |Capture intermediates by name                                                                                                                                   |
|`ShapeTrace(printer=print, mode="every"|"diff_only")`  |Log shape/dtype/extra at every step. Generalised — the `crs` line from geotoolz becomes a subclass hook                                                         |
|`Profile()` (controller) + `Profile.wrap(op)`          |Per-step timings; `Profile.report()`                                                                                                                            |
|`Histogram(bins=10)` (controller) + `Histogram.at(key)`|Capture distributions — **moved here from the deferred list, with a carrier-agnostic implementation that takes a callable `to_array` for numpy / xarray / etc.**|

Both `Snapshot` and `Profile` use the controller-not-operator pattern: the class isn’t an `Operator`, but `.at()` / `.wrap()` returns an operator that closes over the controller’s dict.

## Group F — Combination (`combine.py`)

One-input → many-outputs operators. The dict-keyed version is `Fanout`; the tuple-keyed version is `juxt` (in `compose.py`).

|Operator                   |Purpose                                                       |
|---------------------------|--------------------------------------------------------------|
|`Fanout({"name": op, ...})`|One input → dict of outputs, sugar over a single-input `Graph`|

Note: future combinators that need carrier-specific merging (`Augment`, `ApplyToEach` from xr_toolz) stay in xr_toolz because they use `xr.merge`. They do not live in pipekit.

## Group G — Caching (`cache.py`)

|Operator                         |Purpose                                                                        |
|---------------------------------|-------------------------------------------------------------------------------|
|`Cache(inner)` / `Memoize(inner)`|Hash-keyed memoisation; in-memory backend in v0.1; `_hits` / `_misses` counters|

Direct map from `toolz.memoize`. Hash key = `(input_repr_hash, config_canonical_json_hash)`. Disk backend deferred to v0.2.

## Group H — Quality control (`qc.py`)

Assertions as composable operators. Pass-through; raise (or warn) on contract violation. The bigger pattern: every QC check is a research-time “I bet this won’t break” turned into a permanent runtime guard. CI gets a pipeline-correctness suite for free.

|Operator                                         |Purpose                                                                  |
|-------------------------------------------------|-------------------------------------------------------------------------|
|`Quarantine(check, sentinel, on_quarantine=None)`|Non-raising QC: on failure log + return sentinel; on success pass through|
|`AssertShape(expected_shape)`                    |Pass-through; raise on shape mismatch                                    |
|`AssertDType(expected_dtype)`                    |Pass-through; raise on dtype mismatch                                    |
|`AssertHasAttribute(name, value=None)`           |Pass-through; check for attribute presence / value                       |
|`AssertCallable(predicate, message=...)`         |Pass-through; user-supplied predicate; raise on failure                  |

The numeric assertions (`AssertValueRange`, `AssertNoNaN`, etc.) live in sister libraries (Report 3) because they need to look inside the array. The pipekit-level assertions stay carrier-agnostic via `getattr`.

## Group I — Shape inference (`signature.py`)

|Symbol                                                            |Purpose                                                               |
|------------------------------------------------------------------|----------------------------------------------------------------------|
|`Signature(dims, dtype)`                                          |Immutable value class with `format()`, `drop_dims()`, `replace_dims()`|
|`Operator.compute_output_signature(input_sig) -> Signature | None`|Per-operator method; default passthrough                              |

**Critical wrinkle.** `Signature` assumes named dimensions (xarray-flavoured). For numpy / `GeoTensor` carriers, dim names are positional. The fix: `compute_output_signature` returns `Signature | None`. Operators that don’t track shape return `None`. `Sequential.summary` raises a clear “this operator doesn’t track shape” message rather than blowing up. Domain libraries (xr_toolz) get full shape inference; carrier-agnostic libraries (numpy-flavoured) opt out cleanly.

## Group J — Parallelism (`parallel.py`)

A new group that didn’t exist in either parent library. Worth a dedicated section because this is the single biggest deployment concern, and the design decisions here ripple back into how operators must be written.

### J.1 The four parallelism shapes

Pipelines hit four distinct parallelism patterns. Pipekit ships one operator wrapper for each.

|Shape                    |When                                                      |Constraint                                                  |pipekit operator                                                  |
|-------------------------|----------------------------------------------------------|------------------------------------------------------------|------------------------------------------------------------------|
|**Thread-pool parallel** |I/O-bound (reading from S3, downloading tiles)            |GIL must release in the I/O path (network, rasterio reads)  |`ThreadMap(op, n_workers=8)`                                      |
|**Process-pool parallel**|CPU-bound, pickleable workload                            |Every step must be pickleable: no closures, no captured RNGs|`ProcessMap(op, n_workers=8, on_error="raise"|"log_and_continue")`|
|**Async**                |I/O-bound, single-threaded async stack (FastAPI, LitServe)|Operator must be `async def` or wrappable                   |`AsyncMap(op, semaphore=N)`                                       |
|**Batched / vectorised** |GPU inference; SIMD-bench numpy ops                       |Carrier axis 0 = batch dim                                  |`BatchedMap(op, batch_size=8)` (sister to `ModelOp`)              |

### J.2 The pickleability discipline

Process-pool parallelism is the most common production deployment. The constraint it imposes is severe and not obvious until something breaks at scale: **every operator in the pipeline must be pickleable.**

- Closures in `Lambda`, `Tap`, `Sink`, `Branch.predicate`, `Switch.key`, `ModelOp.model` are pickleability hazards.
- Captured RNGs in augmentation operators silently produce correlated batches across workers.
- Default cloud credentials, file handles, GPU contexts: not pickleable.

The pipekit response is **the `forbid_in_yaml = True` flag does double duty as a pickleability warning.** A future `pipekit.parallel.check_pickleable(operator)` utility walks the operator tree, finds flagged operators, and surfaces them as warnings before the pipeline runs across workers. This isn’t a runtime enforcement; it’s pre-deployment lint.

### J.3 The async story

`AsyncMap(op, semaphore=N)` accepts an operator and runs it across an async iterator with bounded concurrency. The operator itself doesn’t need to be `async` — if it’s sync, `AsyncMap` runs it in a thread executor. If it’s `async def _apply`, `AsyncMap` awaits it directly.

The catch: an async operator’s `_apply` is `async def`, which means `__call__` dispatch (eager vs symbolic) gets more complicated. The honest answer for v0.1: **the operator can be `async def`, but `Sequential` doesn’t natively understand async**. Async operators get unwrapped at the `AsyncMap` layer, not at the `Sequential` layer. v0.2 might introduce `AsyncSequential` if there’s pressure to make composition itself async.

### J.4 Distributed / dask / ray

Explicitly out of scope. Pipekit ships single-machine parallelism (threads / processes / async / batch). Distributed parallelism (dask, ray, beam, flink) is downstream tooling territory. The pipekit response: **operators are pickleable and stateless when they need to be**; how they get scheduled across a cluster is the orchestrator’s problem (see Report 4 use cases 2, 12).

### J.5 The catalog-iteration pattern

The usecases doc shows `CatalogPipeline` repeatedly (use cases 2, 12). The pattern is:

```python
class CatalogPipeline(Operator):
    def __init__(self, catalog, op, n_workers=1, on_error="raise"):
        ...
    
    def run(self):
        if self.n_workers == 1:
            for row in self.catalog.iter_rows():
                self._process(row)
        else:
            with ProcessPoolExecutor(self.n_workers) as ex:
                list(ex.map(self._process, self.catalog.iter_rows()))
```

This pattern is **domain-specific (`catalog` is a geocatalog concept) and stays in the sister libraries**. What pipekit ships is the parallel-iteration primitive (`ProcessMap`, `ThreadMap`) that catalog-iteration is built on top of.

### J.6 Worth being explicit

Pipekit’s parallelism story is intentionally minimal:

- No automatic parallelism. `Sequential` is sequential; `Graph` evaluates topologically in one process.
- No backend abstraction. The four primitives (`ThreadMap`, `ProcessMap`, `AsyncMap`, `BatchedMap`) are stdlib-based (`concurrent.futures`, `asyncio`).
- No fault tolerance beyond `on_error="log_and_continue"`. Retries, dead-letter queues, durable state — orchestrator’s job.

The reasoning: parallelism design decisions trade off correctness, latency, throughput, and observability differently in every deployment. The framework provides honest primitives; the deployment decides how to combine them. Compare to the [usecases gallery](https://github.com/jejjohnson/research_journal_v2/blob/main/notes/geotoolz/plans/geotoolz/examples/usecases.md) — every parallelism case (ETL with `n_workers=8`, FastAPI with thread-pool I/O, LitServe with batched GPU inference, Prefect orchestration) wires up its own combination of these primitives.

## Group M — State primitives (`state.py`)

A new group added in this revision to enable the `pipekit-cycle` sibling package (Report 10) without forcing pipekit itself to ship cycle abstractions. Two primitives, ~150 LOC total.

### M.1 The problem

Pipekit’s existing operators are stateless transformations: `Operator._apply(carrier) → carrier`. They have no memory across calls. This is correct for L0–L2 processing (each scene flows through independently) but fails for L3–L4 work where:

- **DA cycles** need state carry-over across time steps (forecast → analysis → forecast → …)
- **Iterative inference** needs convergence state (residual, iteration count, learning rate schedule)
- **Cumulative aggregations** need running state (online mean, streaming histogram)
- **Recurrent models** need hidden-state propagation

`pipekit.Snapshot` captures intermediate values for *observation* (debug, profile) — not for *threading state through computation*. We need a different primitive.

### M.2 `StatefulOperator`

A subclass marker for operators whose `_apply` takes and returns a `(carrier, state)` tuple rather than just a carrier:

```python
class StatefulOperator(Operator):
    """An operator whose _apply has signature (carrier, state) -> (carrier, state).
    
    Composes into Sequential / Graph just like Operator; the framework threads
    state through automatically. Pipekit-cycle uses these as the per-step
    operator in a Cycle.
    """
    initial_state_fn: Callable[[], Any] | None = None
    _is_stateful: ClassVar[bool] = True

    def _apply(self, carrier, state):
        raise NotImplementedError
```

A `Sequential` containing `StatefulOperator`s automatically threads state through them. A `Sequential` containing only stateless operators behaves identically to today. Mixed pipelines work: stateless operators pass state through unchanged.

### M.3 `CarryState`

A lightweight container for state carried through a cycle. Frozen dataclass-shaped; supports JSON round-trip via the same `state` / `from_state` discipline as `Operator`:

```python
class CarryState:
    """State threaded through a stateful pipeline.
    
    Subclass per state shape — e.g., DAState(background_cov, ensemble_members, t),
    IterationState(residual, count, lr). Serializable to JSON for checkpointing.
    """
    def to_dict(self) -> dict: ...
    @classmethod
    def from_dict(cls, d) -> "CarryState": ...
```

The base class doesn’t dictate fields. Each cycle pattern brings its own `CarryState` subclass.

### M.4 Why this lives in pipekit core, not in pipekit-cycle

Two reasons:

1. **`StatefulOperator` participates in `Sequential` dispatch.** If `Sequential` needs to detect stateful operators and thread state, that logic lives in pipekit (where `Sequential` is defined). Putting `StatefulOperator` in a sibling package would invert the dependency.
2. **Other sibling packages may want state too.** `pipekit-train`’s `TrainingLoop` is itself a stateful operator (the trainer state — optimizer, step, metrics — is threaded through epochs). Same for amortized-inference training loops. Having the base class in pipekit lets all of them share it.

`pipekit-cycle` ships the actual cycle operators (`Cycle`, `EnsembleCycle`, `DACycle`, etc.) built on top of these primitives. ~500 LOC of cycle machinery, all extending `StatefulOperator`. See Report 10.

## Group K — Deferred to sister libraries

For completeness, the operators we **don’t** ship in pipekit core. Each is carrier-specific.

|Operator                                                  |Reason                                                   |Lives in                                                                  |
|----------------------------------------------------------|---------------------------------------------------------|--------------------------------------------------------------------------|
|`ModelOp`                                                 |Currently numpy-specific (`np.asarray`, `np.concatenate`)|`pipekit-array` (Report 3) once Array API; or stays in geotoolz / xr_toolz|
|`ApplyToBands`                                            |numpy (`np.take`, `np.stack`)                            |`pipekit-array`                                                           |
|`Subsample`                                               |numpy slicing                                            |`pipekit-array`                                                           |
|`Diff`                                                    |numpy reductions                                         |`pipekit-array`                                                           |
|`AssertValueRange` / `AssertNoNaN` / `AssertValidFraction`|numpy reductions on the array                            |`pipekit-array` (or xr_toolz / geotoolz)                                  |
|`Mode` / `ModeGated` + `pipeline_mode`                    |Stateful global mode (contextvars)                       |Deferred — design questions before promotion                              |
|`Provenance` / `Watermark`                                |Carrier-specific metadata attachment                     |Stays in geotoolz / xr_toolz                                              |
|`Augment`                                                 |`xr.merge`                                               |xr_toolz                                                                  |
|`ApplyToEach`                                             |`xr.merge`                                               |xr_toolz                                                                  |
|`Spy` / `Hook`                                            |Cross-cutting hooks; design questions                    |Deferred — `_dispatch_post_apply_hooks` reservation in `Operator`         |

## Group L — Serialisation glue (lightweight, optional)

A small surface for YAML / Hydra / JSON serialisation. Not its own module — lives next to `Operator.from_state`. Two utilities worth shipping in v0.1:

- `dumps(op) -> str` — JSON-encode the op’s `state` record
- `loads(s) -> Operator` — round-trip via `Operator.from_state`

Heavier loaders (YAML, Hydra-zen builds, sandboxed loaders) live in `pipekit[yaml]` / `pipekit[hydra]` optional extras. The sandboxed loader for user-uploaded pipelines (use case 6) is implemented in pipekit core with the `ALLOWED` registry as an extension point — domain libraries register their operators and the sandboxed loader rejects anything not in the registry.

## Summary table — full v0.1 inventory

|Group              |Module                                            |Symbols                                                                           |LOC est.     |
|-------------------|--------------------------------------------------|----------------------------------------------------------------------------------|-------------|
|A. Foundations     |`_base/operator.py` + `sequential.py` + `graph.py`|`Operator`, `ConfigMixin`, `Sequential`, `Input`, `Node`, `Graph`                 |~600         |
|B. Convenience     |`compose.py`                                      |`pipe`, `compose`, `compose_left`, `complement`, `juxt`                           |~60          |
|C. Building blocks |`blocks.py`                                       |`Identity`, `Const`, `Lambda`, `Sink`                                             |~120         |
|D. Control flow    |`control.py`                                      |`Branch`, `Switch`, `Try`, `Coalesce`, `Retry`                                    |~200         |
|E. Observers       |`observe.py`                                      |`Tap`, `Snapshot`, `ShapeTrace`, `Profile`, `Histogram`                           |~250         |
|F. Combination     |`combine.py`                                      |`Fanout`                                                                          |~80          |
|G. Caching         |`cache.py`                                        |`Cache`, `Memoize`                                                                |~80          |
|H. Quality control |`qc.py`                                           |`Quarantine`, `AssertShape`, `AssertDType`, `AssertHasAttribute`, `AssertCallable`|~130         |
|I. Shape inference |`signature.py`                                    |`Signature`, `compute_output_signature` protocol                                  |~150         |
|J. Parallelism     |`parallel.py`                                     |`ThreadMap`, `ProcessMap`, `AsyncMap`, `BatchedMap`                               |~250         |
|L. Serialisation   |(inline)                                          |`dumps`, `loads`, sandboxed loader hooks                                          |~80          |
|M. State primitives|`state.py`                                        |`StatefulOperator`, `CarryState`                                                  |~150         |
|**Total**          |                                                  |**~42 symbols**                                                                   |**~2150 LOC**|

Plus tests (~1600 LOC) and docs (~2200 lines markdown).

## What’s intentionally not here

- **Distributed execution** (dask, ray, beam, flink): orchestrator’s job
- **Automatic differentiation / JAX `@jit` compatibility**: incompatible with `__call__` dual-mode dispatch; separate library (`jax_geotoolz` or `equinox`-style)
- **Type-checking of operator chains** at construction time: `Sequential([op_a, op_b])` doesn’t verify `op_a` output type matches `op_b` input type. `Signature` gives shape checking; type checking is a stretch goal.
- **Carrier-specific operators**: see Group K and Report 3
- **GUI / pipeline-builder integration**: a future possibility but not in v0.1
- **Workflow scheduling** (Airflow, Prefect, Dagster): adapters live in `pipekit[orchestration]` extras or downstream libraries, not core

## Open scoping questions for the design doc

Same seven as v2 scoping report, slightly refined by the group structure:

1. **Naming.** `pipekit` is fine but worth checking PyPI for conflicts and considering alternatives (`opkit`, `composable`, `pipekit-core`). Lean: `pipekit`.
2. **`ConfigMixin` always on?** Lean: yes, with `__config_mixin_auto__ = False` and `__config_exclude__` escape hatches.
3. **`Signature` interaction with non-named-dim carriers.** Lean: `compute_output_signature` returns `Signature | None`; `Sequential.summary` raises a clean error on `None`.
4. **YAML round-trip enforcement.** Lean: runtime check in YAML loader rejects `forbid_in_yaml` operators; optional `strict=True` in dumper.
5. **Hydra-zen as built-in or extra.** Lean: extra (`pipekit[hydra]`).
6. **Promote which of `Coalesce` / `Retry` / `Mode` / `Provenance` from the v2 deferred list?** Lean: ship `Coalesce` and `Retry` in v0.1 (small surface, clear semantics); keep `Mode` and `Provenance` deferred (design questions).
7. **Async story: ship `AsyncMap` only, or also `AsyncSequential`?** Lean: `AsyncMap` only in v0.1. `AsyncSequential` if it surfaces real pressure later.