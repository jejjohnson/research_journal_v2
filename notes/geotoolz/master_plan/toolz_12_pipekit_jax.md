---
title: "Report 5 — `pipekit-jax`: a future-direction analysis"
subject: geotoolz master plan
short_title: "R5 — pipekit-jax"
authors:
  - name: J. Emmanuel Johnson
    affiliations:
      - UNEP
      - IMEO
      - MARS
    orcid: 0000-0002-6739-0053
    email: jemanjohnson34@gmail.com
license: CC-BY-4.0
keywords: geotoolz, pipekit-jax, JAX, future-direction
---

# Report 5 — `pipekit-jax`: a future-direction analysis

|                      |                                                                                                                                                      |
|----------------------|------------------------------------------------------------------------------------------------------------------------------------------------------|
|**Status**            |Future-direction; not for v0.1, not even v0.2                                                                                                         |
|**Reading time**      |~25 min                                                                                                                                               |
|**Audience**          |Anyone who’ll eventually need autodiff or jit through a `pipekit`-shaped pipeline                                                                     |
|**Companion reports** |Report 1 (background), Report 2 (pipekit core), Report 3 (sister libraries), Report 4 (use cases)                                                     |
|**Backend assumption**|[Equinox](https://docs.kidger.site/equinox/) — `eqx.Module` for parameterised functions as PyTrees, `eqx.filter_jit`/`grad`/`vmap` for transformations|

## Why this report exists

You’ll eventually want a JAX-traceable version of pipekit’s Operator graph — for differentiable retrievals, learnable corrections to matched filtering, JIT-compiled inference paths in MARS, vmap-batched scene processing. This report is the **heads-up before that work starts**: which pieces of the pipekit design port cleanly, which fight JAX, and what the right shape of the library is when it gets built.

Before I get into recommendations, I need to correct something from earlier reports.

## Correction: JAX `@jit` is not “fundamentally incompatible” with pipekit’s dispatch

In Report 2 (Group J) and Report 3 (§5.3), I claimed JAX `@jit` is fundamentally incompatible with pipekit’s `__call__` dual-mode dispatch. After actually checking how JAX tracing works, **that claim was wrong**. Let me be precise about what’s actually true.

The dispatch is:

```python
def __call__(self, *args, **kwargs):
    if any(isinstance(a, (Node, Input)) for a in args):
        return Node(operator=self, parents=tuple(args))
    return self._apply(*args, **kwargs)
```

When you call `jit(pipeline)(gt)`, JAX traces by replacing `gt` with a `Tracer`. The `Tracer` is **not** a `Node` or `Input` — JAX’s tracers are a completely separate class hierarchy. So `isinstance(a, (Node, Input))` returns `False`, the operator runs eagerly via `_apply`, and JAX captures the operations into a jaxpr. **This is the correct behaviour**.

So the dispatch itself is jit-safe. The incompatibilities are real but they’re different — they’re about *what’s inside `_apply`*, not about how dispatch works. I’ll cover them in §4. Apologies for the prior nonsense.

## Part 1 — How JAX actually works (the mental model)

Before deciding what ports, the relevant facts:

### 1.1 Tracers are abstract stand-ins

When you `jit(f)(x)`, JAX doesn’t run `f` with the actual `x`. It runs `f` with a `Tracer` object that carries an abstract value (`ShapedArray(shape, dtype)`). Every JAX operation on the Tracer records itself into a jaxpr (JAX’s IR). At the end of tracing, the jaxpr is compiled to XLA and executed with the real data. The original `f` is never run again with concrete data — the compiled XLA is.

Implications for an Operator:

- **The first call traces; subsequent calls hit cached compiled code.** Anything that should happen at runtime must be expressible as a JAX op. Anything that should happen at compile time happens during tracing — once.
- **Python `if` on a traced value raises `ConcretizationTypeError`.** Because the abstract `ShapedArray` doesn’t have a concrete value to branch on.
- **Side effects (prints, file writes) only fire during the trace, not at runtime.** They get baked out.
- **Python control flow on *static* arguments works fine.** Tracing re-runs whenever the static args change.

### 1.2 Equinox in one paragraph

`eqx.Module` registers your class as a PyTree. That’s the whole library — the source is ~100 lines. Fields become leaves; non-array fields can be marked `static=True` via `eqx.field(static=True)` to live in the PyTree structure rather than as leaves. `eqx.filter_jit(fn)` is `jax.jit` with automatic partitioning: array leaves get traced, non-array leaves get held static. Same for `filter_grad`, `filter_vmap`, `filter_pmap`. Models are callable PyTrees; `jax.vmap(model)(x_batch)` just works.

### 1.3 PyTrees are trees, not DAGs

This one matters for our design. JAX assumes referential transparency: each PyTree describes a tree, not a directed acyclic graph. Putting the same object in multiple leaves “silently misbehaves” (Equinox docs’ words). The Equinox solution is `eqx.nn.Shared` for tied weights. For us, this matters because a `pipekit.Graph` *can* have nodes that consume the same intermediate twice — that node ends up referenced in multiple places, and naïvely making the Graph a PyTree would break.

### 1.4 The filter pattern

The standard Equinox pattern for “model with mixed array and non-array fields”:

```python
params, static = eqx.partition(model, eqx.is_array)
# params: PyTree with array leaves; non-array leaves replaced with None
# static: inverse; the structural / config part

@jax.jit
def step(params, static, x):
    model = eqx.combine(params, static)
    return model(x)
```

Or equivalently, `eqx.filter_jit(fn)(model, x)` does this automatically. The same pattern works for `grad`, `vmap`, `pmap`.

## Part 2 — Two ways to ship: with or without pipekit

You asked specifically about both options.

### 2.1 Option A — `pipekit-jax` builds on `pipekit`

The clean version. `pipekit-jax` imports `pipekit.Operator`, `Sequential`, `Graph`, etc., and adds JAX-flavoured operators plus the small machinery needed to make Operators play with `eqx.Module`.

```python
# pipekit_jax/operator.py
import equinox as eqx
from pipekit import Operator as _Operator

class JaxOperator(_Operator, eqx.Module):
    """Pipekit Operator that's also an Equinox Module (a PyTree)."""
    # The dual MRO is the key trick.
```

This works because `eqx.Module` only adds PyTree registration via `__init_subclass__` — it doesn’t conflict with pipekit’s `Operator` machinery. Subclasses inherit everything from both.

**Pros.**

- One framework. Pipekit’s `Sequential` / `Graph` / `Fanout` / `Branch` / serialisation work as-is.
- `pipekit-jax` is small — only the JAX-specific operators and a few adapter classes.
- Pipelines compose across libraries: a `Sequential` can chain pipekit-jax JIT-able steps with pipekit-array preprocessing.
- `from_state` reconstruction from YAML works unchanged.

**Cons.**

- Pipekit’s design includes features (`Tap`, `Snapshot`, `Sink`) that don’t play well with JAX tracing. They have to be neutered or redirected for jit-mode use.
- Some operators in pipekit (`Branch.predicate` calling Python `if`) need to be reimplemented for JAX (`lax.cond` predicates).
- Adds a transitive dep on pipekit, even though most code overlap is small.

### 2.2 Option B — `pipekit-jax` is standalone

`pipekit-jax` reimplements the Operator base, Sequential, and Graph in pure-Equinox idioms. No pipekit dep.

**Pros.**

- Cleaner JAX semantics — no need to work around features that don’t fit. Branch/Switch use `lax.cond`/`lax.switch` natively without a “compatibility shim” with the Python-`if` version.
- Faster to evolve independently. JAX changes a lot; not tying to pipekit means you can move at JAX’s pace.
- The library is single-purpose and easier to reason about.

**Cons.**

- Code duplication. Sequential, Graph, Fanout, ConfigMixin, from_state, YAML loading all get reimplemented.
- No cross-library composition. A pipekit `Sequential` and a pipekit-jax `Sequential` are different types.
- Pipelines that want to mix non-JAX preprocessing (read GeoTensor, mask clouds) with JAX-traced retrieval (matched filter, autodiff) need glue code at the boundary.

### 2.3 Recommendation

**Option A — build on pipekit.** The cross-library composition is more valuable than the JAX-purity. The features that don’t fit JAX (Tap, Sink, mutable Snapshot) are exactly the ones you don’t *use* in production retrieval pipelines anyway — they’re notebook / debug tools. And the duplication cost of Option B is real (~600-800 LOC of reimplemented framework).

Specifically: `pipekit-jax.JaxOperator` is `pipekit.Operator + eqx.Module` via multiple inheritance. Pipekit’s `Sequential` and `Graph` are re-used as-is (they’re carrier-agnostic — they don’t care what’s flowing through). What `pipekit-jax` ships is the JAX-flavoured *operators* plus a handful of replacements for operators that don’t trace cleanly.

## Part 3 — What ports cleanly

The classes that don’t fight JAX at all.

### 3.1 `Operator` base class

Pipekit’s `Operator` is pure-Python. It carries `get_config`, `state`, `from_state`, `forbid_in_yaml`, `_terminal`, `__or__`, dual-mode dispatch. None of this conflicts with JAX. A subclass that’s both `Operator` and `eqx.Module` works:

```python
class TOAToBOA(JaxOperator):
    sun_zenith_band: int = eqx.field(static=True)  # static config

    def _apply(self, gt):
        # Pure-functional JAX-style implementation
        return gt - jnp.cos(sun_zenith[..., self.sun_zenith_band, :, :])
```

The `eqx.field(static=True)` annotation puts config fields in the static part of the PyTree, so `jit` doesn’t retrace when you instantiate two `TOAToBOA(sun_zenith_band=4)` operators with the same value.

### 3.2 `Sequential`

`Sequential` is just a list of operators applied left-to-right. Pure structural — no JAX involvement. If every step’s `_apply` is JAX-pure, then `jit(seq)(x)` traces the whole pipeline as a single jaxpr.

The one wrinkle: `Sequential` holds `self.operators` as a Python list. To make a `Sequential` itself a PyTree (so it can be vmapped across, say, an ensemble), the operators list needs to be a tuple (PyTree-registered) rather than a mutable list. `pipekit-jax.JaxSequential` overrides this.

```python
class JaxSequential(Sequential, eqx.Module):
    operators: tuple   # tuple, not list, so it's PyTree-flat
```

### 3.3 `Graph`

Same logic. Construction-time symbolic, evaluation-time pure. The cycle-detection and topological-sort logic is pure-Python and runs once at construction. The runtime path is just operator composition.

Caveat from §1.3: a `Graph` with diamond dependencies (one intermediate consumed by two downstream nodes) means the same node is referenced twice. As pure structural composition this is fine — the topological sort handles it. But making the Graph itself a PyTree leaf would silently misbehave because of JAX’s tree-not-DAG assumption. The fix: `JaxGraph` evaluates eagerly when called, but isn’t itself stored as a PyTree leaf inside a larger PyTree. (You can jit the Graph’s `__call__`; you just can’t `vmap` over a structure that contains the Graph as a leaf in multiple places.)

### 3.4 `Fanout`

Trivial port. Each branch operator runs independently on the same input; outputs come back as a dict. No JAX-specific concerns.

### 3.5 `Identity`, `Const`, `Lambda`

- `Identity` traces fine — `return gt` is a no-op in the jaxpr.
- `Const(value)` ignores its input and returns a fixed value. If `value` is a JAX array, traces fine. If `value` is a static config value, mark it with `eqx.field(static=True)`.
- `Lambda(fn)` — the function `fn` runs at trace time. If `fn` itself is pure JAX, traces fine. If `fn` does Python-`if` on traced values, breaks.

### 3.6 Shape inference (`Signature`)

`Signature` is a value class with `(dims, dtype)`. Operators’ `compute_output_signature` runs at construction / introspection time, not at trace time. **Fully portable** — and arguably more useful in JAX-land because shape correctness is the single most common bug.

### 3.7 YAML / `from_state` / config_hash / registry / sandboxed loader

All build-time framework. Run before any tracing happens. Fully portable.

### 3.8 `Branch` and `Switch` — with a JAX-flavoured rewrite

The pipekit versions take a Python predicate that returns a Python bool. Under jit, that fails: `ConcretizationTypeError`. The JAX-flavoured replacements use `lax.cond` and `lax.switch`:

```python
class JaxBranch(JaxOperator):
    predicate: Callable                              # produces a JAX bool
    if_true: JaxOperator = eqx.field()
    if_false: JaxOperator = eqx.field()

    def _apply(self, x):
        return lax.cond(self.predicate(x), self.if_true, self.if_false, x)
```

Both branches must have the same output shape and dtype — `lax.cond` requirement. This is more restrictive than the pipekit `Branch`, where the arms can return different shapes, but it’s correct for jit-traced code.

### 3.9 `ShapeTrace`

This one’s interesting. Under jit, `print` only fires during the trace (once). That’s actually fine for `ShapeTrace`‘s purpose — you want to see shapes during construction / first run, not on every call. So the eager-version pipekit `ShapeTrace` works correctly under jit, just with the property that subsequent calls don’t print. Document this and ship as-is.

### 3.10 Summary of clean ports

These all work in `pipekit-jax` essentially unchanged from `pipekit`:

`Operator` (with `eqx.Module` mixin), `Sequential` (with tuple-of-operators), `Graph`, `Fanout`, `Identity`, `Const`, `Lambda`, `Signature` + shape inference, YAML / serialisation / registry / sandboxed loader, `ShapeTrace` (with the trace-time-only caveat documented).

`Branch` and `Switch` need a `lax.cond`/`lax.switch`-based reimplementation but the *concept* ports.

## Part 4 — What doesn’t port

The honest list. Each of these is either subtly broken under jit, or fundamentally the wrong abstraction.

### 4.1 `Tap(fn)` — side effects only fire at trace time

`Tap` is “call `fn(x)`, return `x` unchanged.” Under jit, `fn(x)` runs during tracing (with abstract tracers as the input) and then never again. Your callback receives a `Tracer`, not a real array. If you write `Tap(lambda x: print(f"NaN frac: {np.isnan(x).mean()}"))`, it’ll print something useless about a Tracer.

**Workarounds.**

- `jax.debug.print("NaN: {x}", x=jnp.isnan(x).mean())` runs at runtime, embedded in the jaxpr. Replace `Tap` with a `JaxDebugPrint` operator that uses this.
- `jax.experimental.io_callback` runs an arbitrary Python callback at runtime (with some overhead). Use sparingly.
- Outside-of-jit: `Tap` works as in pipekit. Document clearly that **`Tap` is a debug-mode tool that’s disabled under jit**.

### 4.2 `Sink(write_fn)` — same problem, worse

`Sink` writes side data (a COG to disk, a metric to a database) and passes the carrier through. Under jit: the write happens once at trace time and never again. This is wrong every time.

**Workarounds.**

- Use `io_callback` for the write. Slow but correct.
- Better: split the pipeline at the Sink. Jit the part before; run the Sink in Python; jit the part after if there is one.
- Document that **`Sink` is incompatible with jit and is a deployment-layer concern, not a pipeline-layer one** in JAX-land.

### 4.3 `Snapshot` — mutable state breaks tracing

`Snapshot` is a controller that mutates a dict as the pipeline runs. JAX is functional — mutable state during tracing gets captured at trace time and frozen.

**Workarounds.**

- Use the snapshot pattern outside of jit only.
- For inside jit, the equivalent is `lax.scan` with carry state — different API entirely.
- Document: **`Snapshot` is a debug-mode tool, not a production-jit-pipeline tool**.

### 4.4 `Profile` — meaningless under jit

`Profile` times each operator. Under jit, all operators get fused into one jaxpr; per-operator timings don’t exist. The timing you get is the trace-time timing, which is one-shot and unrepresentative.

**Workarounds.**

- For JIT timing, use `jax.profiler` (system-wide profiler) or `jax.block_until_ready` around the full pipeline call.
- Don’t ship a JAX-flavoured `Profile`. Tell users it’s a debug-mode tool only.

### 4.5 `Cache` / `Memoize` — JAX already has compilation caching

JAX caches compiled functions by their (shape, dtype, static-args) signature. A user-level `Cache(inner)` is redundant under jit and may actively hurt — it prevents JAX from seeing the full computation. Drop from `pipekit-jax`.

### 4.6 `ProcessMap` / `AsyncMap` — wrong abstraction

These are CPU/IO parallelism primitives. JAX’s parallelism story is `vmap` (vectorisation) and `pmap` / `shard_map` (device parallelism). Cross-process parallelism with JAX makes less sense — you’ve already got XLA fanning out to all device cores.

**Replacements in `pipekit-jax`:**

- `BatchedMap` becomes `VMapOver(op)` — semantically the same (apply to a batched axis), but compiles to a single XLA kernel via `vmap`.
- `ProcessMap` has no direct analogue; data-parallel scene processing is `pmap` or `shard_map` across devices.

### 4.7 `Branch` / `Switch` with Python predicates on traced values

Covered in §3.8 — these need rewriting as `JaxBranch` / `JaxSwitch` using `lax.cond` / `lax.switch`. The pipekit versions don’t trace.

### 4.8 `ModelOp` — fundamentally different in JAX

Pipekit’s `ModelOp` wraps “any callable” (sklearn estimator, torch model, JAX function) and treats the model as opaque state. In JAX, the model *is* a PyTree — there’s no “opaque callable” abstraction. You don’t wrap a model; you put the model in the pipeline directly.

In JAX-land, the equivalent of `ModelOp` is simply: any `JaxOperator` whose `_apply` calls a model PyTree. The model is a field of the operator, not a wrapped opaque object.

```python
class MatchedFilter(JaxOperator):
    target_spectrum: jax.Array  # learnable; participates in grad
    detector_model: eqx.nn.MLP  # learnable correction; participates in grad

    def _apply(self, gt):
        scores = ...
        correction = self.detector_model(scores)
        return scores + correction
```

### 4.9 `from_state` at trace time

`Operator.from_state(state_dict)` walks `cls.__subclasses__()` to find the concrete class and reconstruct. This is build-time work — fine. **Doing it inside `_apply` (i.e. inside the trace) would be a bug.** Document and ship; the build-time / trace-time distinction is a JAX literacy issue, not a framework defect.

## Part 5 — JAX transformations and the pipeline

How each transformation interacts with a `pipekit-jax` pipeline.

### 5.1 `jit`

Wraps the whole pipeline. `eqx.filter_jit(sequential)(gt)` traces once, then runs compiled XLA on subsequent calls. Two requirements on the operators:

1. Every `_apply` is JAX-pure (uses `jnp`, not `np`; no Python `if` on traced values; no mutation).
2. Static config fields are marked `eqx.field(static=True)` so jit doesn’t retrace when you reconstruct the same pipeline with the same config.

Result: a fast inference pipeline. Real value for MARS operational throughput.

### 5.2 `vmap`

Vectorise over a leading batch axis. `eqx.filter_vmap(sequential)(batch_of_gts)`. Each operator’s `_apply` is written for one scene; vmap maps it across many.

Wrinkle: vmap interacts with shape inference. The `Signature` for a vmapped pipeline gains a leading batch dim — `compute_output_signature` needs to handle this if the user wants `summary()` to work for vmapped pipelines.

### 5.3 `grad`

Differentiate the pipeline w.r.t. some inputs (typically learnable parameters inside operators). `eqx.filter_grad(loss_fn)(model, x, y)` where `model` includes the pipeline.

This is the headline feature for differentiable retrievals: the `target_spectrum` in a matched filter, the percentile cutoffs in radiometric correction, the threshold in a cloud mask — all become differentiable parameters that can be trained against a ground-truth signal.

Constraint: every operator in the differentiated path must be smooth. `jnp.where(x > threshold, ...)` is fine; integer indexing with a learnable index is not. Cloud-bit-masking operators need `straight-through` gradient hacks or just stop_gradient.

### 5.4 `pmap` / `shard_map`

Device parallelism — same pipeline running on multiple GPUs / TPU cores in parallel. `pmap` is the older API; `shard_map` is newer and more flexible (since JAX ~0.4.x).

This is where multi-device inference at MARS scale fits. A single XLA kernel can fan a batch of 8 scenes across 8 GPUs and process them in parallel without leaving the device.

Constraint from Equinox: `filter_pmap` has known limitations with non-JAX-array return types ([equinox#115](https://github.com/patrick-kidger/equinox/issues/115)). If a pipeline returns a `dict` with mixed array / non-array values, `pmap` won’t work cleanly. Workaround: pmap a wrapper that returns only arrays.

### 5.5 `lax.scan`

For repeated / iterative operators. A fixed-point iteration solver, an RNN-style temporal smoother, or a many-step physics model — all benefit from `scan` over Python loop, both for compile time and for memory.

`pipekit-jax` should expose `ScanSequential(op, n_steps)` that applies an operator `n_steps` times via `lax.scan`. Useful for the systematic-variations pattern in [equinox#685](https://github.com/patrick-kidger/equinox/issues/685) — a sequence of small modifications applied in turn to a histogram or similar.

### 5.6 `checkpoint` (rematerialisation)

For memory-bound large pipelines, `jax.checkpoint` (a.k.a. `jax.remat`) trades extra compute for less memory by recomputing intermediates during the backward pass instead of storing them. Useful for differentiable retrievals on large hyperspectral scenes.

`pipekit-jax` should expose `Checkpoint(op)` as a transparent wrapper. Trivial to implement.

### 5.7 Compose freely

These transformations compose: `jit(vmap(grad(pipeline)))` works as long as the pipeline is pure. This is the killer feature — write the pipeline once, transform it five different ways depending on whether you want training, batched inference, or device-parallel deployment.

## Part 6 — Equinox-specific design decisions

Concrete choices when building `pipekit-jax`.

### 6.1 Subclassing pattern

```python
import equinox as eqx
from pipekit import Operator

class JaxOperator(Operator, eqx.Module):
    """Pipekit Operator that's also an Equinox Module (a PyTree)."""
    pass
```

MRO: `JaxOperator → Operator → eqx.Module → object`. Both contribute `__init_subclass__` hooks; both run. `Operator` adds `forbid_in_yaml`, `_terminal`, dispatch; `eqx.Module` adds PyTree registration.

### 6.2 Static vs dynamic fields

The default Equinox behaviour: array fields become PyTree leaves; non-array fields become PyTree static. You usually want explicit control:

```python
class TOAToBOA(JaxOperator):
    sun_zenith_band: int = eqx.field(static=True)  # config
    correction_factor: jax.Array                    # learnable
```

Convention to ship: `JaxOperator` subclasses use `eqx.field(static=True)` for *every* config field. Be explicit; don’t rely on auto-detection.

### 6.3 `filter_jit` over `jit`

Always use `eqx.filter_jit`, never raw `jax.jit`, on a `JaxOperator` or `JaxSequential`. The filter handles non-array fields cleanly; raw `jit` raises `TypeError` for any non-JAX leaf.

### 6.4 `eqx.tree_at` for surgery

To swap one operator in a `JaxSequential` for an updated version (e.g. fine-tune just the matched filter step inside an otherwise frozen pipeline):

```python
new_seq = eqx.tree_at(
    lambda s: s.operators[3],   # path to the operator to replace
    sequential,
    replace=updated_matched_filter,
)
```

Document this pattern. It replaces the need for any pipekit-side mutation API.

### 6.5 `eqx.nn.Sequential` vs `JaxSequential`

Equinox already ships `eqx.nn.Sequential`. Why a `JaxSequential`? Because:

- `eqx.nn.Sequential` doesn’t have pipekit’s dual-mode dispatch (eager / symbolic), introspection, `summary()`, `describe()`, YAML serialisation, or `from_state`.
- It does have what we need for PyTree integration.

So `JaxSequential` = pipekit’s `Sequential` + tuple-of-operators-as-PyTree + Equinox Module mixin. Strictly a superset of `eqx.nn.Sequential` for our purposes.

### 6.6 The PyTree-as-tree issue with diamond Graphs

From §1.3: PyTrees are trees not DAGs. A `Graph` with a node that feeds two downstream nodes (diamond) has the intermediate stored once but referenced twice. As a *runtime computation* this is fine. As a *PyTree leaf* this is a footgun.

Recommendation: `JaxGraph` is jit-able and vmap-able (as a callable), but is **not itself a PyTree leaf inside a larger structure**. If you need a Graph inside an Equinox model, use `eqx.nn.Shared` or wrap the Graph in a single-leaf wrapper.

## Part 7 — Use cases this unlocks

What `pipekit-jax` makes possible that pipekit alone doesn’t:

### 7.1 Differentiable retrievals (the headline)

Matched filter, BAEMR, IME — any retrieval algorithm where the parameters are currently hand-tuned can become trainable end-to-end. Differentiate the loss back through the full pipeline; let the optimiser adjust the target spectrum, the regularisation, the cloud-mask threshold. Real value for MARS where ground-truth labels exist for known plumes.

### 7.2 Learnable corrections to physics-based pipelines

The pure-physics pipeline (radiometric correction → matched filter) gives a baseline. Add a learnable neural net correction at the end. Train end-to-end on labels. The physics provides the prior; the correction handles known systematics the physics can’t capture (sensor-specific calibration drift, scene-content-dependent biases).

### 7.3 JIT-compiled inference paths

LitServe / FastAPI deployments where the same `Sequential` runs millions of times per day. JIT compilation gives 5-50x speedup over Python-loop execution. Real cost savings for MARS.

### 7.4 vmap-batched scene processing

Process 100 EMIT scenes simultaneously in a single XLA kernel. Useful for backfills, reprocessing, and batch QC.

### 7.5 Device-parallel inference

Shard a batch across 8 GPUs via `pmap` or `shard_map`. Real throughput multiplier for operational reprocessing of historical archives.

### 7.6 Hyperparameter sweeps via vmap over operator pytrees

Instantiate 100 versions of a `JaxSequential` with different thresholds. vmap them. Run the entire sweep in one compiled kernel. Tradeoff: compile time grows, but for small parameter spaces this is dramatically faster than running the loop in Python.

## Part 8 — When to build it

**Not v0.1.** Pipekit’s design isn’t yet stable; building a JAX variant on a moving target is wasted work.

**Not v0.2.** Pipekit-array against the Array API standard is the right v0.2 target. Once that’s stable, the *carrier* abstraction settles, and `pipekit-jax` has a stable foundation.

**v0.3 or later.** Realistically, when a specific MARS project demands one of:

- Differentiable retrieval (a research project drives this)
- Operational JIT inference at sufficient scale that Python overhead becomes the bottleneck
- Device-parallel reprocessing (a multi-year archive backfill)

Estimate: 2-3 weeks of focused work once the requirements are concrete. Most of the framework code is reused from pipekit; what’s new is ~10-15 JAX-flavoured operator variants, the `lax.cond`-based control flow, and the `eqx.Module` mixin.

## Part 9 — Recommendations

1. **Build on pipekit, don’t fork.** Option A from §2. Multiple inheritance with `eqx.Module` is clean; cross-library composition is valuable.
2. **Be honest about what’s debug-only.** `Tap`, `Sink`, `Snapshot`, `Profile` all become debug-mode-only under jit. Document this clearly; don’t pretend they work.
3. **Replace `Branch` / `Switch` / `ProcessMap` with JAX-native equivalents.** Don’t try to make the pipekit versions work under jit — the abstractions are different.
4. **Use Equinox idioms unmodified.** `eqx.field(static=True)`, `filter_jit`, `filter_grad`, `tree_at`. Don’t reinvent.
5. **Document the build-time vs trace-time distinction up front.** Most JAX bugs in a framework like this come from users not understanding when their code runs. A “JAX literacy” section in the docs is mandatory.
6. **Defer until a project demands it.** Differentiable retrievals are exciting but not the current bottleneck. Build it when there’s a concrete use case driving the work.
7. **Correct my prior nonsense.** The earlier reports said JAX `@jit` is “fundamentally incompatible” with pipekit’s dispatch. It’s not. The dispatch works fine because tracers aren’t Nodes. The real incompatibilities are about what’s inside `_apply`, and the list is manageable (covered in §4).

## Where this leaves the four-library structure

The updated map:

```
pipekit (core, v0.1)
├── pipekit-array (v0.2, Array API for numpy/JAX/CuPy/PyTorch as arrays)
├── geotoolz (refactored v0.2)
├── xr_toolz (refactored v0.2)
└── pipekit-jax (v0.3+, Equinox-backed, differentiable)
    └── jax_geotoolz (v0.3+, JAX-traceable GeoTensor operators)
```

`pipekit-jax` is the JAX framework layer. A future `jax_geotoolz` would be the domain layer that ships JAX-traceable versions of the geotoolz operators (where it makes sense — many domain ops are inherently Python-loop-shaped and don’t port).

The honest scope: `pipekit-jax` is ~600-800 LOC of JAX-flavoured operators on top of pipekit. Small library, big enabling power, deferred until needed.