import Lehmer.Core

namespace Lehmer
open State

def boundaryPlus : State :=
  ⟨-2, -3, -3, -2, -1, 0, 1, 2, 2, 1⟩

def boundaryMinus : State :=
  ⟨2, 3, 3, 2, 1, 0, -1, -2, -2, -1⟩

theorem boundaryPlus_identity {R : Type*} [CommRing R] (β : R)
    (hβ : lehmerRel β = 0) :
    (β - 1) * eval β boundaryPlus = 1 := by
  calc
    (β - 1) * eval β boundaryPlus = 1 + lehmerRel β := by
      simp [boundaryPlus, eval, lehmerRel]
      ring
    _ = 1 := by simp [hβ]

end Lehmer
