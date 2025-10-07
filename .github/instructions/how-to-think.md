# Engineering Philosophy

This document contains universal software design principles that apply to any project. These are thinking frameworks, not rules to follow.

## Questions to Guide Your Thinking

**Before Writing Code:**

- What problem am I actually solving? (Not just the immediate task, but the deeper need)
- What are the essential concepts in this domain? How should they relate?
- What will this look like to someone encountering it for the first time?
- How will this change and evolve? What am I optimizing for?

**While Designing:**

- What is the simplest thing that could work? What is the simplest thing that could work *well*?
- Where are the natural boundaries between concepts?
- What would failure look like here? How can I make failure informative rather than mysterious?
- Am I modeling the problem or just implementing a solution?

**When Naming:**

- Does this name reveal intent or implementation details?
- Would someone reading this code understand the concept even without documentation?
- Am I being consistent with the mental model I've established elsewhere?
- Is this name diagnostic of good design or am I hiding complexity behind clever words?

## Core Design Tensions

Every software project involves fundamental tensions. Being aware of them helps you make conscious trade-offs:

**Simplicity vs. Completeness**: The urge to handle every edge case battles against the need for understandable systems. Favor simplicity, but acknowledge when complexity serves a real purpose.

**Consistency vs. Optimization**: Following established patterns may not always be the most efficient choice. Consistency serves human understanding; optimization serves machine performance. Choose deliberately.

**Abstraction vs. Clarity**: Abstractions hide complexity but can also hide understanding. Ask: does this abstraction reveal or obscure the essential nature of the problem?

**Flexibility vs. Constraint**: Systems that can do anything often do nothing well. Good constraints enable creativity by clarifying what matters.

## Universal Implementation Guidance

When contributing to any project, think through these dimensions:

### Conceptual Modeling

- What concepts exist in this domain? How do they relate?
- What are the essential vs. accidental complexities?
- What mental model will users build from this interface?

### Error Philosophy

- Errors are information, not failures. What information does this error convey?
- Can someone reading this error understand both what happened and why it matters?
- Does this error suggest a path forward?

### Naming as Communication

- Naming is not cosmetic - it's diagnostic of design clarity
- Names should reveal intent without requiring explanation
- Consistency in naming reflects consistency in thinking
- Deviation from patterns should signal genuine conceptual differences

### Composition Patterns

- Design components to combine naturally
- Each module should do one thing well and compose predictably
- Prefer composition over configuration where possible
- Make dependencies explicit and minimal

The goal is not perfect code, but code that clearly expresses the thoughts behind it.
