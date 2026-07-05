# TODO List

## Beats Page Inline Editing (Completed)

- [x] Fix compilation error: "the compiler is unable to type-check this expression in reasonable time"
  - Issue occurs when adding `activeBeatId` state and modifying onFocus closure
  - Need to simplify BeatCardView or use a different approach

- [x] Implement inline beat editing (similar to scene page)
  - Show beats in a list format instead of cards
  - Allow clicking on a beat to edit it inline
  - Highlight active beat being edited with accent color border

- [x] Update TemplateStepView.swift
  - Replace BeatCardView with BeatLineView struct
  - Add activeBeatId state for tracking which beat is being edited
  - Implement inline editing using existing BeatDraftTextEditor

## Release Process (Completed)

- [ ] Commit and push changes with tag v3.1b15
