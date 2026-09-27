import Mathlib.Tactic.Ring

namespace Lehmer

structure State where
  c0 : Int
  c1 : Int
  c2 : Int
  c3 : Int
  c4 : Int
  c5 : Int
  c6 : Int
  c7 : Int
  c8 : Int
  c9 : Int
  deriving DecidableEq, Repr

namespace State

def zero : State := ⟨0, 0, 0, 0, 0, 0, 0, 0, 0, 0⟩

def mulBeta (s : State) : State :=
  ⟨-s.c9,
   s.c0 - s.c9,
   s.c1,
   s.c2 + s.c9,
   s.c3 + s.c9,
   s.c4 + s.c9,
   s.c5 + s.c9,
   s.c6 + s.c9,
   s.c7,
   s.c8 - s.c9⟩

inductive Digit where
  | neg
  | zero
  | pos
  deriving DecidableEq, Repr

namespace Digit

def val : Digit → Int
  | neg => -1
  | zero => 0
  | pos => 1

end Digit

def step (s : State) (d : Digit) : State :=
  let t := mulBeta s
  { t with c0 := t.c0 + d.val }

def run : State → List Digit → State
  | s, [] => s
  | s, d :: ds => run (step s d) ds

def valueStep {R : Type*} [CommRing R] (β : R) (x : R) (d : Digit) : R :=
  β * x + (d.val : R)

def runValue {R : Type*} [CommRing R] (β : R) : R → List Digit → R
  | x, [] => x
  | x, d :: ds => runValue β (valueStep β x d) ds

structure CompletionEntry where
  state : State
  suffix : List Digit
  deriving Repr

def checkCompletion (e : CompletionEntry) : Bool :=
  decide (run e.state e.suffix = zero)

def lehmerRel {R : Type*} [CommRing R] (β : R) : R :=
  β^10 + β^9 - β^7 - β^6 - β^5 - β^4 - β^3 + β + 1

def eval {R : Type*} [CommRing R] (β : R) (s : State) : R :=
  (s.c0 : R) + (s.c1 : R) * β + (s.c2 : R) * β^2 +
  (s.c3 : R) * β^3 + (s.c4 : R) * β^4 + (s.c5 : R) * β^5 +
  (s.c6 : R) * β^6 + (s.c7 : R) * β^7 + (s.c8 : R) * β^8 +
  (s.c9 : R) * β^9

theorem eval_mulBeta {R : Type*} [CommRing R] (β : R)
    (hβ : lehmerRel β = 0) (s : State) :
    eval β (mulBeta s) = β * eval β s := by
  calc
    eval β (mulBeta s) =
        β * eval β s - (s.c9 : R) * lehmerRel β := by
          simp [eval, mulBeta, lehmerRel]
          ring
    _ = β * eval β s := by simp [hβ]

theorem eval_step {R : Type*} [CommRing R] (β : R)
    (hβ : lehmerRel β = 0) (s : State) (d : Digit) :
    eval β (step s d) = β * eval β s + (d.val : R) := by
  calc
    eval β (step s d) = eval β (mulBeta s) + (d.val : R) := by
      simp [step, eval]
      ring
    _ = β * eval β s + (d.val : R) := by
      rw [eval_mulBeta β hβ s]

theorem eval_run {R : Type*} [CommRing R] (β : R)
    (hβ : lehmerRel β = 0) (s : State) (ds : List Digit) :
    eval β (run s ds) = runValue β (eval β s) ds := by
  induction ds generalizing s with
  | nil => rfl
  | cons d ds ih =>
      simp [run, runValue, valueStep, ih, eval_step, hβ]

theorem checkCompletion_sound (e : CompletionEntry)
    (h : checkCompletion e = true) :
    run e.state e.suffix = zero := by
  exact of_decide_eq_true h

theorem checkedCompletion_value_zero {R : Type*} [CommRing R] (β : R)
    (hβ : lehmerRel β = 0) (e : CompletionEntry)
    (h : checkCompletion e = true) :
    runValue β (eval β e.state) e.suffix = 0 := by
  rw [← eval_run β hβ e.state e.suffix]
  rw [checkCompletion_sound e h]
  simp [eval, zero]

end State
end Lehmer
