import Lehmer.CompletionData

namespace Lehmer

/-- All 1705 entries pass the finite checker. -/
theorem completionEntries_checked :
    completionEntries.all State.checkCompletion = true := by
  simp only [completionEntries, List.all_append,
    completionChunk00_checked, completionChunk01_checked, completionChunk02_checked,
    completionChunk03_checked, completionChunk04_checked, completionChunk05_checked,
    completionChunk06_checked, completionChunk07_checked, completionChunk08_checked,
    completionChunk09_checked, completionChunk10_checked, completionChunk11_checked,
    completionChunk12_checked, completionChunk13_checked, completionChunk14_checked,
    completionChunk15_checked, completionChunk16_checked, completionChunk17_checked, Bool.and_self]

theorem completionEntry_run_zero (e : State.CompletionEntry)
    (he : e ∈ completionEntries) : State.run e.state e.suffix = State.zero := by
  exact State.checkCompletion_sound e (List.all_eq_true.mp completionEntries_checked e he)

/-- Algebraic meaning of every listed certificate; not a coverage theorem. -/
theorem completionEntry_value_zero {R : Type*} [CommRing R] (β : R)
    (hβ : State.lehmerRel β = 0) (e : State.CompletionEntry)
    (he : e ∈ completionEntries) :
    State.runValue β (State.eval β e.state) e.suffix = 0 := by
  exact State.checkedCompletion_value_zero β hβ e
    (List.all_eq_true.mp completionEntries_checked e he)

end Lehmer
