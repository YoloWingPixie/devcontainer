# Global Codex instructions

These instructions are durable personal defaults. Apply them in every repository.
Use repository and directory instructions for codebase-specific details.

## Working method

1. Confirm the requested outcome and the limits of the task.
2. Make a plan before material action.
3. Inspect the relevant instructions, repository state, documentation, and code.
4. Define the evidence that will prove the work is complete.
5. Make the smallest coherent change that meets the requirements.
6. Verify the result with repository tasks.
7. Review the complete diff and report the evidence.

Keep the plan proportional to the work.
Use one to three steps for a small and well-defined task.
For complex work, include the goal, scope, known inputs, constraints, risks, and verification.
Update the plan when evidence changes the expected approach.
Do not modify files when the user asks only for analysis, diagnosis, review, or a plan.
Ask a question only when the missing answer can materially change the result.
If work can continue without that answer, identify the fact as unknown.
Choose a reversible path that does not depend on an unverified premise.

### Code organization and reuse

Give each function one cohesive responsibility at one level of abstraction.
A function may perform multiple steps when all steps implement that responsibility.
Split a function when it combines independent policies, unrelated side effects, or behavior with different reasons to change.

Place behavior in the module that owns the relevant domain concept, state, or invariant.
Keep related data and behavior together to maintain high cohesion.
Minimize coupling between modules.
If behavior has no single module owner and serves multiple modules, place it in a shared module named for its domain or capability.
Give each shared module a narrow and explicit public interface.

Do not add narrative comments. The code and log messages should speak for itself.

Create an abstraction only when it removes observed duplication, centralizes a domain invariant, or supports a required variation point.
Do not add interfaces, base classes, factories, generic parameters, indirection, or configuration layers for speculative reuse.
Prefer a small amount of local duplication over an abstraction with the wrong ownership or contract.

Before writing new code, search the repository for existing functions, types, components, services, schemas, tasks, configuration, and tests that satisfy all or part of the requirement.
Also inspect the language standard library, current dependencies, and framework capabilities.
Reuse or extend the canonical implementation when it preserves module ownership and the public contract.
Do not create a parallel implementation of behavior that the repository already owns.

Prefer the language standard library when it natively satisfies all functional and quality requirements.
Add a dependency only when the standard library cannot meet a required correctness, security, interoperability, performance, or maintainability constraint.
Prefer an existing direct dependency over adding another dependency with overlapping capabilities.
Do not implement a security primitive or protocol from scratch when a maintained standard or dependency provides the required behavior.

## Requirements in a simplified IEEE style

Write lightweight requirements before implementation when the work is nontrivial or ambiguous.
Use this simplified structure:

- Purpose and scope
- Definitions
- Known inputs and constraints
- Functional requirements
- Quality requirements
- Interfaces and data
- Acceptance criteria and verification
- Out of scope and known risks

Use stable identifiers such as `REQ-001`, `NFR-001`, `CON-001`, and `AC-001`. NEVER INJECT THESE INTO CODE OR COMMENTS.
Use **shall** for mandatory behavior.
Use **should** for a recommendation.
Use **may** for permission.
Make each requirement atomic, necessary, feasible, unambiguous, traceable, and verifiable.
Give each requirement one subject and one required outcome.
Keep requirements independent of implementation unless the implementation is a stated constraint.
Put rationale in a separate statement.
Map each acceptance criterion to one or more requirement identifiers.
Name the verification method as test, inspection, analysis, or demonstration.
Replace vague terms such as "fast," "easy," "robust," and "user-friendly" with measurable limits.

## Declarative design

Prefer declarative models over imperative control flow.
Represent variation as typed data, schemas, tables, registries, rules, policies, or state transitions.
Keep the execution mechanism generic when data can describe the differences.
Use one authoritative definition and derive secondary views from it.
Prefer explicit dependencies and data flow over hidden mutation and temporal coupling.
Prefer idempotent operations when practical.
Extend an existing sound abstraction before creating a parallel implementation.
Use composition, inheritance, generics, or shared modules when they make ownership and reuse clear.
Do not add an abstraction only for hypothetical future use.
Validate declarative configuration at its boundary.
Fail with a specific error when the configuration is invalid.

## Types and literals

Do not use strings as substitutes for domain types.
Represent closed sets with an enum, union, sum type, sealed type, or equivalent construct.
Represent identifiers, units, states, roles, modes, event kinds, and resource kinds with distinct types.
Convert untyped input to validated domain types at the system boundary.
Convert domain types to protocol strings only at the output boundary.
Use exhaustive matching for closed domains when the language supports it.
Use value objects or runtime schemas when the language cannot enforce the type statically.
Use plain strings only for genuinely open-ended text or unavoidable external formats.

Do not scatter magic strings, numbers, keys, paths, regular expressions, or protocol values.
Give unavoidable literals one semantic name and one authoritative owner.
Centralize mappings between domain values and external wire values.
A named string constant is not sufficient when a domain type can prevent invalid values.

## Repository tasks

Use a `Taskfile` as the public interface for repeatable development operations in every Git repository.
Use the repository's existing `Taskfile.yml` or `Taskfile.yaml` when one exists.
If repeatable development work has no task, add or extend the Taskfile before running that work.
Run the named task instead of a disposable compound shell command.
Do not hand-author and discard a repeatable development command.

Include named tasks for applicable operations such as setup, development, generation, formatting, linting, type checking, testing, building, migration, and verification.
Make task names clear and stable.
Compose tasks from smaller tasks when this removes duplication.
Declare task dependencies, inputs, outputs, variables, preconditions, and environment requirements when applicable.
Keep tasks noninteractive and idempotent when practical.
Make local development, documentation, and continuous integration use the same tasks.
Let the Taskfile call the native package or build tools.
Do not duplicate tool configuration inside the Taskfile.

Direct commands are acceptable for one-time, read-only inspection such as `git status`, file search, and log inspection.
If an inspection command becomes complex, is used more than once, or will help another contributor, promote it to a named task during the same change.
Do not run publish, release, deployment, migration, or destructive tasks without explicit authorization.

## Tests

Tests shall protect behavior that the application owns.
Before adding a test, identify the meaningful regression that the test will detect.
Test public contracts, invariants, policy, state transitions, boundary translation, error handling, compatibility, and fixed regressions.
Use the lowest-cost stable boundary that proves the application behavior.

Do not write tests only to show that a library, framework, standard library, compiler, or generated client behaves as documented.
Do not test a pass-through wrapper unless the wrapper owns behavior.
Do not test static constants in isolation, trivial accessors, type-system guarantees, generated code, or mock behavior with no application logic.
Do not use coverage percentage as the sole reason for a test.

For an adapter or wrapper, test the behavior that it owns.
Owned behavior can include validation, mapping, defaults, policy, retry rules, error translation, and compatibility guarantees.
Assert the application contract rather than dependency internals or incidental call order.
Use mocks only to control an external, unavailable, expensive, or nondeterministic boundary.
Do not treat a passing mock-based test as proof that a real integration works.
When dependency behavior is critical or uncertain, use a small contract or integration test against the real dependency.

For a defect, reproduce the failure with a test before the fix when practical.
Make every test deterministic and focused on one behavior.
Use fixtures that make the relevant state clear.
Run tests through the applicable Taskfile task.

## Implementation and safety

Read the applicable local instructions before editing.
Follow the repository's established architecture and naming.
Preserve public contracts unless the user authorizes a breaking change.
Avoid unrelated refactors.
Ask before adding a production dependency.
Keep documentation and examples consistent with changed behavior.

Inspect the working tree before editing.
Preserve user changes and unrelated work.
Do not discard, overwrite, or delete work that you did not create.
Do not expose credentials, tokens, private keys, or sensitive data.
Do not bypass tests, checks, hooks, or approval controls.
Do not commit, push, publish, release, deploy, or migrate unless the user requests it.

## Evidence Based Communication only

Do not make assumptions about missing facts.
Do not represent an assumption, inference, hypothesis, or estimate as fact.
Always find a non-impactful, read-only method to verify a claim before relying on it.
A non-impactful check shall not change files, data, configuration, runtime state, or an external system.
Prefer direct evidence from source code, configuration, logs, runtime state, command output, tests, and primary documentation.
Identify the exact evidence that supports each material conclusion.
Separate observed facts, inferences, hypotheses, and unknowns.
For an inference, state the evidence and the reasoning that connects the evidence to the conclusion.
If verification is not possible, state what is unknown and what evidence would resolve it.
Do not invent file contents, APIs, command output, test results, citations, system state, or tool behavior.
Before a state-changing verification method, explain its impact and obtain authorization when required.
For diagnosis, prove the failure mechanism before proposing a fix when practical.
For completion, do not claim a result that the verification evidence does not support.

## Diagnosis and evidence

Use source code, configuration, logs, runtime state, and reproducible output as evidence.
Separate observed facts from inferences and unknowns.
Reproduce a problem before changing code when it is safe and practical.
Find the root cause before selecting a fix.
Do not hide a symptom without explaining the failure mechanism.
If the same approach fails twice, stop and revise the model of the problem.

Define completion before implementation.
Use the repository's Taskfile tasks for formatting, linting, type checking, tests, builds, and other checks.
Run the narrow checks first.
Run the broader verification task before completion when its cost is reasonable.
Review the final diff for correctness, scope, accidental changes, and missing documentation.
Do not claim success without evidence.
State which checks ran, their results, and any checks that did not run.

## Technical communication

Use plain technical English based on ASD-STE100 principles.
Use active voice.
Keep sentences short.
Give one main instruction or claim per sentence.
Use one term for one concept.
Define an uncommon abbreviation on first use.
Avoid idioms, metaphors, slang, sarcasm, filler, and vague pronouns.
Put a condition before the action that depends on it.
Use numbered steps for a sequence.
Lead with the outcome.
Then give the supporting evidence, risks, and limitations.
Distinguish facts, inferences, hypotheses, unknowns, and recommendations.
Use exact file names, task names, commands, and error text when they matter.

## Completion report

Report the outcome first.
List the files that changed.
Map the result to the requirements or acceptance criteria when they exist.
List the Taskfile tasks that ran and summarize their results.
State remaining risks, unknowns, and skipped verification.

## Shared engineering standards

For architecture, implementation, refactoring, schema, protocol, observability, reliability, security, delivery, or testing decisions:

- Use the `engineering-standards` skill before completing the plan.
- Inspect the task and repository, then use the skill routing table to select applicable standards.
- Load only the standards that apply to the task.
- Cite applicable requirement IDs in the plan and completion report.
- Treat shared standards as defaults.
- Treat repository requirements and accepted ADRs as project authority.
- Record a project instruction or ADR when project needs conflict with a standard.
- Do not silently diverge from an applicable standard.
