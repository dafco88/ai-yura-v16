/-
  SafetyGate.lean — les deux theoremes portants du chantier safety-gate.

  Aucune dependance Mathlib. La structure algebrique est declaree
  explicitement ci-dessous : tous les axiomes utilises sont visibles.
  Une instance concrete (Nat) est fournie en fin de fichier pour etablir
  que l'axiomatique n'est pas vide.
-/

namespace SafetyGate

/-- Semi-anneau ordonne : les seules proprietes utilisees par les preuves. -/
class OrdRing (K : Type) where
  le   : K → K → Prop
  mul  : K → K → K
  one  : K
  zero : K
  le_refl       : ∀ a : K, le a a
  le_trans      : ∀ {a b c : K}, le a b → le b c → le a c
  mul_mono_left : ∀ {a b : K}, le a b → ∀ {c : K}, le zero c → le (mul c a) (mul c b)
  one_mul       : ∀ a : K, mul one a = a
  mul_assoc     : ∀ a b c : K, mul (mul a b) c = mul a (mul b c)

open OrdRing

variable {K : Type} [OrdRing K]

/-
  `s i` = mesure de securite de l'etat commite au tour i, sur la sonde gelee.
  `s 0` = etat aligne initial.
  `tau` = seuil de retention de la porte.
-/

/-- Regle de la porte ANCREE : reference figee sur l'etat initial. -/
def AnchoredRule (tau : K) (s : Nat → K) : Prop :=
  ∀ i : Nat, le (mul tau (s 0)) (s i)

/-- Regle de la porte MARKOVIENNE : reference = dernier etat accepte. -/
def MarkovRule (tau : K) (s : Nat → K) : Prop :=
  ∀ i : Nat, le (mul tau (s i)) (s (i + 1))

/-- Puissance iteree : `tauPow tau n = tau^n`. -/
def tauPow (tau : K) : Nat → K
  | 0     => one
  | n + 1 => mul tau (tauPow tau n)

/--
  THEOREME 1 — PLANCHER DE LA PORTE ANCREE.

  Sous la regle ancree, tout etat commite reste au-dessus de `tau * s0`,
  a n'importe quel tour `n`. La borne ne depend NI de la longueur de la
  sequence NI de la force de l'adversaire.
-/
theorem anchored_floor (tau : K) (s : Nat → K)
    (h : AnchoredRule tau s) (n : Nat) :
    le (mul tau (s 0)) (s n) :=
  h n

/--
  THEOREME 2 — BORNE GEOMETRIQUE DE LA PORTE MARKOVIENNE.

  Sous la regle markovienne, la seule garantie disponible au tour `n` est
  `s n >= tau^n * s 0`. Elle DEPEND de `n` et se degrade a chaque tour.
-/
theorem markov_geometric (tau : K) (s : Nat → K)
    (htau : le (zero : K) tau) (h : MarkovRule tau s) :
    ∀ n : Nat, le (mul (tauPow tau n) (s 0)) (s n) := by
  intro n
  induction n with
  | zero =>
    show le (mul (tauPow tau 0) (s 0)) (s 0)
    rw [show (tauPow tau 0 : K) = one from rfl, one_mul]
    exact le_refl _
  | succ k ih =>
    have step1 : le (mul tau (mul (tauPow tau k) (s 0))) (mul tau (s k)) :=
      mul_mono_left ih htau
    have step2 : le (mul tau (s k)) (s (k + 1)) := h k
    have eq1 : mul (tauPow tau (k + 1)) (s 0) = mul tau (mul (tauPow tau k) (s 0)) := by
      show mul (mul tau (tauPow tau k)) (s 0) = _
      exact mul_assoc _ _ _
    rw [eq1]
    exact le_trans step1 step2

/--
  COROLLAIRE — la garantie ancree est invariante par extension de sequence.
  Formellement : si la regle ancree tient, la meme borne vaut pour tout m, n.
-/
theorem anchored_length_invariant (tau : K) (s : Nat → K)
    (h : AnchoredRule tau s) (m n : Nat) :
    le (mul tau (s 0)) (s m) ∧ le (mul tau (s 0)) (s n) :=
  ⟨h m, h n⟩

/-! ### Non-vacuite : instance concrete sur Nat -/

instance : OrdRing Nat where
  le            := Nat.le
  mul           := Nat.mul
  one           := 1
  zero          := 0
  le_refl       := Nat.le_refl
  le_trans      := Nat.le_trans
  mul_mono_left := fun h _ _ => Nat.mul_le_mul_left _ h
  one_mul       := Nat.one_mul
  mul_assoc     := Nat.mul_assoc

/-- Verification que les theoremes s'instancient effectivement. -/
example (s : Nat → Nat) (h : AnchoredRule 1 s) (n : Nat) :
    OrdRing.le (OrdRing.mul 1 (s 0)) (s n) :=
  anchored_floor 1 s h n

end SafetyGate

