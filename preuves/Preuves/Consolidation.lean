/-
  Consolidation.lean — transfert des theoremes de porte aux regularisateurs
  anti-oubli en espace de parametres.

  Aucune dependance Mathlib. Axiomatique explicite, instance Nat en fin de
  fichier pour etablir la non-vacuite.
-/

namespace Consolidation

/-- Semi-anneau ordonne : toutes les proprietes utilisees sont listees ici. -/
class OrdSemiring (K : Type) where
  le   : K → K → Prop
  add  : K → K → K
  mul  : K → K → K
  one  : K
  zero : K
  le_refl   : ∀ a : K, le a a
  le_trans  : ∀ {a b c : K}, le a b → le b c → le a c
  add_mono  : ∀ {a b c d : K}, le a b → le c d → le (add a c) (add b d)
  mul_mono_left : ∀ {a b : K}, le a b → ∀ {c : K}, le zero c → le (mul c a) (mul c b)
  one_mul   : ∀ a : K, mul one a = a
  mul_assoc : ∀ a b c : K, mul (mul a b) c = mul a (mul b c)

open OrdSemiring
variable {K : Type} [OrdSemiring K]

/-! ## 1. Derive cumulee sous contrainte PAR PAS (regime sequentiel) -/

/-- `nmul n c = c + c + ... + c` (n fois). -/
def nmul (n : Nat) (c : K) : K :=
  match n with
  | 0      => zero
  | n' + 1 => add c (nmul n' c)

/-- Distance totale parcourue apres n pas, `d i` etant la longueur du pas i. -/
def cumDrift (d : Nat → K) : Nat → K
  | 0      => zero
  | n' + 1 => add (d n') (cumDrift d n')

/--
  THEOREME 3 — ACCUMULATION LINEAIRE DE LA DERIVE SEQUENTIELLE.

  Si la penalite borne chaque PAS par `c` (forme `||theta_t - theta_{t-1}|| <= c`),
  alors la derive totale depuis l'origine n'est bornee que par `n * c`.
  La borne CROIT avec le nombre de tours : aucune garantie a horizon long.
-/
theorem drift_linear (d : Nat → K) (c : K) (h : ∀ i, le (d i) c) :
    ∀ n : Nat, le (cumDrift d n) (nmul n c) := by
  intro n
  induction n with
  | zero => exact le_refl _
  | succ k ih => exact add_mono (h k) ih

/-! ## 2. Contrainte ANCREE (reference figee) -/

/--
  THEOREME 4 — BORNE ANCREE, INDEPENDANTE DE L'HORIZON.

  Si la penalite borne la distance A L'ORIGINE (forme `||theta_t - theta_0|| <= B`),
  la borne est la meme a tout tour. `n` n'apparait pas dans la conclusion.
-/
theorem anchored_bounded (dist : Nat → K) (B : K)
    (h : ∀ n : Nat, le (dist n) B) :
    ∀ n : Nat, le (dist n) B :=
  h

/-! ## 3. Oubli geometrique d'une memoire a moyenne mobile exponentielle -/

/-- `geoMem r n = r^n`, avec `r = 1 - rho` le facteur de retention par pas. -/
def geoMem (r : K) : Nat → K
  | 0      => one
  | n' + 1 => mul r (geoMem r n')

/--
  THEOREME 5 — DECROISSANCE GEOMETRIQUE DE LA MEMOIRE EMA.

  Une memoire mise a jour par `a <- (1-rho)*a + rho*theta` voit la
  contribution de son etat initial contractee par `r = 1-rho` a chaque pas.
  Apres n pas il n'en subsiste que `r^n`.

  Pour tout `rho > 0` on a `r < 1` : la memoire de l'origine s'efface
  exponentiellement. Aucun choix de `rho > 0` ne produit un plancher.
-/
theorem ema_geometric_decay (r : K) (a : Nat → K)
    (hr : le (zero : K) r)
    (h : ∀ i : Nat, le (a (i + 1)) (mul r (a i))) :
    ∀ n : Nat, le (a n) (mul (geoMem r n) (a 0)) := by
  intro n
  induction n with
  | zero =>
    show le (a 0) (mul (geoMem r 0) (a 0))
    rw [show (geoMem r 0 : K) = one from rfl, one_mul]
    exact le_refl _
  | succ k ih =>
    have step1 : le (mul r (a k)) (mul r (mul (geoMem r k) (a 0))) :=
      mul_mono_left ih hr
    have eq1 : mul (geoMem r (k + 1)) (a 0) = mul r (mul (geoMem r k) (a 0)) := by
      show mul (mul r (geoMem r k)) (a 0) = _
      exact mul_assoc _ _ _
    rw [eq1]
    exact le_trans (h k) step1

/-!
  ## Lecture

  Theoreme 3 : contrainte par pas  -> borne `n * c`, croissante en n.
  Theoreme 4 : contrainte ancree   -> borne `B`, constante en n.
  Theoreme 5 : memoire EMA         -> retention `r^n`, decroissante en n.

  Toute memoire mise a jour par moyenne mobile exponentielle
  `x <- (1-rho)*x + rho*(nouveau)` releve du theoreme 5 : sa memoire de l'etat
  initial s'efface en `r^n`. Elle ne releve PAS du theoreme 4.

  PORTEE — ce qui n'est PAS etabli ici :
    * que `r^n -> 0` (analyse reelle, non formalisee) ;
    * qu'une ancre figee serait PREFERABLE : le theoreme 4 borne la derive,
      il ne dit rien du cout en plasticite, qui est le sujet meme de
      l'apprentissage continu. Geler l'ancre borne l'oubli ET l'apprentissage ;
    * que ces enonces modelisent correctement une implementation donnee :
      le pont entre une mise a jour concrete et l'hypothese `h` ici reste
      une hypothese de modelisation.
-/

/-! ## Non-vacuite -/

instance : OrdSemiring Nat where
  le            := Nat.le
  add           := Nat.add
  mul           := Nat.mul
  one           := 1
  zero          := 0
  le_refl       := Nat.le_refl
  le_trans      := Nat.le_trans
  add_mono      := fun h1 h2 => Nat.add_le_add h1 h2
  mul_mono_left := fun h _ _ => Nat.mul_le_mul_left _ h
  one_mul       := Nat.one_mul
  mul_assoc     := Nat.mul_assoc

example (d : Nat → Nat) (c : Nat) (h : ∀ i, d i ≤ c) (n : Nat) :
    OrdSemiring.le (cumDrift d n) (nmul n c) :=
  drift_linear d c h n

end Consolidation

