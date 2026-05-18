---
title: "GeoStack master plan"
subject: geotoolz master plan
short_title: "Master plan"
authors:
  - name: J. Emmanuel Johnson
    affiliations:
      - UNEP
      - IMEO
      - MARS
    orcid: 0000-0002-6739-0053
    email: jemanjohnson34@gmail.com
license: CC-BY-4.0
keywords: geotoolz, geostack, master-plan, navigation, reports
---

# GeoStack master plan

A set of scoping reports for the **GeoStack** — a JAX-native research software stack
for geophysical modeling, inference, and data assimilation. Each report is a deep
dive on one piece of the stack; together they describe the full picture.

If you are new here, **start with [Report 0](toolz_0_overview.md)** — the synthesis
document that weaves everything together. The companion vision document is
[The Idea (v3)](../supporting_info/geostack_vision.md), and the operational
discipline is described in [Report 16 — modeling cycle](../supporting_info/modeling_cycle.md).

## Navigation by report number

| Report                                                              | File                                                | Topic                                                       |
| ------------------------------------------------------------------- | --------------------------------------------------- | ----------------------------------------------------------- |
| [Report 0](toolz_0_overview.md)                                     | `toolz_0_overview.md`                               | The GeoStack — an introduction (start here)                 |
| [Report 1](toolz_1_primer.md)                                       | `toolz_1_primer.md`                                 | Background: `toolz` lineage and typed entities              |
| [Report 2](toolz_2_pipekit.md)                                      | `toolz_2_pipekit.md`                                | What `pipekit` will ship                                    |
| [Report 3](toolz_3_pipekit_array.md)                                | `toolz_3_pipekit_array.md`                          | Sister libraries on top of pipekit                          |
| _Report 4_                                                          | _(superseded — see Report 9)_                       | Original use-case mapping                                   |
| [Report 5](toolz_12_pipekit_jax.md)                                 | `toolz_12_pipekit_jax.md`                           | `pipekit-jax` — future-direction analysis                   |
| [Report 6](toolz_4_geocatalog.md)                                   | `toolz_4_geocatalog.md`                             | `geocatalog` — spatiotemporal index                         |
| [Report 7](toolz_5_geopatcher.md)                                   | `toolz_5_geopatcher.md`                             | `geopatcher` — four-axis patcher                            |
| _Report 8_                                                          | _(not yet written)_                                 | `xr-toolz` deep dive                                        |
| [Report 9](toolz_6_usecases.md)                                     | `toolz_6_usecases.md`                               | Use-case revisit with full library structure                |
| [Report 10](toolz_8_pipekit_cycle.md)                               | `toolz_8_pipekit_cycle.md`                          | `pipekit-cycle` — time-stepping, DA, observation operators  |
| [Report 11](toolz_9_pipekit_train.md)                               | `toolz_9_pipekit_train.md`                          | `pipekit-train` — training pipelines                        |
| [Report 12](toolz_10_pipekit_experiment.md)                         | `toolz_10_pipekit_experiment.md`                    | `pipekit-experiment` — tracking and model registry          |
| [Report 13](toolz_7_statecatalog.md)                                | `toolz_7_statecatalog.md`                           | `statecatalog` — catalog for model states                   |
| [Report 14](toolz_11_pipekit_evaluate.md)                           | `toolz_11_pipekit_evaluate.md`                      | `pipekit-evaluate` — multidimensional evaluation            |
| [Report 15](../supporting_info/benchmark.md)                        | `supporting_info/benchmark.md`                      | Benchmarking as first-class infrastructure                  |
| [Report 16](../supporting_info/modeling_cycle.md)                   | `supporting_info/modeling_cycle.md`                 | Data-driven modeling cycle, benchmark-gated L0–L4           |

## Companion documents

- [The Idea (v3)](../supporting_info/geostack_vision.md) — manifesto / vision document.
- [Data + ML lifecycle](../supporting_info/geodata_lifecycle.md) — three-layer model, two streams, depth axis, matchup.
- [Benchmarks gallery](../supporting_info/benchmark_gallery.md) — worked benchmark designs across six domains.

> **Note.** Filenames preserve historical ordering and don't match report numbers
> one-to-one. Use this table to navigate by report number.
