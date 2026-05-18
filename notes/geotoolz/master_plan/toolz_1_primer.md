---
title: "Report 1 — Background: `toolz` lineage and typed entities"
subject: geotoolz master plan
short_title: "R1 — Primer"
authors:
  - name: J. Emmanuel Johnson
    affiliations:
      - UNEP
      - IMEO
      - MARS
    orcid: 0000-0002-6739-0053
    email: jemanjohnson34@gmail.com
license: CC-BY-4.0
keywords: geotoolz, pipekit, toolz, primer, background, typed-entities
---

# Report 1 — Background: `toolz` lineage and the trajectory to typed entities

|                     |                                                                                            |
|---------------------|--------------------------------------------------------------------------------------------|
|**Status**           |Background / motivation                                                                     |
|**Reading time**     |~15 min                                                                                     |
|**Audience**         |Anyone reviewing the pipekit design before the structural sections                          |
|**Companion reports**|Report 2 (pipekit shipped surface), Report 3 (sister libraries), Report 4 (use-case revisit)|

## Why this report exists

The pipekit design will make more sense if the reader first sees **what we inherited from `toolz`**, **what that inheritance can’t do**, and **why the progression from “any function” → “Protocol-typed” → “concrete typed entity” is correct rather than over-engineered**. This report is the motivation layer. No code lands here; the surface and the operators live in Report 2.

## Part 1 — `toolz` as the ancestor

[`pytoolz/toolz`](https://github.com/pytoolz/toolz) is the explicit intellectual ancestor of pipekit. Looking at it directly is the fastest way to see what idea we’re carrying forward and what we’re adding.

### 1.1 The `toolz.functoolz` surface

The directly relevant functions:

|`toolz` primitive                 |One-line meaning                                 |
|----------------------------------|-------------------------------------------------|
|`identity(x)`                     |Pass-through                                     |
|`pipe(value, *funcs)`             |Apply functions left-to-right to a value         |
|`compose(*funcs)`                 |Right-to-left function composition (`f(g(h(x)))`)|
|`compose_left(*funcs)`            |Left-to-right function composition               |
|`juxt(*funcs)`                    |Multi-output: `juxt(f, g)(x) → (f(x), g(x))`     |
|`do(f, x)`                        |Run `f(x)` for side effect, return `x` unchanged |
|`complement(pred)`                |Negate a predicate                               |
|`excepts(exceptions, op, handler)`|Catch listed exceptions during application       |
|`memoize(func)`                   |Cache results by input                           |
|`curry`                           |Partial application as a class wrapper           |
|`thread_first` / `thread_last`    |Clojure-style threading macros                   |
|`flip(f, a, b) → f(b, a)`         |Argument flip                                    |

Plus `itertoolz` (~30 functions on iterables) and `dicttoolz` (~15 on dicts). Pipekit only really inherits from `functoolz`.

### 1.2 The mental model

`toolz` says: a pipeline is *a sequence of pure functions*. Compose them with `pipe()` or `compose()`. Each function is responsible for nothing except its transform; metadata, types, and effects are someone else’s problem.

```python
from toolz import pipe, do, juxt

pipe(
    "  HELLO  ",
    str.strip,
    str.lower,
    do(print),
    lambda s: s.split("l"),
)
# prints "hello"; returns ['he', '', 'o']
```

This is **functional composition over plain Python**. Functions are values, composition is an operation, side effects are explicit (`do`). It’s elegant and minimal, and it directly inspired the `|` syntax, the `Sequential` shape, the `Tap`/`Sink` distinction, and the multi-output `Fanout`/`juxt` family in your libraries.

### 1.3 Direct one-to-one mappings to pipekit

Almost every primitive we want in pipekit has a `toolz` ancestor. The mapping is so tight that **“pipekit = toolz, but each function is replaced by a typed class”** is the most accurate one-line description.

|`toolz` primitive     |pipekit equivalent                                              |What pipekit’s version adds                                                                |
|----------------------|----------------------------------------------------------------|-------------------------------------------------------------------------------------------|
|`pipe(value, *funcs)` |`Sequential(operators)(value)`                                  |Operators carry config; introspection; serialisation; reuse                                |
|`compose_left(*funcs)`|`op1 | op2 | op3`                                               |`__or__` flatten; `__repr__`; class-typed steps                                            |
|`compose(*funcs)`     |(reverse `__or__` order)                                        |Convenience for users who prefer mathematical-style composition                            |
|`do(f, x)`            |`Tap(fn)`, `Sink(write_fn)`                                     |Closures are owned by the `Operator`; serialisable name; `forbid_in_yaml = True` discipline|
|`juxt(f, g, h)`       |`Fanout({"f": f, ...})` (dict-keyed); `juxt(f, g)` (tuple-keyed)|Both shapes; named outputs for downstream consumers                                        |
|`memoize`             |`Cache` / `Memoize` (deferred in geotoolz idioms)               |Hit / miss counters; config-aware hashing                                                  |
|`excepts`             |`Try` / `Fallback` (deferred in geotoolz idioms)                |Operator-shaped arms; explicit exception list                                              |
|`complement`          |(gap)                                                           |Predicate negation utility — currently missing from both libraries                         |
|`identity`            |`Identity` Operator                                             |Class-based; composes everywhere                                                           |
|`curry`               |Implicit in `__init__`                                          |Operators *are* curried constructors                                                       |

`toolz` is the design template. Pipekit is the typed, introspectable, serialisable variant of the same idea.

## Part 2 — Where `toolz` stops being enough

`toolz` handles function-composition mechanics cleanly. What it lacks, and why your domain libraries needed something more:

### 2.1 No introspection

```python
pipe = compose_left(strip, lower, lambda s: s.split("-"))
print(pipe)
# <function compose_left.<locals>.composition at 0x...>
```

No `__repr__` listing steps. No way to ask “what’s step 3?” No per-step state to inspect. For interactive shell work that’s fine; for a 14-step preprocessing pipeline that needs to be auditable, it’s painful.

### 2.2 No serialisation

`toolz` pipelines are tuples of function references and closures. They don’t round-trip to YAML, JSON, or a Hydra config. You can’t ship a pipeline over the wire to a worker process and have it reconstruct cleanly. Every deployment shape in the [usecases gallery](https://github.com/jejjohnson/research_journal_v2/blob/main/notes/geotoolz/plans/geotoolz/examples/usecases.md) (ETL, LitServe API, FastAPI service, tile server, regulatory artifact, orchestrator) needs serialisation in some form. `toolz` can’t supply it.

### 2.3 No dual-mode dispatch

`toolz` functions only run eagerly. You can’t pass a symbolic placeholder through them to build a graph that’s executed later. Graph-building (the `Input` / `Node` symbolic API in geotoolz and xr_toolz) requires the *same callable* to behave differently depending on whether its input is data or a symbolic placeholder. That dispatch has nowhere to live in `toolz`.

### 2.4 No control-flow operators in the composition language

`Branch` / `Switch` exist in `toolz`-style pipelines as Python `if` / `match` statements — they sit *outside* the pipeline, not inside it. The pipeline gets broken apart whenever a conditional is needed. Pipekit treats conditionals as first-class operators (`Branch`, `Switch`, `Try`, `Coalesce`), composable inside `Sequential` like any other step.

### 2.5 No carrier shape tracking

Every `toolz` step is `Any → Any`. Two consequences for remote-sensing / geoscience use:

- xarray’s named dimensions and your `GeoTensor`’s spatial metadata have structure worth surfacing — `Signature` shape inference lets `Sequential.summary()` produce Keras-style structural tables that catch shape mismatches at construction time, not at runtime, deep in a hot loop.
- Without shape tracking, debugging a broken pipeline means stepping through with a debugger to find which transform produced the wrong dimensions. With shape inference, the summary tells you immediately.

### 2.6 No discipline against closure capture

`toolz` accepts any closure. That’s correct for interactive scripting. It’s ruinous for production pipelines that need to be auditable: a closure cannot be inspected for what it captures, cannot be serialised, cannot be reconstructed on a worker. Geotoolz’s `forbid_in_yaml = True` is the codified discipline — operators that hold closures (`Tap`, `Lambda`, `Branch`, `Switch`, `Sink`, `ModelOp`) declare it explicitly, and a future YAML loader can refuse them.

### 2.7 Summary

Each of these six gaps is real. Each is what `toolz` cannot give us. Each is what pipekit is built to provide.

The header for the whole report: **pipekit is what `toolz` becomes when you take the pipeline seriously as a first-class object — repr-able, config-able, summary-able, dispatchable, and bound to discipline about what’s inside it.**

## Part 3 — The trajectory: functions → Protocols → typed entities

You asked specifically about the trajectory from raw functions, through Protocols, to typed entities. The honest answer is that the trajectory looks different depending on whether you’re talking about **operators** or **carriers**, so I’ll do both separately.

### 3.1 The operator-side trajectory

For the things in a pipeline (the steps):

#### Stage 1 — functions

The `toolz` shape. An operator is a Python function. Maximum flexibility, zero boilerplate.

```python
def my_op(x):
    return ...

pipe(value, my_op, other_op, third_op)
```

**Buys you.** Adapt any existing function trivially. No subclassing. No import dependencies beyond `toolz` itself.

**Costs you.** No config. No `__repr__`. No serialisation. No dispatch. No flags. No state. No reuse beyond Python-function-reuse.

#### Stage 2 — Protocols

A natural next thought: “let me write a `Protocol` for what an operator looks like.”

```python
from typing import Protocol

class OperatorLike(Protocol):
    def __call__(self, x): ...
    def get_config(self) -> dict: ...
```

Anything structurally compatible counts. No inheritance required.

**Buys you.** Structural typing. Tools can recognise “this thing is operator-shaped” without forcing inheritance. Friendly to third-party code that doesn’t import your library.

**Costs you.** A Protocol is a *check*, not a *base class*. Specifically:

- **You can’t provide default implementations.** Every implementer rebuilds `get_config`, `__repr__`, `__or__`, etc. from scratch. No `super().__call__()` to reuse.
- **You can’t host class-level flags.** `forbid_in_yaml = True` and `_terminal = True` are class-level metadata that says something about the operator’s *contract*, not its instances. Protocols can’t carry contract-level metadata cleanly.
- **You can’t host shared mechanism.** Dual-mode `__call__` dispatch (eager-vs-symbolic, based on whether the argument is a `Node`) is shared infrastructure that every operator wants. Protocol-typed operators each reimplement it.
- **You can’t walk subclasses.** `Operator.from_state(state_dict)` needs to find the right concrete class to reconstruct. With a Protocol there’s no class registry to walk.

**Verdict.** Protocols are the right answer for *type-checking* an operator interface (“does this look operator-shaped?”) but the wrong answer for *being* an operator base (“here’s the operator infrastructure for free”).

#### Stage 3 — concrete typed base class

Where both `geotoolz.core` and `xr_toolz.core` have actually landed:

```python
class Operator:
    forbid_in_yaml: ClassVar[bool] = False
    _terminal: ClassVar[bool] = False

    def __call__(self, *args, **kwargs):
        # Dual-mode dispatch: eager vs symbolic
        ...

    def _apply(self, *args, **kwargs):
        raise NotImplementedError

    def get_config(self) -> dict:
        return {}

    def __or__(self, other):  # pipe syntax
        ...

    @classmethod
    def from_state(cls, state):  # walks subclasses to reconstruct
        ...
```

**Buys you.**

- `__init__` carries config naturally; `get_config()` exposes it; `from_state` reconstructs from it.
- `__or__` is defined once in the base; every subclass gets pipe-syntax for free.
- Dual-mode `__call__` is defined once; subclasses only implement `_apply`.
- Class-level flags (`forbid_in_yaml`, `_terminal`) are visible to `Sequential` validation and to future YAML loaders.
- `__init_subclass__` and `cls.__subclasses__()` give you a class registry for `from_state`.
- IDE / static-analysis tools see the full surface and offer completions, signature help, etc.

**Costs you.**

- Subclassing overhead — `class NDVI(Operator): ...` is more ceremony than a function.
- Can’t trivially adapt a third-party function — though `Lambda` is the escape hatch, and `ConfigMixin` (xr_toolz) reduces the boilerplate to almost nothing.
- More code surface to maintain in the framework.

**Verdict.** This is the right design for operators. Every “what does pipekit need to do” feature has a natural place to live, and the cost is a one-time decision to subclass. Both libraries landed here independently, which is the strongest signal that it’s correct.

### 3.2 The carrier-side trajectory

The carrier (the data flowing through the pipeline) is a *different* trajectory and is not yet settled.

#### Stage 1 — `Any`

The current pipekit-shaped libraries use `Carrier = Any`. The framework doesn’t care what’s flowing through; operators that need specific structure check at their own signatures.

**Buys you.** Maximum flexibility. The composition core works the same whether the carrier is a `GeoTensor`, an `xr.DataArray`, a numpy array, a scalar, or a custom user type. Test pipelines can run on scalars.

**Costs you.** Operators that *do* want structure (named axes, CRS, units) have to duck-check every time. No shared metadata surface.

#### Stage 2 — Protocols (`__array_namespace__`, `ArrayLike`, etc.)

The Python ecosystem has converged on Protocol-shaped carrier descriptions via the [Array API standard](https://data-apis.org/array-api/). `numpy.ndarray`, `jax.Array`, `cupy.ndarray`, `torch.Tensor`, and `dask.array.Array` all satisfy the same `__array_namespace__` Protocol.

A future pipekit could parameterise on this Protocol — operators that want array structure declare `Operator[ArrayLike]`, and the framework can statically check shape inference, dtypes, and so on across heterogeneous backends.

**Buys you.** Heterogeneous backends — write an operator once, have it work on numpy / JAX / CuPy / PyTorch arrays transparently. Real value for cross-framework pipelines.

**Costs you.** Adds Array API as a real dep. Operators have to be written against the Array API namespace (`xp.mean(x)`), not against numpy directly (`np.mean(x)`). Some operators are subtly framework-dependent and don’t generalise (e.g., NaN handling differs).

#### Stage 3 — Concrete typed carriers (`GeoTensor`, `xr.DataArray`, `xr.Dataset`)

The current state of geotoolz and xr_toolz. Operators are typed to a specific carrier. Maximum metadata exploitation; zero cross-library composability.

**Buys you.** Rich metadata used natively — `GeoTensor` operators reach for `.crs` and `.transform` without defensive checks; `xr_toolz` operators use `.dims` and `.coords` directly. Each library can specialise.

**Costs you.** Each library is locked to its carrier. No `Sequential([geotoolz_op, xr_toolz_op])` cross-library composition. Each carrier-specific operator must be written separately for each library.

### 3.3 Where pipekit lands on each axis

The honest framing:

**Operators: typed concrete classes.** Settled. Both libraries chose this. Pipekit ships an `Operator` base class.

**Carriers: pipekit doesn’t know or care.** `Carrier = Any` in the framework. Each domain library uses whatever carrier serves it — `GeoTensor` for geotoolz, `xr.DataArray` / `Dataset` for xr_toolz. Sister modules (Report 3) can introduce Array API Protocol-typed operators for multi-backend work without forcing pipekit to commit.

**The trajectory wasn’t “functions → Protocols → typed entities” as a single arc**. It was two separate trajectories that happened to share vocabulary:

- For operators: started at functions (toolz), considered Protocols, landed at typed concrete base classes. Correct.
- For carriers: still in flux. `Any` in pipekit core; concrete-typed in current domain libraries; Protocol-typed (Array API) in future sister modules.

Calling them out as one trajectory blurs the picture. Separating them is the right framing.

## Part 4 — One more piece of context: why typed entities for operators isn’t over-engineering

It’s worth being honest about why “I’ll just use functions” is tempting and why pipekit chooses not to.

**The argument for functions.** Less code. Faster to write. Familiar to anyone who’s used `toolz`. No subclassing ceremony. Pythonic.

**The argument for typed operators.** The six gaps in Part 2 don’t have function-shaped solutions. Every one of them needs **somewhere to live** — `get_config` on the operator, `forbid_in_yaml` on the class, dispatch in `__call__`, subclass walking in `from_state`. Functions are the wrong host for any of these.

The honest case for pipekit’s typed-entity design isn’t that classes are inherently better than functions. It’s that **the responsibilities pipekit takes on are class-shaped, not function-shaped**. If you removed the responsibilities — no introspection, no serialisation, no dispatch, no flags — you’d be left with `toolz`, and that’s a perfectly good answer for problems that fit it. Pipekit’s problems don’t.

## Where this leaves us

Report 2 takes this background and turns it into a concrete pipekit shipped surface. The shape is roughly:

- Toolz-style convenience functions for the toolz-familiar surface (`pipe`, `compose`, `juxt`, `complement`).
- A small typed-Operator base class plus enough machinery to host the six gaps above (`get_config`, `from_state`, `forbid_in_yaml`, `_terminal`, dual-mode dispatch, pipe-operator).
- A composition library on top: `Sequential`, `Graph`, `Fanout`, `Branch`, `Switch`.
- Observers, control flow, building blocks.
- Shape inference (`Signature`) and a parallelism story.

Report 3 covers the sister modules (`pipekit-numpy`-or-similar, geotoolz, xr_toolz).

Report 4 maps it all back to the 13 use cases in your usecases.md.