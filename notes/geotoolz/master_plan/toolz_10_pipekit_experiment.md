---
title: "Report 12 — `pipekit-experiment`: experiment tracking and model registry"
subject: geotoolz master plan
short_title: "R12 — pipekit-experiment"
authors:
  - name: J. Emmanuel Johnson
    affiliations:
      - UNEP
      - IMEO
      - MARS
    orcid: 0000-0002-6739-0053
    email: jemanjohnson34@gmail.com
license: CC-BY-4.0
keywords: geotoolz, pipekit-experiment, experiment-tracking, model-registry, mlflow
---

# Report 12 — `pipekit-experiment`: experiment tracking and model registry

|                       |                                                                                                                                                                                                   |
|-----------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|**Status**             |Scoping proposal — committed                                                                                                                                                                       |
|**Reading time**       |~18 min                                                                                                                                                                                            |
|**Decisions locked in**|Thin adapter layer over external orchestration tools (MLflow, DVC, Hydra, W&B), not a from-scratch experiment tracker. Model registry is content-addressed and pipekit-aware. Monorepo development.|
|**Audience**           |Anyone reviewing the bridge between pipekit pipelines and orchestration/serving tiers                                                                                                              |
|**Companion reports**  |Report 10 (`pipekit-cycle`), Report 11 (`pipekit-train`), Report 13 (`statecatalog`)                                                                                                               |

## Part 1 — Where `pipekit-experiment` sits in the stack

The user’s six-tier model explicitly puts **orchestration** (Metaflow, MLflow, DVC, Hydra) and **serving** (FastAPI, LitServe) outside the owned stack. Pipekit-experiment is the **boundary between owned pipeline infrastructure and external orchestration tools** — the thin adapter layer that lets pipekit pipelines play nice with whatever tracker / scheduler the user has chosen, without leaking those tools’ idioms into the pipeline code.

```
   Serving (external)         FastAPI │ LitServe │ Fused
                                  ▲
                                  │
   Orchestration (external)   MLflow │ DVC │ Hydra │ W&B │ Metaflow
                                  ▲
                                  │
                          ┌── pipekit-experiment ── (this report)
                          │   adapters/        ←─ thin glue per tool
                          │   registry         ←─ content-addressed models
                          │   artifacts        ←─ versioned training/inference records
                          ▼
   Infrastructure         pipekit-cycle  pipekit-train
                                  ▲
                                  │
   Framework                  pipekit ◄── pipekit-array
```

Three principles:

1. **Pipekit owns pipelines and artifacts; external tools own scheduling, UI, and storage.** Pipekit-experiment is the *adapter*, not a replacement. If you have MLflow already, pipekit-experiment talks to it; you don’t rebuild experiment tracking.
2. **The model registry is content-addressed.** A trained model is identified by `hash(training_config, dataset_content, weights)`. Loading by hash is the canonical path. Names (`"methane_emulator_v3"`) are convenience tags over hashes.
3. **The same training run can flow to multiple trackers.** Same `pipekit-train.TrainingLoop` logs to MLflow + W&B + DVC simultaneously via stacked adapters. No tool lock-in.

## Part 2 — What’s in `pipekit-experiment`

Four conceptual pieces, ~500 LOC total.

### 2.1 Source layout

```
pipekit-experiment/
  __init__.py             # public re-exports
  _src/
    protocols.py          # ExperimentTracker, ModelRegistry Protocols
    run.py                # Run, RunMetrics, RunArtifacts
    registry.py           # base ModelRegistry, S3ModelRegistry, LocalModelRegistry
    artifacts.py          # TrainingArtifact, InferenceArtifact (parallel to pipekit.repro.Artifact)
    adapters/
      __init__.py
      mlflow.py           # MLflowTracker, MLflowModelRegistry
      dvc.py              # DVCDatasetVersioning
      hydra.py            # HydraConfigLoader
      wandb.py            # WandbTracker
      metaflow.py         # MetaflowStepAdapter
```

### 2.2 The two protocols (`protocols.py`)

The seam between pipekit and external tools.

```python
@runtime_checkable
class ExperimentTracker(Protocol):
    """Log metrics, parameters, and artifacts from a training run.
    
    Implementations wrap external trackers: MLflow, W&B, ClearML, etc.
    """
    def start_run(self, name: str, config: dict) -> "Run": ...
    def log_metrics(self, run: "Run", metrics: dict, step: int): ...
    def log_artifact(self, run: "Run", path: str, name: str): ...
    def end_run(self, run: "Run", status: str): ...

@runtime_checkable
class ModelRegistry(Protocol):
    """Store and retrieve trained models by content hash.
    
    Implementations: S3-backed, MLflow-backed, local-filesystem, etc.
    """
    def store(self, model_op: Operator, *, name: str | None = None, 
              tags: dict | None = None) -> str:
        """Return the content hash of the stored model."""
    def load(self, ref: str) -> Operator:
        """ref is either a hash or a name (which resolves to a hash)."""
    def list(self, *, tags: dict | None = None) -> list[str]: ...
    def tag(self, hash: str, name: str): ...
```

Both protocols are runtime-checkable. Adapters satisfy them structurally; no inheritance from pipekit-experiment required.

### 2.3 Runs and metrics (`run.py`)

```python
class Run:
    """A single execution of a pipeline (training or inference).
    
    Identified by run_id (tracker-assigned) and pipeline_hash (pipekit-derived).
    Carries metrics, config, artifacts, and provenance.
    """
    run_id: str
    pipeline_hash: str
    config: dict
    metrics: dict
    artifacts: dict[str, str]      # name -> URI
    started_at: datetime
    ended_at: datetime | None
    status: Literal["running", "completed", "failed"]

class RunMetrics:
    """Per-step metrics, paired with a Run."""
    values: dict[str, list[tuple[int, float]]]   # name -> [(step, value), ...]

    def log(self, name: str, value: float, step: int): ...
    def to_dataframe(self) -> pd.DataFrame: ...

class RunArtifacts:
    """Named artifacts (files, models, plots) attached to a Run."""
    items: dict[str, str]   # name -> URI
    
    def attach(self, name: str, source: str | Path | Operator): ...
```

### 2.4 The model registry (`registry.py`)

```python
class S3ModelRegistry:
    """S3-backed model registry. Content-addressed.
    
    Storage layout:
        s3://bucket/models/<hash>/model.bin      # serialized weights
        s3://bucket/models/<hash>/operator.yaml  # pipekit Operator config
        s3://bucket/models/<hash>/metadata.json  # tags, training_run_id, etc.
        s3://bucket/models/_tags/<name>.txt      # name -> hash mapping
    """
    bucket: str
    prefix: str = "models/"
    
    def store(self, model_op: Operator, *, name=None, tags=None) -> str:
        h = self._compute_hash(model_op)
        # Serialize operator config + weights, upload to S3
        # If name provided, create/update the tag
        return h
    
    def load(self, ref: str) -> Operator:
        h = self._resolve(ref)   # tag -> hash if needed
        config = self._load_config(h)
        weights = self._load_weights(h)
        return Operator.from_state(config).with_weights(weights)

class LocalModelRegistry:
    """Local-filesystem version. Useful for dev, CI tests."""
    root: Path

class MLflowModelRegistry:
    """MLflow Model Registry adapter — uses MLflow's built-in model
    versioning. Names map to MLflow model names; hashes map to versions.
    """
```

### 2.5 The training artifact (`artifacts.py`)

Parallel to `pipekit.repro.Artifact` (use case 9, the regulatory snapshot). Difference: training artifacts include the training dataset hash + tracker references.

```python
class TrainingArtifact:
    """Reproducibility artifact for a training run.
    
    Includes:
    - The TrainingLoop YAML (from pipekit-train)
    - The dataset content_hash
    - The trained model hash
    - The tracker run_id (MLflow / W&B reference)
    - The model registry URI
    - Backend info (Lightning version, JAX version, hardware)
    - Lockfile (poetry.lock / uv.lock)
    """
    training_pipeline_yaml: str
    dataset_hash: str
    trained_model_hash: str
    tracker_run_id: str | None
    model_registry_uri: str
    backend_info: dict
    deps_lock: str
    metadata: dict
    
    def save(self, path: str): ...
    @classmethod
    def load(cls, path: str) -> "TrainingArtifact": ...
    def rerun(self) -> Operator:
        """Re-execute the training pipeline from scratch.
        Returns the freshly trained model_op.
        """
    def reload_model(self) -> Operator:
        """Load the stored model from the registry — no retraining."""

class InferenceArtifact(pk.repro.Artifact):
    """Subclass of pipekit.repro.Artifact that additionally pins the
    model registry version of any ModelOp in the pipeline.
    
    Bridges the regulatory artifact story (use case 9) with the model
    registry — inference artifacts re-create their models by hash.
    """
    pinned_model_hashes: dict[str, str]   # operator_path -> model_hash
```

## Part 3 — The adapters

Each adapter is ~100-150 LOC. Pure translation: pipekit constructs → tool’s API.

### 3.1 `adapters/mlflow.py`

```python
class MLflowTracker:
    """Wraps mlflow.tracking client. Satisfies ExperimentTracker protocol."""
    tracking_uri: str
    experiment_name: str
    
    def start_run(self, name, config):
        run = mlflow.start_run(experiment_id=self._experiment_id, run_name=name)
        mlflow.log_params(_flatten(config))
        return Run(run_id=run.info.run_id, ...)
    
    def log_metrics(self, run, metrics, step):
        with mlflow.start_run(run_id=run.run_id):
            mlflow.log_metrics(metrics, step=step)
    # ...
```

### 3.2 `adapters/dvc.py`

DVC is fundamentally about data versioning, not metrics. The adapter focuses on **dataset content-hash tracking**:

```python
class DVCDatasetVersioning:
    """Track dataset content hashes via DVC's content-addressed storage.
    
    Use case: a TrainingDataset's content_hash() returns "ab12cd...";
    this adapter ensures the actual data at that hash is in DVC's
    storage (.dvc/cache or remote). At rerun time, DVC reproduces
    the dataset from the hash.
    """
    repo: str
```

### 3.3 `adapters/hydra.py`

Hydra is config-management, not tracking. The adapter is one-way: convert a Hydra config into a pipekit operator graph.

```python
class HydraConfigLoader:
    """Convert Hydra config into pipekit operator graph.
    
    pipekit YAML and Hydra config are similar but not identical;
    this adapter bridges them. Useful when the team standardizes
    on Hydra for everything-but-pipekit (or vice versa).
    """
    @staticmethod
    def from_hydra_cfg(cfg) -> Operator: ...
    @staticmethod  
    def to_hydra_cfg(op: Operator) -> Any: ...
```

### 3.4 `adapters/wandb.py`

```python
class WandbTracker:
    """W&B adapter. Satisfies ExperimentTracker protocol."""
    project: str
    entity: str | None = None
    # parallel to MLflowTracker
```

### 3.5 `adapters/metaflow.py`

Metaflow is workflow orchestration. The adapter wraps a pipekit pipeline as a Metaflow step.

```python
class MetaflowStepAdapter:
    """Wrap a pipekit pipeline as a Metaflow @step.
    
    Pipekit handles the compute; Metaflow handles scheduling,
    dependency tracking across steps, and artifact storage.
    """
    @staticmethod
    def as_step(op: Operator, *, name: str, inputs: list[str]): ...
```

## Part 4 — Worked examples

### 4.1 Training with MLflow tracking

```python
import pipekit_train as pt
import pipekit_experiment as pe

tracker = pe.adapters.mlflow.MLflowTracker(
    tracking_uri="http://mlflow.imeo.local",
    experiment_name="methane_emulator",
)

loop = pt.TrainingLoop(
    model_op=...,
    dataset=...,
    loss=pt.MSE(),
    optimizer_config={"name": "adam", "lr": 1e-3},
    n_epochs=100,
    backend="lightning",
    callbacks=[
        pt.LogToExperiment(tracker=tracker),   # ← adapter plugged in here
        pt.Checkpoint(every_n_epochs=10),
    ],
)

trained_op = loop.run()
# MLflow now shows: hyperparameters, per-epoch loss, val metrics, final model artifact
```

### 4.2 Model registry + reuse

```python
import pipekit_experiment as pe

# After training, store the model
registry = pe.S3ModelRegistry(bucket="imeo-models", prefix="emulators/")
hash = registry.store(trained_op, name="methane_emulator_v3", tags={
    "domain": "atm_chemistry",
    "training_dataset_hash": "ab12cd...",
    "validation_rmse": 0.04,
})

# Later, in an inference pipeline — load by name
import pipekit_cycle as pc

emulator = registry.load("methane_emulator_v3")   # resolves name to hash

forecast = pc.Cycle(step_op=pc.NeuralForward(model_op=emulator, dt=3600.0),
                    n_steps=72)
trajectory = forecast(initial_state, initial_carry_state)
```

### 4.3 Stacked tracking (MLflow + W&B simultaneously)

```python
loop = pt.TrainingLoop(
    ...,
    callbacks=[
        pt.LogToExperiment(tracker=pe.adapters.mlflow.MLflowTracker(...)),
        pt.LogToExperiment(tracker=pe.adapters.wandb.WandbTracker(...)),
    ],
)
# Logs to both trackers per epoch
```

### 4.4 Reproducibility artifact for a trained model

```python
artifact = pe.TrainingArtifact(
    training_pipeline_yaml=loop.to_yaml(),
    dataset_hash=loop.dataset.content_hash(),
    trained_model_hash=hash,
    tracker_run_id="mlflow://runs/abc123",
    model_registry_uri="s3://imeo-models/emulators/methane_emulator_v3",
    backend_info={"backend": "lightning", "lightning_version": "2.4.0", ...},
    deps_lock=open("uv.lock").read(),
    metadata={"author": "ej", "date": "2026-Q2"},
)
artifact.save("/regulatory/methane_emulator_v3.training.artifact")

# 2 years later
art = pe.TrainingArtifact.load("/regulatory/methane_emulator_v3.training.artifact")
fresh_model_op = art.rerun()           # full retrain
loaded_model_op = art.reload_model()   # load stored weights
```

### 4.5 Pipeline-driven Metaflow flow

```python
from metaflow import FlowSpec, step
import pipekit_experiment as pe

class MethaneFlow(FlowSpec):
    @step
    def preprocess(self):
        preprocess_op = pe.adapters.hydra.HydraConfigLoader.from_hydra_cfg(cfg.preprocess)
        # ... run preprocess_op
    
    @step
    def train(self):
        # Use the adapter to wrap a pipekit training pipeline as a Metaflow step
        result = pe.adapters.metaflow.MetaflowStepAdapter.run(loop)
        self.model_hash = result.model_hash
    
    @step
    def evaluate(self):
        model = registry.load(self.model_hash)
        # ... evaluate
```

## Part 5 — The model registry deserves a dedicated section

Of everything in this report, **the model registry is the most consequential structurally**. It’s the artifact that lets train→serve loops close.

### 5.1 Why content-addressed

A name (`"methane_emulator_v3"`) is mutable. A hash (`"ab12cd..."`) is not. Production deployment artifacts that pin “this model” should pin the hash; UIs / users can use names that resolve to hashes.

This mirrors content-addressing in your existing `pipekit.repro.Artifact` story and in the regulatory case 9. Consistent across the stack.

### 5.2 What a stored model contains

```
s3://bucket/models/<hash>/
  operator.yaml      # pipekit Operator config — architecture, hyperparameters
  weights.bin        # serialized trained weights
  metadata.json      # tags, training_run_id, validation metrics, hardware
  preview.json       # representative input/output examples for sanity checks
```

The `operator.yaml` is the pipekit Operator config (architecture). The `weights.bin` is backend-specific (PyTorch `.pt`, JAX serialized PyTree, Keras `.keras`). At load time, the registry reconstructs the operator from `operator.yaml` and rebinds the weights.

### 5.3 Loading semantics

```python
op = registry.load("methane_emulator_v3")
# Equivalent to:
op = registry.load(registry.resolve_tag("methane_emulator_v3"))
# Which is:
config = read_yaml("s3://.../<hash>/operator.yaml")
weights = read_bytes("s3://.../<hash>/weights.bin")
op = Operator.from_state(config)
op = op.with_weights(weights)
```

The `with_weights` step is backend-specific. For `pipekit-array.ModelOp` it loads via `torch.load` / `jax.numpy.load` / etc.; for `pipekit-jax.JaxModelOp` it uses `eqx.tree_deserialise_leaves`.

### 5.4 Promotion / staging

The registry supports tags:

```python
registry.tag(hash_v3, "production")   # tag the production model
registry.tag(hash_v4, "candidate")    # tag the v4 candidate
registry.tag(hash_v4, "production")   # promote v4 to production (atomic)
```

Deployment configs reference `"production"`; the registry resolves to the current hash. Promotion is one API call.

This is the headline win for the train→serve loop: **promote a model from candidate to production without re-deploying any pipeline**. The pipeline YAML references `production`; the registry resolves to the right hash; LitServe / FastAPI pick up the new model on next worker recycle.

## Part 6 — Dependencies and optional extras

```toml
[project]
name = "pipekit-experiment"
version = "0.1.0"
dependencies = [
    "pipekit>=0.1",
]

[project.optional-dependencies]
# Adapters — pick what you use
mlflow   = ["mlflow>=2.10"]
wandb    = ["wandb>=0.16"]
dvc      = ["dvc>=3.30"]
hydra    = ["hydra-core>=1.3", "hydra-zen>=0.13"]
metaflow = ["metaflow>=2.10"]

# Model registry backends
s3       = ["fsspec>=2024.0", "s3fs>=2024.0"]
mlflow-registry = ["mlflow>=2.10"]

# Training integration
train    = ["pipekit-train>=0.1"]

all      = ["pipekit-experiment[mlflow,wandb,dvc,hydra,s3,train]"]
```

Minimum install: the protocols + LocalModelRegistry. Real-world users pick the adapters matching their orchestration tools.

## Part 7 — Honest tradeoffs

### 7.1 What gets better

1. **Tool independence.** Same pipekit code logs to MLflow today, W&B tomorrow, ClearML next year. No rewrites.
2. **Train→serve loop closes.** Trained models are first-class artifacts that drop into inference pipelines via the registry.
3. **Regulatory + training reproducibility unifies.** Same artifact mechanism for inference (use case 9) and training (this report). One pattern.
4. **Promotion is atomic.** Tag-based promotion lets candidates ride alongside production without code changes.
5. **No tool idioms leak.** MLflow’s “experiment” concept stays in MLflow; pipekit pipelines don’t import mlflow.

### 7.2 What gets harder

1. **Multiple adapter implementations to maintain.** Each tool has its own API churn. Mitigation: pin tool versions in extras; have CI catch drift.
2. **The model registry has real operational concerns.** Garbage collection of unused models, S3 cost management, hash collisions (vanishingly unlikely but) — all need policies. Mitigation: ship a `registry.gc()` operation in v0.1; document the policies.
3. **Names-as-tags is a foot-gun.** If a name silently moves between hashes, deployments that “use production” change underfoot. Mitigation: log every tag move; require explicit `force=True` to retag; default to write-once tags.
4. **`with_weights` is backend-specific.** Loading a model isn’t uniform across PyTorch / JAX / Keras / sklearn. Mitigation: each `ModelOp` subclass implements its own `with_weights`; the registry doesn’t try to be backend-neutral at the weights layer.

### 7.3 What doesn’t fit and isn’t tried

- **Model evaluation as a service.** Pipekit-experiment tracks runs; it doesn’t run evaluations. That’s pipekit + pipekit-train + an evaluation pipeline.
- **A/B testing in production.** That’s the deployment layer (use case 13).
- **Drift detection.** Out of scope; lives in monitoring tooling.
- **Cost tracking.** Some trackers (W&B, MLflow) do this; the adapter passes through.

## Part 8 — Effort and timing

### 8.1 Effort

- **Day 1**: `protocols.py`, `run.py` — the Run / metrics / artifact base classes.
- **Day 2-3**: `registry.py` — `LocalModelRegistry`, `S3ModelRegistry`. The content-addressing logic is the core; test thoroughly.
- **Day 4-5**: `adapters/mlflow.py` — first adapter, since MLflow is the most common starting point.
- **Day 6**: `artifacts.py` — `TrainingArtifact`, `InferenceArtifact`.
- **Day 7**: `adapters/wandb.py` — second adapter.
- **Day 8-9**: `adapters/dvc.py`, `adapters/hydra.py` — pick based on what’s in actual use.
- **Day 10**: Documentation, integration tests with pipekit-train.

**Total: ~2 weeks** for v0.1. Each additional adapter is ~1-2 days.

### 8.2 Timing

Ship **after** pipekit-train (Report 11) is stable. Pipekit-experiment depends on:

- `pipekit-train.TrainingLoop` (for `LogToExperiment` callback integration)
- `pipekit.repro.Artifact` (for `InferenceArtifact` subclass)

Realistic: v0.4 of the ecosystem.

### 8.3 What this unblocks

1. **Trained models become reusable across pipelines.** Train once; load by hash; deploy anywhere.
2. **MLflow / W&B / DVC plug in without leaking into pipeline code.** Adapter pattern keeps pipekit clean.
3. **Promotion workflows.** Tag-based promotion of candidate → production is one API call.
4. **The regulatory artifact (use case 9) extends to training.** Same pattern; broader coverage.
5. **Cross-team collaboration.** A team using MLflow can hand a model to a team using W&B; the registry is the lingua franca.

## Part 9 — Recommendation

**Ship `pipekit-experiment` as a separate sister package.** Signals:

- Heavy external-tool dependencies (mlflow, wandb, dvc, hydra) — pipekit core can’t take these on
- Multiple adapter implementations — separation lets users install only what they use
- Independent release cycles from pipekit core — orchestration tools churn faster
- Adapter pattern parallels `geopatcher.integrations.pipekit` — consistent across the ecosystem

Lives in `packages/pipekit-experiment/`. Sibling of `pipekit-cycle` and `pipekit-train`.

This is the **bridge from owned pipeline infrastructure to external orchestration**. Without it, every team using a different tracker writes their own glue. With it, the orchestration tier becomes a clean external boundary, traversed through a small, stable adapter surface.

The model registry, in particular, is the **single most consequential artifact** for the train→serve loop. Building it right (content-addressed, hash-resolvable, with atomic tag promotion) unblocks the operational ML story across the stack.