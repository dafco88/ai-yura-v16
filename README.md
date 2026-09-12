# AI-YURA v16 — résultats

AI-YURA est un programme de recherche indépendant sur l'**apprentissage continu** : un modèle qui
apprend des domaines successifs sans oublier les précédents, et qui se ré-entraîne seul sans jamais
régresser. Ce dépôt présente les **résultats mesurés**. Le code et la méthode restent privés.

> 🧪 Tester les modèles : **[dafco88/ai-yura-seeds](https://github.com/dafco88/ai-yura-seeds)**

## En bref

Chiffres tenus sur 3 graines :

- **84 à 89 %** du bénéfice d'un rejeu de données, **sans conserver aucune donnée**, avec 1/100 de
  la mémoire (20 Ko contre 2 Mo).
- Sans le composant central de la méthode : **−17 points en texte, −30 points en vision**. La
  protection est nécessaire, pas décorative.
- Sur 60 nuits de ré-entraînement automatique, la dérive de qualité reste bornée à **×1,07 à ×1,10**,
  contre ×39,7 à ×58,0 pour une porte de promotion classique.
- Le 29.08.2026, une régression réelle (perplexité 32,5 contre 20,9) a été **rejetée
  automatiquement** et le champion restauré, sans intervention humaine.

## 1. Oubli texte + vision

Banc multimodal, 1,85 M de paramètres, tâches texte et vision enchaînées, 3 graines. Santé en fin de
séquence, en % (haut = mieux).

| | Texte | Vision |
|---|---|---|
| Sans protection | 20,0 ± 4,8 | 33,3 ± 0,0 |
| Rejeu avec données (référence, 2 Mo stockés) | 94,0 ± 0,3 | 66,7 ± 0,0 |
| **AI-YURA (aucune donnée stockée)** | **82,3 ± 1,3** | **63,5 ± 3,4** |
| AI-YURA sans son composant central | 65,0 ± 0,7 | 33,3 |

## 2. Champion texte

Modèle de continuation de texte, ré-entraîné par phases. Chaque phase repart des poids de la
précédente, jamais de zéro. Perplexité (bas = mieux).

| Phase | Date | Perplexité moyenne | Cas validés |
|---|---|---|---|
| Phase 1 | 18.07.2026 | 254,0 | 13/15 |
| Phase 2 | 19.07.2026 | 140,4 | 15/15 |
| Phase 3 | 16.08.2026 | 59,0 → 44,4 | 15/15 |
| Phase 4 | 17.08.2026 | 30,6 | 15/15 |
| Phase 5 | 18.08.2026 | 25,3 | 12/12 |
| **Apprentissage autonome — champion** | **18.08.2026** | **20,9** | **12/12** |
| Apprentissage autonome — rejeté par la porte | 29.08.2026 | 32,5 | rollback automatique |
| Apprentissage autonome — rejeté par la porte | 30.08.2026 | 25,7 | rollback automatique |

Détail du champion du 18.08.2026 :

| Domaine | Perplexité |
|---|---|
| dialogue | 1,24 |
| logique | 10,19 |
| philosophie | 12,29 |
| mathématiques | 20,28 |
| français | 20,52 |
| sciences | 24,63 |
| TinyStories | 24,70 |
| histoire | 26,70 |
| Shakespeare | 33,15 |
| code | 34,85 |
| **moyenne** | **20,86** |

Plus deux cas de génération validés (français, histoire en anglais), soit 12/12.

## 3. Ophan — seed multimodale texte + vision

Née en août-septembre 2026 : 2,77 M de paramètres, trois domaines texte et six classes d'images
(hasard : 16,7 %). Les trois graines ont passé la porte de promotion.

| Graine | Perplexité moyenne | Vision |
|---|---|---|
| 42 | 12,48 | 44,4 % |
| **123** | **12,43** | 36,1 % |
| 7 | 12,68 | **47,2 %** |

## 4. Porte de promotion

Simulation de 60 nuits de ré-entraînement, candidats qui dérivent de +9 % par promotion, tolérance
×1,10, 3 graines.

| Porte | Dérive finale | Borne ×1,10 respectée |
|---|---|---|
| Classique (compare au dernier champion) | ×39,7 à ×58,0 | 0/3 |
| Pondérée par l'historique | ×1,10 à ×1,16 | 1/3 |
| **AI-YURA** | **×1,07 à ×1,10** | **3/3** |

Vérifiée en production le 29.08.2026 (voir §2).

## 4bis. Résultats formels vérifiés mécaniquement (Lean 4)

Le comportement de la porte n'est pas qu'un résultat de simulation : il découle de deux théorèmes simples,
**vérifiés par Lean 4.33.1**, sans Mathlib, sans `sorry` ni `axiom`. L'algèbre utilisée (un semi-anneau
ordonné) est déclarée explicitement, et une instance concrète sur les entiers naturels montre qu'elle
n'est pas vide. Fichiers dans [`preuves/`](preuves/).

| Fichier — énoncé | Résultat | Portée |
|---|---|---|
| `SafetyGate.lean` — théorème 2 | Porte **dépendante du chemin** (référence = dernier état accepté, seuil τ par tour) : la seule garantie au tour n est **sₙ ≥ τⁿ · s₀**, qui se dégrade géométriquement | résultat principal |
| `SafetyGate.lean` — théorème 1 | Porte **ancrée** (référence = état initial) : **sₙ ≥ τ · s₀ à tout tour**, indépendamment de la longueur | découle directement de la règle ; sert de contraste |
| `Consolidation.lean` — théorème 3 | Contrainte **par pas** ≤ c : dérive cumulée ≤ **n · c** | borne croissante avec le temps |
| `Consolidation.lean` — théorème 4 | Contrainte **à distance de l'origine** ≤ B : borne **B** à tout tour | constante en n |
| `Consolidation.lean` — théorème 5 | Mémoire à **moyenne mobile exponentielle** : la contribution de l'état initial est ≤ **rⁿ** | effacement géométrique |

Lecture : une référence **ancrée** donne une garantie constante, une référence **dépendante du chemin**
une garantie qui s'érode à chaque tour. La simulation du §4 en est l'illustration numérique (×39,7 à ×58,0
pour la porte classique contre ×1,07 à ×1,10 pour la porte ancrée).

**Ce qui n'est PAS établi** : la convergence rⁿ → 0 (analyse réelle non formalisée) ; qu'une référence figée
soit préférable en général (elle borne l'oubli mais aussi l'apprentissage) ; la correspondance exacte entre
ces énoncés et une implémentation donnée, qui reste une hypothèse de modélisation.

Vérifier soi-même : `cd preuves && lake build` (Lean 4.33.1 via `elan`, quelques secondes).

## 5. Limites connues

- En vision, les tâches les plus anciennes restent mal retenues. Trois pistes testées en septembre
  2026 n'ont pas apporté de gain.
- Le champion texte n'a pas été remplacé depuis le 18.08.2026 : les domaines code, Shakespeare et
  TinyStories font échouer les candidats.
- Les résultats à une seule graine sont traités comme des directions, jamais comme des conclusions.

## Le projet en chiffres

Avril → septembre 2026 : 131 checkpoints, 375 fichiers de résultats, 10 ères d'expérimentation,
60/60 tests automatisés.

## Licence

Tous droits réservés. Voir [LICENCE.md](LICENCE.md).
